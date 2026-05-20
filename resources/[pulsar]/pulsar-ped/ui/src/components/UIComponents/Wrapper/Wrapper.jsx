import React from 'react';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		color: theme.palette.text.main,
		width: '100%',
		minHeight: 0,
		display: 'flex',
		flexDirection: 'column',
		gap: '.75rem',
		overflowX: 'hidden',
	},
}));

export default (props) => {
	const classes = useStyles();
	return <div className={classes.wrapper}>{props.children}</div>;
};
