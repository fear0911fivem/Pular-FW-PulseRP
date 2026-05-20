const fs = require('fs');
const http = require('http');
const path = require('path');
const { exec } = require('child_process');

const root = path.resolve(__dirname, '..', 'srp');
const localesRoot = path.resolve(__dirname, '..', '..', 'locales');
const port = Number(process.env.PORT || process.env.npm_config_port || 3000);

const mimeTypes = {
	'.html': 'text/html; charset=utf-8',
	'.js': 'text/javascript; charset=utf-8',
	'.css': 'text/css; charset=utf-8',
	'.json': 'application/json; charset=utf-8',
	'.otf': 'font/otf',
	'.png': 'image/png',
	'.webp': 'image/webp',
	'.svg': 'image/svg+xml',
};

const demoAccounts = [
	{
		id: 253746,
		accountNumber: 253746,
		name: 'Personal Checking',
		balance: 42650,
		type: 'personal',
		owner: 1,
		frozen: false,
		permissions: {
			MANAGE: true,
			BALANCE: true,
			WITHDRAW: true,
			DEPOSIT: true,
			TRANSACTIONS: true,
		},
		jointOwners: [],
	},
	{
		id: 691204,
		accountNumber: 691204,
		name: 'Savings Account',
		balance: 138900,
		type: 'personal_savings',
		owner: 1,
		frozen: false,
		permissions: {
			MANAGE: true,
			BALANCE: true,
			WITHDRAW: true,
			DEPOSIT: true,
			TRANSACTIONS: true,
		},
		jointOwners: [
			{ stateId: 42, firstName: 'Alex', lastName: 'Stone' },
		],
	},
	{
		id: 802113,
		accountNumber: 802113,
		name: 'Business Account',
		balance: 284500,
		type: 'organization',
		owner: 'business',
		frozen: false,
		permissions: {
			MANAGE: false,
			BALANCE: true,
			WITHDRAW: true,
			DEPOSIT: true,
			TRANSACTIONS: true,
		},
		jointOwners: [],
	},
];

const now = Date.now();
const demoTransactions = [
	{
		id: 'preview-1',
		accountNumber: 253746,
		title: 'Cash Deposit',
		description: 'Preview transaction',
		amount: 2500,
		type: 'deposit',
		createdAt: now - 1000 * 60 * 35,
	},
	{
		id: 'preview-2',
		accountNumber: 253746,
		title: 'Cash Withdrawal',
		description: 'ATM withdrawal',
		amount: -650,
		type: 'withdraw',
		createdAt: now - 1000 * 60 * 60 * 5,
	},
	{
		id: 'preview-3',
		accountNumber: 691204,
		title: 'Incoming Bank Transfer',
		description: 'Transfer from Account: 253746.',
		amount: 12400,
		type: 'transfer',
		createdAt: now - 1000 * 60 * 60 * 18,
	},
	{
		id: 'preview-4',
		accountNumber: 802113,
		title: 'Paycheck',
		description: 'Paycheck For 120 Minutes Worked',
		amount: 3200,
		type: 'paycheck',
		createdAt: now - 1000 * 60 * 60 * 30,
	},
];

function getLocalesPayload() {
	const localePath = path.join(localesRoot, 'en.json');
	const raw = fs.existsSync(localePath) ? fs.readFileSync(localePath, 'utf8') : '{}';
	const translation = JSON.parse(raw);

	return {
		locales: JSON.stringify({
			en: {
				translation,
			},
		}),
		defaultLocale: 'en',
	};
}

function getCallbackResponse(endpoint, payload) {
	switch (endpoint) {
		case 'GET_LOCALES':
			return getLocalesPayload();
		case 'banking:validateReceiver':
			return { stateId: Number(payload.receiver) || 1, firstName: 'John', lastName: 'Doe' };
		case 'banking:doAction':
			return { success: true };
		case 'banking:createAccount':
			return { success: true };
		case 'banking:addJointOwner':
			return {
				success: {
					stateId: Number(payload.stateId) || 2,
					firstName: 'Preview',
					lastName: 'Owner',
				},
			};
		case 'banking:deleteJointOwner':
			return { success: true };
		case 'banking:saveAccount':
		case 'banking:deleteAccount':
			return true;
		case 'banking:getTransactions':
			return demoTransactions.filter((transaction) => (
				String(transaction.accountNumber) === String(payload.accountNumber)
			));
		case 'banking:exportTransactions':
			return false;
		default:
			return {};
	}
}

