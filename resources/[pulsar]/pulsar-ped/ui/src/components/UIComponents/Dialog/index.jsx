import React from 'react';
import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
} from '@mui/material';
import { createTheme, ThemeProvider } from '@mui/material/styles';

const srpDialogTheme = createTheme({
	typography: {
		fontFamily: ['Bai Jamjuree'],
	},
	palette: {
		primary: {
			main: '#4B6611',
			light: '#D9D9D9',
			dark: '#11121b',
			contrastText: '#ffffff',
		},
		secondary: {
			main: '#000D1A',
			light: '#223239',
			dark: '#000617',
			contrastText: '#ffffff',
		},
		error: {
			main: '#6e1616',
			light: '#a13434',
			dark: '#430b0b',
		},
		success: {
			main: '#4B6611',
			light: '#60eb50',
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
			light: '#000000',
			dark: '#cecece',
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
		MuiCssBaseline: {
			styleOverrides: {
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
	},
});

export default ({
	open,
	title,
	onAccept,
	onDecline,
	children,
	declineLang = 'Cancel',
	acceptLang = 'Save',
}) => (
	<ThemeProvider theme={srpDialogTheme}>
		<Dialog fullWidth maxWidth="sm" open={open}>
			<DialogTitle>
				{title}
			</DialogTitle>
			<DialogContent dividers>
				{children}
			</DialogContent>
			<DialogActions>
				<Button onClick={onDecline}>
					{declineLang}
				</Button>
				<Button onClick={onAccept}>
					{acceptLang}
				</Button>
			</DialogActions>
		</Dialog>
	</ThemeProvider>
);
