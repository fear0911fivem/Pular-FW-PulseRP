import React from 'react';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../../util/Nui';
import { Ticker } from '../../UIComponents';
import { connect, useDispatch, useSelector } from 'react-redux';
import ElementBox from '../../UIComponents/ElementBox/ElementBox';
import { Button, IconButton } from '@mui/material';

const useStyles = makeStyles(() => ({
	body: {
		display: 'grid',
		gap: '.75rem',
		gridTemplateColumns: 'minmax(0, 1fr) auto',
		alignItems: 'stretch',
	},
	del: {
		height: 'fit-content',
		width: 'fit-content',
		position: 'absolute',
		top: 0,
		bottom: 0,
		left: 0,
		right: 0,
		margin: 'auto',
		color: 'rgba(161,52,52,0.8)',
		'&:hover': { color: '#a13434' },
	},
	add: {
		marginBottom: 12,
		padding: '6px 0',
		borderRadius: 2,
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: 11,
		fontWeight: 700,
		letterSpacing: '0.15em',
		textTransform: 'uppercase',
		color: '#87da21',
		borderColor: 'rgba(135, 218, 33, .4)',
		'&:hover': {
			borderColor: '#87da21',
			background: 'rgba(135, 218, 33, .08)',
		},
		'&.Mui-disabled': {
			color: 'rgba(135, 218, 33, .3)',
			borderColor: 'rgba(135, 218, 33, .15)',
		},
	},
}));

export default connect()((props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const Tattoos = useSelector((state) => state.app.tattoos);
	const tattoos = Tattoos?.filter((t) => t.Zone == props.data.type && Boolean(t));

	const onAdd = () => {
		if (props.current.length >= 25) return;
		let payload = { type: props.data.type };
		Nui.send('AddPedTattoo', payload);
		dispatch({ type: 'ADD_PED_TATTOO', payload });
	};

	const onChange = (value, data, index) => {
		return (d) => {
			if (!Boolean(value) || !Boolean(tattoos[value])) return;
			let payload = { type: props.data.type, data: tattoos[value], index };
			Nui.send('SetPedTattoo', payload);
			d({ type: 'UPDATE_PED_TATTOO', payload });
		};
	};

	const onDelete = (index) => {
		let payload = { type: props.data.type, index };
		Nui.send('RemovePedTattoo', payload);
		dispatch({ type: 'REMOVE_PED_TATTOO', payload });
	};

	return (
		<>
			<Button
				fullWidth
				variant="outlined"
				className={classes.add}
				onClick={onAdd}
				disabled={props.current.length >= 25}
				startIcon={<FontAwesomeIcon icon={['fas', 'plus']} style={{ fontSize: 10 }} />}
			>
				Add {props.label} Tattoo
			</Button>

			{props.current.map((tattoo, k) => {
				if (tattoo.Zone != props.data.type) return null;
				try {
					let curr = tattoo?.Name == ''
						? 0
						: tattoos.findIndex((t) => t?.Name == tattoo?.Name);

					return (
						<ElementBox key={`tat-${k}`} label={`Tattoo #${k + 1}`} bodyClass={classes.body}>
							<Ticker
								label={'Type'}
								event={(v, d) => onChange(v, d, k)}
								data={{ ...props.data, extraType: 'index' }}
								current={curr}
								min={0}
								max={tattoos.length - 1}
							/>
							<div style={{ position: 'relative' }}>
								<IconButton className={classes.del} onClick={() => onDelete(k)}>
									<FontAwesomeIcon icon={['fas', 'trash']} style={{ fontSize: 13 }} />
								</IconButton>
							</div>
						</ElementBox>
					);
				} catch (err) {
					return null;
				}
			})}
		</>
	);
});
