import React, { useState } from 'react';
import { Grid, Slider as MSlider, Tooltip } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { useDispatch } from 'react-redux';

import Nui from '../../../util/Nui';

const useStyles = makeStyles(() => ({
	div: {
		width: '100%',
		display: 'flex',
		alignItems: 'center',
		gap: '1rem',
		userSelect: 'none',
		color: '#ffffff',
	},
	label: {
		width: '10rem',
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: '1.5rem',
		textTransform: 'uppercase',
		textAlign: 'left',
		lineHeight: 1,
	},
	slider: {
		width: '100%',
		color: '#87da21',
		'& .MuiSlider-rail': {
			backgroundColor: 'hsla(0, 0%, 100%, .15)',
			opacity: 1,
			height: 4,
		},
		'& .MuiSlider-track': {
			backgroundColor: '#87da21',
			border: 'none',
			height: 4,
			boxShadow: '0 4px 16px rgba(135, 218, 33, .35)',
		},
		'& .MuiSlider-thumb': {
			width: 14,
			height: 14,
			backgroundColor: '#9eff00',
			boxShadow: '0 4px 16px rgba(135, 218, 33, .35)',
		},
	},
}));

function ValueLabelComponent(props) {
	const { children, open, value } = props;
	return (
		<Tooltip open={open} enterTouchDelay={0} placement="top" title={value}>
			{children}
		</Tooltip>
	);
}

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const [currentValue, setCurrentValue] = useState(props.current);

	const onChange = (event, newValue) => {
		if (!props.disabled) {
			setCurrentValue(newValue);
			dispatch(props.event(currentValue, props.data));
		}
	};

	const style = props.disabled ? { opacity: 0.4 } : {};

	return (
		<div className={classes.div} style={style}>
			<span className={classes.label}>{props.label}</span>
			<MSlider
				className={classes.slider}
				onChange={onChange}
				components={{ ValueLabel: ValueLabelComponent }}
				defaultValue={0}
				value={currentValue}
				disabled={props.disabled}
				step={1}
				min={props.min}
				max={props.max}
				component="div"
			/>
		</div>
	);
};
