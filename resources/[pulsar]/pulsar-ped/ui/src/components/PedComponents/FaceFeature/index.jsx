import React from 'react';
import { makeStyles } from '@mui/styles';

import { Slider } from '../../UIComponents';
import { SetPedFaceFeature } from '../../../actions/pedActions';
import ElementBox from '../../UIComponents/ElementBox/ElementBox';

const useStyles = makeStyles(() => ({
	body: {
		display: 'grid',
		gap: '.75rem',
		gridTemplateColumns: 'repeat(2, minmax(0, 1fr))',
	},
}));

export default (props) => {
	const classes = useStyles();

	const elements = props.data.items.map((item, i) => (
		<Slider
			key={i}
			label={item.label}
			event={SetPedFaceFeature}
			data={{ index: item.index }}
			current={item.current}
			min={-100}
			max={100}
		/>
	));

	return (
		<ElementBox label={props.label} bodyClass={classes.body}>
			{elements}
		</ElementBox>
	);
};
