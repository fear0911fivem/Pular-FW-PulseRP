import '@babel/polyfill';
import './srp-hud.css';

import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import CssBaseline from '@mui/material/CssBaseline';
import {
	ThemeProvider,
	createTheme,
	StyledEngineProvider,
} from '@mui/material';

import App from 'containers/App';
import WindowListener from 'containers/WindowListener';
import configureStore from './configureStore';
import KeyListener from './containers/KeyListener';

const initialState = {};
const store = configureStore(initialState);
const MOUNT_NODE = document.getElementById('app');

const render = () => {
	const muiTheme = createTheme({
		typography: {
			fontFamily: ['Bai Jamjuree', 'sans-serif'],
		},
		palette: {
			primary: {
				main: '#87da21',
				light: '#9eff00',
				dark: '#425c2c',
				contrastText: '#ffffff',
			},
			secondary: {
				main: 'rgba(26, 31, 20, 0.85)',
				light: '#425c2c',
				dark: '#0b1203',
				contrastText: '#ffffff',
			},
			error: {
				main: '#6e1616',
				light: '#a13434',
				dark: '#430b0b',
			},
			success: {
				main: '#87da21',
				light: '#9eff00',
				dark: '#244a20',
			},
			warning: {
				main: '#f09348',
				light: '#f2b583',
				dark: '#b05d1a',
			},
			info: {
				main: '#247ba5',
				light: '#247ba5',
				dark: '#175878',
			},
			text: {
				main: '#ffffff',
				alt: '#cecece',
				info: '#919191',
				light: '#ffffff',
				dark: '#000000',
			},
			rarities: {
				rare1: '#ffffff',
				rare2: '#87da21',
				rare3: '#247ba5',
				rare4: '#11121b',
				rare5: '#f2d411',
			},
			border: {
				main: '#e0e0e008',
				light: '#ffffff',
				dark: '#26292d',
				input: 'rgba(255, 255, 255, 0.23)',
				divider: '#2d2e44',
				item: 'rgb(255, 255, 255)',
			},
			mode: 'dark',
		},
		components: {
			MuiCssBaseline: {
				styleOverrides: {
					html: {
						background:
							process.env.NODE_ENV != 'production'
								? '#000000'
								: 'transparent',
					},
					'*': {
						'&::-webkit-scrollbar': { width: 6 },
						'&::-webkit-scrollbar-thumb': {
							background: '#87da21',
						},
						'&::-webkit-scrollbar-track': {
							background: '#101010',
						},
					},
					body: {
						'.fade-enter': { opacity: 0 },
						'.fade-exit': { opacity: 1 },
						'.fade-enter-active': { opacity: 1 },
						'.fade-exit-active': { opacity: 0 },
						'.fade-enter-active, .fade-exit-active': {
							transition: 'opacity 500ms',
						},
					},
				},
			},
			MuiTooltip: {
				styleOverrides: {
					tooltip: {
						fontSize: 16,
						backgroundColor: '#111315',
						border: '1px solid rgba(255, 255, 255, 0.23)',
						boxShadow: '0 0 10px #000',
					},
				},
			},
			MuiPaper: {
				styleOverrides: {
					root: {
						background: '#111315',
					},
				},
			},
			MuiAppBar: {
				styleOverrides: {
					root: {
						backgroundImage: 'none',
					},
					colorTransparent: {
						backgroundColor: 'transparent',
						boxShadow: 'none',
					},
				},
			},
			MuiTab: {
				styleOverrides: {
					root: {
						fontFamily: "'Bai Jamjuree', sans-serif",
						fontWeight: 700,
						fontSize: 12,
						letterSpacing: '0.1em',
						color: 'rgba(255,255,255,0.6)',
						transition: 'color 0.2s ease',
						'&.Mui-selected': {
							color: '#87da21',
						},
					},
				},
			},
			MuiTabs: {
				styleOverrides: {
					indicator: {
						backgroundColor: '#87da21',
					},
				},
			},
		},
	});

	ReactDOM.render(
		<Provider store={store}>
			<KeyListener>
				<WindowListener>
					<StyledEngineProvider injectFirst>
						<ThemeProvider theme={muiTheme}>
							<CssBaseline />
							<App />
						</ThemeProvider>
					</StyledEngineProvider>
				</WindowListener>
			</KeyListener>
		</Provider>,
		MOUNT_NODE,
	);
};

if (module.hot) {
	module.hot.accept(['containers/App'], () => {
		ReactDOM.unmountComponentAtNode(MOUNT_NODE);
		render();
	});
}

render();
