import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { AppBar, Tab, Tabs } from '@mui/material';
import { makeStyles } from '@mui/styles';

import Wrapper from '../UIComponents/Wrapper/Wrapper';
import { TabPanel } from '../UIComponents';
import { Tattoo } from '../PedComponents';
import { Zones } from './Data';

const useStyles = makeStyles((theme) => ({
	count: {
		display: 'inline-flex',
		alignItems: 'center',
		gap: 6,
		marginBottom: 12,
		fontSize: 11,
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontWeight: 700,
		letterSpacing: '0.15em',
		textTransform: 'uppercase',
		color: 'rgba(255,255,255,0.4)',
		padding: '4px 10px',
		background: 'rgba(135, 218, 33, .08)',
		border: '1px solid rgba(135, 218, 33, .2)',
		borderRadius: 2,
	},
	highlight: {
		color: '#87da21',
		fontWeight: 700,
	},
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const ped = useSelector((state) => state.app.ped);
	const [value, setValue] = useState(0);

	const handleChange = (event, newValue) => setValue(newValue);

	useEffect(() => {
		dispatch({ type: 'FORCE_NEKKED', payload: { state: true } });
		return () => {
			dispatch({ type: 'FORCE_NEKKED', payload: { state: false } });
		};
	}, []);

	return (
		<Wrapper>
			<AppBar
				position="static"
				color="transparent"
				style={{ marginBottom: 15, boxShadow: 'none' }}
			>
				<Tabs
					value={value}
					onChange={handleChange}
					variant="scrollable"
					indicatorColor="primary"
					textColor="primary"
				>
					{Object.keys(Zones).map((zone) => (
						<Tab key={`tattootab-${zone}`} label={Zones[zone]} />
					))}
				</Tabs>
			</AppBar>
			<div className={classes.count}>
				<span className={classes.highlight}>{ped.customization.tattoos.length}</span>
				/
				<span className={classes.highlight}>25</span>
				Tattoos
			</div>
			{Object.keys(Zones).map((zone, k) => (
				<TabPanel key={`tattoopanel-${zone}`} value={value} index={k}>
					<Tattoo
						label={Zones[zone]}
						data={{ type: zone }}
						current={ped.customization.tattoos}
					/>
				</TabPanel>
			))}
		</Wrapper>
	);
};
