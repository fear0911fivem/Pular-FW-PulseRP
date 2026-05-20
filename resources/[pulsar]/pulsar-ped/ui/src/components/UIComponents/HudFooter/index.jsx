import React from 'react';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles(() => ({
	footer: {
		width: '100%',
		flexShrink: 0,
		paddingTop: '1rem',
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'space-between',
		gap: '1rem',
	},
	left: {
		display: 'flex',
		alignItems: 'center',
		minWidth: 0,
	},
	buttons: {
		display: 'flex',
		alignItems: 'center',
		gap: '.75rem',
		marginLeft: 'auto',
	},
	button: {
		display: 'flex',
		padding: '.75rem 1rem',
		alignItems: 'center',
		justifyContent: 'center',
		width: 'fit-content',
		gap: '.6125rem',
		color: '#fff',
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: '1rem',
		lineHeight: 1,
		cursor: 'pointer',
		transition: 'background .2s ease, border .2s ease, opacity .2s ease',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		border: '1px solid transparent',
		textTransform: 'uppercase',
		'&:hover': {
			background: 'var(--black-hover)',
			borderColor: 'hsla(0, 0%, 100%, .12)',
		},
	},
	save: {
		background: 'rgba(var(--green-active-rgb), .2)',
		borderColor: 'rgba(var(--green-active-rgb), .5)',
		'&:hover': {
			background: 'rgba(var(--green-active-rgb), .35)',
			borderColor: 'var(--bright-green)',
		},
	},
}));

export default function HudFooter({ children, onDiscard, onSave }) {
	const classes = useStyles();

	return (
		<div className={classes.footer}>
			<div className={classes.left}>{children}</div>
			<div className={classes.buttons}>
				<button className={classes.button} type="button" onClick={onDiscard}>
					Discard
				</button>
				<button className={`${classes.button} ${classes.save}`} type="button" onClick={onSave}>
					Save
				</button>
			</div>
		</div>
	);
}