function readRequestBody(request) {
	return new Promise((resolve) => {
		let body = '';

		request.on('data', (chunk) => {
			body += chunk;
		});

		request.on('end', () => {
			try {
				resolve(body ? JSON.parse(body) : {});
			} catch {
				resolve({});
			}
		});
	});
}

function buildPreviewScript() {
	const localePayload = getLocalesPayload();

	return `
<script>
(() => {
	window.GetParentResourceName = () => 'pulsar-finance';

	const localePayload = ${JSON.stringify(localePayload)};
	const accounts = ${JSON.stringify(demoAccounts)};
	const transactions = ${JSON.stringify(demoTransactions)};
	const summary = { changeInLast7Days: [2400, -650, 12400, 3200, 850, -400, 1900] };

	const responses = {
		GET_LOCALES: localePayload,
		'banking:validateReceiver': { stateId: 1, firstName: 'John', lastName: 'Doe' },
		'banking:doAction': { success: true },
		'banking:createAccount': { success: true },
		'banking:addJointOwner': { success: { stateId: 2, firstName: 'Preview', lastName: 'Owner' } },
		'banking:deleteJointOwner': { success: true },
		'banking:saveAccount': true,
		'banking:deleteAccount': true,
		'banking:getTransactions': transactions,
		'banking:exportTransactions': false,
	};

	const originalFetch = window.fetch.bind(window);
	window.fetch = (input, init = {}) => {
		const url = typeof input === 'string' ? input : input.url;
		const endpoint = decodeURIComponent(url.split('/').pop());

		if (url.includes('pulsar-finance') || responses[endpoint] !== undefined) {
			return Promise.resolve(new Response(JSON.stringify(responses[endpoint] ?? {}), {
				headers: { 'Content-Type': 'application/json' },
			}));
		}

		return originalFetch(input, init);
	};

	const send = (action, data) => {
		window.postMessage({ action, data }, '*');
	};

	const boot = () => {
		send('banking:setView', new URLSearchParams(window.location.search).get('view') === 'atm' ? 'ATM' : 'BANKING');
		send('banking:setDepositVisible', true);
		send('banking:atm:setData', { street: 'Hawick Ave', maxWithdraw: 5000 });
		send('banking:setPlayer', {
			character: { stateId: 1, firstName: 'John', lastName: 'Doe' },
			cash: 52352,
		});
		send('banking:setAccounts', accounts);
		send('banking:setSummary', summary);
		send('banking:setTransactions', transactions);
		send('banking:setVisible', true);
	};

	window.addEventListener('load', () => {
		setTimeout(boot, 250);
		setTimeout(boot, 900);
	});
})();
</script>`;
}

function send(response, status, content, type) {
	response.writeHead(status, {
		'Content-Type': type,
		'Cache-Control': 'no-store',
	});
	response.end(content);
}

function safeResolve(urlPath) {
	const decodedPath = decodeURIComponent(urlPath.split('?')[0]);
	const requestedPath = decodedPath === '/' ? '/index.html' : decodedPath;
	const filePath = path.resolve(root, `.${requestedPath}`);

	if (!filePath.startsWith(root)) {
		return null;
	}

	return filePath;
}

const server = http.createServer(async (request, response) => {
	if (request.method === 'POST') {
		const endpoint = decodeURIComponent(request.url.split('/').pop());
		const payload = await readRequestBody(request);
		send(response, 200, JSON.stringify(getCallbackResponse(endpoint, payload)), mimeTypes['.json']);
		return;
	}

	const filePath = safeResolve(request.url);
	if (!filePath || !fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
		send(response, 404, 'Not found', 'text/plain; charset=utf-8');
		return;
	}

	if (path.basename(filePath) === 'index.html') {
		const html = fs.readFileSync(filePath, 'utf8').replace('</head>', `${buildPreviewScript()}</head>`);
		send(response, 200, html, mimeTypes['.html']);
		return;
	}

	const ext = path.extname(filePath).toLowerCase();
	send(response, 200, fs.readFileSync(filePath), mimeTypes[ext] || 'application/octet-stream');
});

server.listen(port, () => {
	const url = `http://localhost:${port}`;
	console.log(`PRP finance preview running at ${url}`);

	if (process.platform === 'win32') {
		exec(`start "" "${url}"`);
	}
});
