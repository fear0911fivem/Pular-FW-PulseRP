import React from 'react';
import { makeStyles } from '@mui/styles';

import armsIcon from '../../../assets/srp-hud/clothing/icons/arms.svg';
import badgeIcon from '../../../assets/srp-hud/clothing/icons/badge.svg';
import bagIcon from '../../../assets/srp-hud/clothing/icons/bag.svg';
import beardIcon from '../../../assets/srp-hud/clothing/icons/beard.svg';
import blemishesIcon from '../../../assets/srp-hud/clothing/icons/blemishes.svg';
import braceletIcon from '../../../assets/srp-hud/clothing/icons/bracelet.svg';
import chesthairIcon from '../../../assets/srp-hud/clothing/icons/chesthair.svg';
import earringsIcon from '../../../assets/srp-hud/clothing/icons/earrings.svg';
import eyebrowsIcon from '../../../assets/srp-hud/clothing/icons/eyebrows.svg';
import faceIcon from '../../../assets/srp-hud/clothing/icons/face.svg';
import featuresIcon from '../../../assets/srp-hud/clothing/icons/features.svg';
import glassesIcon from '../../../assets/srp-hud/clothing/icons/glasses.svg';
import hairIcon from '../../../assets/srp-hud/clothing/icons/hair.svg';
import hatIcon from '../../../assets/srp-hud/clothing/icons/hat.svg';
import headIcon from '../../../assets/srp-hud/clothing/icons/head.svg';
import maskIcon from '../../../assets/srp-hud/clothing/icons/mask.svg';
import necklaceIcon from '../../../assets/srp-hud/clothing/icons/necklace.svg';
import pantsIcon from '../../../assets/srp-hud/clothing/icons/pants.svg';
import pedIcon from '../../../assets/srp-hud/clothing/icons/ped.svg';
import runwayPropsIcon from '../../../assets/srp-hud/clothing/icons/runway_props.svg';
import shirtIcon from '../../../assets/srp-hud/clothing/icons/shirt.svg';
import shoesIcon from '../../../assets/srp-hud/clothing/icons/shoes.svg';
import torsoIcon from '../../../assets/srp-hud/clothing/icons/torso.svg';
import undershirtIcon from '../../../assets/srp-hud/clothing/icons/undershirt.svg';
import vestsIcon from '../../../assets/srp-hud/clothing/icons/vests.svg';
import watchIcon from '../../../assets/srp-hud/clothing/icons/watch.svg';
import zoneHeadIcon from '../../../assets/srp-hud/clothing/icons/ZONE_HEAD.svg';
import zoneLeftArmIcon from '../../../assets/srp-hud/clothing/icons/ZONE_LEFT_ARM.svg';
import zoneLeftLegIcon from '../../../assets/srp-hud/clothing/icons/ZONE_LEFT_LEG.svg';
import zoneRightArmIcon from '../../../assets/srp-hud/clothing/icons/ZONE_RIGHT_ARM.svg';
import zoneRightLegIcon from '../../../assets/srp-hud/clothing/icons/ZONE_RIGHT_LEG.svg';
import zoneTorsoIcon from '../../../assets/srp-hud/clothing/icons/ZONE_TORSO.svg';

const icons = {
	arms: armsIcon,
	badge: badgeIcon,
	bag: bagIcon,
	beard: beardIcon,
	blemishes: blemishesIcon,
	body: torsoIcon,
	bracelet: braceletIcon,
	chesthair: chesthairIcon,
	cloth: shirtIcon,
	earrings: earringsIcon,
	eyebrows: eyebrowsIcon,
	face: faceIcon,
	features: featuresIcon,
	glasses: glassesIcon,
	hair: hairIcon,
	hat: hatIcon,
	head: headIcon,
	makeup: blemishesIcon,
	mask: maskIcon,
	necklace: necklaceIcon,
	overlays: blemishesIcon,
	pants: pantsIcon,
	ped: pedIcon,
	runway_props: runwayPropsIcon,
	shirt: shirtIcon,
	shoes: shoesIcon,
	torso: torsoIcon,
	undershirt: undershirtIcon,
	vests: vestsIcon,
	watch: watchIcon,
	ZONE_HEAD: zoneHeadIcon,
	ZONE_LEFT_ARM: zoneLeftArmIcon,
	ZONE_LEFT_LEG: zoneLeftLegIcon,
	ZONE_RIGHT_ARM: zoneRightArmIcon,
	ZONE_RIGHT_LEG: zoneRightLegIcon,
	ZONE_TORSO: zoneTorsoIcon,
	tattoo: zoneTorsoIcon,
};

const useStyles = makeStyles(() => ({
	wrapper: {
		display: 'flex',
		flexDirection: 'column',
		gap: '.75rem',
	},
	title: {
		color: '#fff',
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: '1.125rem',
		fontWeight: 400,
		lineHeight: 1,
		margin: 0,
	},
	grid: {
		display: 'grid',
		gridTemplateColumns: 'repeat(12, minmax(0, 1fr))',
		gap: '1rem',
	},
	item: {
		width: '100%',
		aspectRatio: '1',
		borderRadius: '.5rem',
		border: '1px solid transparent',
		background: 'var(--dark-green-bg)',
		transition: 'background .2s ease, border .2s ease',
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
		cursor: 'pointer',
		padding: '.625rem',
		'&:hover': {
			background: 'var(--dark-green-bg)',
			border: '1px solid hsla(0, 0%, 100%, .1)',
		},
		'&:hover img': {
			opacity: .8,
		},
	},
	active: {
		border: '1px solid var(--bright-green)',
		background: 'var(--green-bg)',
		cursor: 'default',
		'&:hover': {
			border: '1px solid var(--bright-green)',
			background: 'var(--green-bg)',
		},
	},
	icon: {
		maxWidth: '1.65rem',
		maxHeight: '1.65rem',
		objectFit: 'contain',
		transition: 'opacity .2s ease',
	},
}));

export default function HudTabs({ label = 'Categories', items, value, onChange }) {
	const classes = useStyles();

	return (
		<div className={classes.wrapper}>
			<h4 className={classes.title}>{label}</h4>
			<div className={classes.grid}>
				{items.map((item, index) => (
					<button
						key={item.name || item.label}
						className={`${classes.item} ${value === index ? classes.active : ''}`}
						type="button"
						title={item.label}
						onClick={() => onChange(index)}
					>
						<img className={classes.icon} src={icons[item.icon || item.name] || icons.face} alt="" />
					</button>
				))}
			</div>
		</div>
	);
}
