import React from 'react';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles(() => ({
	header: {
		color: '#fff',
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: '2rem',
		fontWeight: 400,
		lineHeight: 1,
		display: 'flex',
		justifyContent: 'space-between',
		alignItems: 'center',
		textTransform: 'uppercase',
	},
}));

export default function PanelHeader({ label = 'Clothing Shop' }) {
	const classes = useStyles();

	return (
		<div className={classes.header}>
			<span>{label}</span>
		</div>
	);
}
