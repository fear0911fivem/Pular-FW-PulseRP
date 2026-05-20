import ElementBox from '../../UIComponents/ElementBox/ElementBox';
import React from 'react';
import { makeStyles } from '@mui/styles';
import { SetPedEyeColor } from '../../../actions/pedActions';
import { useDispatch } from 'react-redux';
import Nui from '../../../util/Nui';

const eyeContext = require.context(
	'../../../assets/srp-hud/clothing/eyes',
	false,
	/\.png$/,
);

const eyeImages = Array.from({ length: 32 }, (_, index) => {
	const fileName = `./eyeball-${String(index + 1).padStart(2, '0')}.png`;
	const image = eyeContext(fileName);
	return image.default || image;
});

const useStyles = makeStyles(() => ({
	body: {
		display: 'grid',
		gap: '.75rem',
	},
	grid: {
		display: 'grid',
		gridTemplateColumns: 'repeat(8, minmax(0, 1fr))',
		gap: '.5rem',
	},
	option: {
		aspectRatio: '1',
		borderRadius: '.5rem',
		border: '1px solid transparent',
		background: 'var(--black)',
		cursor: 'pointer',
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
		padding: '.25rem',
		transition: 'background .2s ease, border .2s ease',
		'&:hover': {
			background: 'var(--black-hover)',
			borderColor: 'hsla(0, 0%, 100%, .12)',
		},
	},
	active: {
		background: 'var(--green-bg)',
		borderColor: 'var(--bright-green)',
	},
	image: {
		width: '100%',
		height: '100%',
		objectFit: 'contain',
	},
}));

const EyeColors = [
	'Green',
	'Emerald',
	'Light Blue',
	'Ocean Blue',
	'Light Brown',
	'Dark Brown',
	'Hazel',
	'Dark Gray',
	'Light Gray',
	'Pink',
	'Yellow',
	'Purple',
	'Blackout',
	'Shades of Gray',
	'Tequila Sunrise',
	'Atomic',
	'Warp',
	'ECola',
	'Space Ranger',
	'Ying Yang',
	'Bullseye',
	'Lizard',
	'Dragon',
	'Extra Terrestrial',
	'Goat',
	'Smiley',
	'Possessed',
	'Demon',
	'Infected',
	'Alien',
	'Undead',
	'Zombie',
];

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();

	const onSelect = (index) => {
		Nui.send('FrontEndSound', { sound: 'SELECT' });
		dispatch(SetPedEyeColor(index, { type: 'drawableId', name: props.name }));
	};

	return (
		<ElementBox label={props.label} bodyClass={classes.body}>
			<div className={classes.grid}>
				{EyeColors.map((label, index) => (
					<button
						key={label}
						className={`${classes.option} ${props.component === index ? classes.active : ''}`}
						type="button"
						title={label}
						onClick={() => onSelect(index)}
						disabled={props.disabled}
					>
						<img className={classes.image} src={eyeImages[index]} alt="" />
					</button>
				))}
			</div>
		</ElementBox>
	);
};
