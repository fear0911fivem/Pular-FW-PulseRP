import React from 'react';
import { makeStyles } from '@mui/styles';
import { useDispatch } from 'react-redux';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../../util/Nui';

const useStyles = makeStyles(() => ({
	row: {
		width: '100%',
		display: 'flex',
		alignItems: 'center',
		gap: '.75rem',
		lineHeight: '100%',
		opacity: 1,
	},
	disabled: {
		opacity: .5,
		pointerEvents: 'none',
	},
	name: {
		color: '#fff',
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: '1.5rem',
		fontWeight: 400,
		textTransform: 'uppercase',
		minWidth: '10rem',
		textAlign: 'left',
	},
	avail: {
		color: 'hsla(0, 0%, 100%, .5)',
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: '1.125rem',
		marginRight: 'auto',
	},
	wheel: {
		color: '#fff',
		border: '1px solid hsla(0, 0%, 100%, .15)',
		borderRadius: '.5rem',
		overflow: 'hidden',
		width: 'fit-content',
		display: 'flex',
		alignItems: 'center',
		background: 'var(--black)',
	},
	field: {
		width: '1.75rem',
		padding: '.75rem 0',
		cursor: 'pointer',
		transition: 'background-color .1s ease',
		userSelect: 'none',
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
		lineHeight: '100%',
		color: 'hsla(0, 0%, 100%, .5)',
		background: 'transparent',
		border: 0,
		'&:hover': {
			background: 'var(--black-hover)',
			color: '#fff',
		},
	},
	value: {
		display: 'flex',
		width: '2rem',
		height: '100%',
	},
	input: {
		background: 'transparent',
		color: '#fff',
		width: '100%',
		height: '100%',
		border: 'none',
		textAlign: 'center',
		fontWeight: 700,
		fontFamily: "'Bai Jamjuree', sans-serif",
		'&:focus': {
			outline: 'none',
		},
		'&::-webkit-inner-spin-button, &::-webkit-outer-spin-button': {
			appearance: 'none',
		},
	},
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const min = props.min ?? 0;
	const max = props.max;

	const sendValue = (value) => {
		Nui.send('FrontEndSound', { sound: 'UPDOWN' });
		if (Boolean(props.onChange)) {
			props.onChange(value, props.data);
		} else {
			dispatch(props.event(value, props.data));
		}
	};

	const onUp = () => {
		if (props.disabled) return;
		sendValue(props.current + 1 > max ? min : props.current + 1);
	};

	const onDown = () => {
		if (props.disabled) return;
		sendValue(props.current - 1 < min ? max : props.current - 1);
	};

	const updateIndex = (event) => {
		let value = parseInt(event.target.value, 10);
		if (Number.isNaN(value) || props.disabled) return;
		if (value > max) value = max;
		if (value < min) value = min;
		sendValue(value);
	};

	return (
		<div className={`${classes.row} ${props.disabled ? classes.disabled : ''}`}>
			<div className={classes.name}>{props.label}</div>
			<div className={classes.avail}>{props.current} / {max}</div>
			<div className={classes.wheel}>
				<button className={classes.field} type="button" onClick={onDown}>
					<FontAwesomeIcon icon={['fas', 'chevron-left']} />
				</button>
				<div className={classes.value}>
					<input
						className={classes.input}
						value={props.current}
						onChange={updateIndex}
						type="number"
						min={min}
						max={max}
						step={1}
					/>
				</div>
				<button className={classes.field} type="button" onClick={onUp}>
					<FontAwesomeIcon icon={['fas', 'chevron-right']} />
				</button>
			</div>
		</div>
	);
};
