import React from 'react';
import { Box } from '@mui/material';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles(() => ({
	tabPanel: {
		width: '100%',
		minHeight: 0,
		overflow: 'visible',
	},
}));

export default ({ children, value, index, ...other }) => {
	const classes = useStyles();

	if (value !== index) return null;
	return (
		<Box className={classes.tabPanel} p={0}>
			{children}
		</Box>
	);
};
