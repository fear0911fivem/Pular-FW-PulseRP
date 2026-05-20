import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';

import Nui from '../../../util/Nui';
import faceIcon from '../../../assets/srp-hud/clothing/icons/camera_face.svg';
import upperIcon from '../../../assets/srp-hud/clothing/icons/camera_upper.svg';
import lowerIcon from '../../../assets/srp-hud/clothing/icons/camera_lower.svg';

const cams = [
	{ label: 'Full', icon: upperIcon, value: 'upper' },
	{ label: 'Head', icon: faceIcon, value: 'face' },
	{ label: 'Torso', icon: upperIcon, value: 'upper' },
	{ label: 'Legs', icon: lowerIcon, value: 'lower' },
];

const useStyles = makeStyles(() => ({
	list: {
		position: 'absolute',
		left: 0,
		top: '2rem',
		transform: 'translateX(-100%)',
		display: 'flex',
		flexDirection: 'column',
		gap: '.5rem',
	},
	button: {
		borderRadius: '.5rem 0 0 .5rem',
		background: 'var(--dark-green-bg)',
		border: 0,
		transition: 'background-color .2s ease, opacity .2s ease',
		cursor: 'pointer',
		padding: '.5rem',
		width: '2.75rem',
		height: '2.75rem',
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
		'&:hover': {
			opacity: .9,
		},
	},
	active: {
		background: 'var(--green-bg)',
		boxShadow: 'inset 0 0 0 1px var(--bright-green)',
	},
	icon: {
		width: '1.5rem',
		height: '1.5rem',
		objectFit: 'contain',
	},
}));

export default function CamBar() {
	const classes = useStyles();
	const dispatch = useDispatch();
	const camera = useSelector((state) => state.app.camera);

	const setCam = async (cam) => {
		try {
			const res = await (await Nui.send('ChangeCamera', { cameraType: cams[cam].value })).json();
			if (res) {
				dispatch({ type: 'SET_CAM', payload: { cam } });
			}
		} catch (err) {}
	};

	return (
		<div className={classes.list}>
			{cams.map((cam, index) => (
				<button
					key={cam.label}
					className={`${classes.button} ${camera === index ? classes.active : ''}`}
					type="button"
					title={cam.label}
					onClick={() => setCam(index)}
				>
					<img className={classes.icon} src={cam.icon} alt="" />
				</button>
			))}
		</div>
	);
}
