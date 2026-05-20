import React from 'react';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles(() => ({
	wrapper: {
		position: 'absolute',
		bottom: 14,
		left: '50%',
		transform: 'translateX(-50%)',
		display: 'flex',
		alignItems: 'center',
		padding: '8px 16px',
		gap: 20,
		background: 'rgba(0,0,0,0.72)',
		border: '1px solid rgba(135, 218, 33, .2)',
		boxShadow: '0 0 20px rgba(0,0,0,0.5), 0 0 10px rgba(135, 218, 33, .06)',
		borderRadius: 2,
		userSelect: 'none',
		whiteSpace: 'nowrap',
	},
	row: {
		display: 'flex',
		alignItems: 'center',
		gap: 6,
		fontSize: 11,
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontWeight: 600,
		textTransform: 'uppercase',
		letterSpacing: '0.1em',
		color: 'rgba(255,255,255,0.45)',
	},
	key: {
		display: 'inline-flex',
		alignItems: 'center',
		justifyContent: 'center',
		padding: '1px 7px',
		background: 'rgba(135, 218, 33, .1)',
		border: '1px solid rgba(135, 218, 33, .4)',
		borderRadius: 2,
		color: '#87da21',
		fontWeight: 700,
		fontSize: 11,
		letterSpacing: '0.05em',
	},
	sep: {
		width: 1,
		height: 14,
		background: 'rgba(135, 218, 33, .2)',
	},
}));

export default () => {
	const classes = useStyles();
	return (
		<div className={classes.wrapper}>
			<div className={classes.row}>
				<span className={classes.key}>Q</span>
				<span>/</span>
				<span className={classes.key}>E</span>
				<span>Rotate</span>
			</div>
			<div className={classes.sep} />
			<div className={classes.row}>
				<span className={classes.key}>Scroll</span>
				<span>Zoom</span>
			</div>
			<div className={classes.sep} />
			<div className={classes.row}>
				<span className={classes.key}>R</span>
				<span>Animation</span>
			</div>
		</div>
	);
};
