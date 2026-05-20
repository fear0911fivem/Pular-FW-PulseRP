import React from 'react';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles((theme) => ({
	inner: {
		padding: '1.25rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		alignItems: 'center',
		gap: '.75rem',
		lineHeight: '100%',
		color: '#fff',
	},
	header: {
		color: '#fff',
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: '1.5rem',
		fontWeight: 400,
		textTransform: 'uppercase',
		whiteSpace: 'nowrap',
		width: '10rem',
		flexShrink: 0,
	},
	headerText: {
		maxWidth: '100%',
		overflow: 'hidden',
		textOverflow: 'ellipsis',
	},
	body: {
		flex: 1,
		minWidth: 0,
	},
}));

export default (props) => {
	const classes = useStyles();
	return (
		<div className={classes.inner}>
			{Boolean(props.label) && (
				<div className={classes.header}>
					<span className={classes.headerText}>{props.label}</span>
				</div>
			)}
			<div className={`${classes.body} ${props.bodyClass || ''}`}>{props.children}</div>
		</div>
	);
};
