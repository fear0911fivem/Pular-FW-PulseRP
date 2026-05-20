import React, { useEffect, useMemo, useRef, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../util/Nui';
import {
	CancelEdits,
	SetPedComponentVariation,
	SetPedEyeColor,
	SetPedFaceFeature,
	SetPedHairColor,
	SetPedHeadBlendData,
	SetPedHeadOverlay,
	SetPedPropIndex,
} from '../../actions/pedActions';
import PedModels from './Ped/peds';

import clothingMaps from '../../assets/srp-hud/clothing/maps/freemode.json';
import armsIcon from '../../assets/srp-hud/clothing/icons/arms.svg';
import badgeIcon from '../../assets/srp-hud/clothing/icons/badge.svg';
import bagIcon from '../../assets/srp-hud/clothing/icons/bag.svg';
import beardIcon from '../../assets/srp-hud/clothing/icons/beard.svg';
import blemishesIcon from '../../assets/srp-hud/clothing/icons/blemishes.svg';
import braceletIcon from '../../assets/srp-hud/clothing/icons/bracelet.svg';
import cameraFaceIcon from '../../assets/srp-hud/clothing/icons/camera_face.svg';
import cameraLowerIcon from '../../assets/srp-hud/clothing/icons/camera_lower.svg';
import cameraShoesIcon from '../../assets/srp-hud/clothing/icons/camera_shoes.svg';
import cameraUpperIcon from '../../assets/srp-hud/clothing/icons/camera_upper.svg';
import chesthairIcon from '../../assets/srp-hud/clothing/icons/chesthair.svg';
import earringsIcon from '../../assets/srp-hud/clothing/icons/earrings.svg';
import eyebrowsIcon from '../../assets/srp-hud/clothing/icons/eyebrows.svg';
import faceIcon from '../../assets/srp-hud/clothing/icons/face.svg';
import featuresIcon from '../../assets/srp-hud/clothing/icons/features.svg';
import glassesIcon from '../../assets/srp-hud/clothing/icons/glasses.svg';
import hairIcon from '../../assets/srp-hud/clothing/icons/hair.svg';
import hatIcon from '../../assets/srp-hud/clothing/icons/hat.svg';
import headIcon from '../../assets/srp-hud/clothing/icons/head.svg';
import maskIcon from '../../assets/srp-hud/clothing/icons/mask.svg';
import necklaceIcon from '../../assets/srp-hud/clothing/icons/necklace.svg';
import pantsIcon from '../../assets/srp-hud/clothing/icons/pants.svg';
import pedIcon from '../../assets/srp-hud/clothing/icons/ped.svg';
import shirtIcon from '../../assets/srp-hud/clothing/icons/shirt.svg';
import shoesIcon from '../../assets/srp-hud/clothing/icons/shoes.svg';
import torsoIcon from '../../assets/srp-hud/clothing/icons/torso.svg';
import undershirtIcon from '../../assets/srp-hud/clothing/icons/undershirt.svg';
import vestsIcon from '../../assets/srp-hud/clothing/icons/vests.svg';
import watchIcon from '../../assets/srp-hud/clothing/icons/watch.svg';
import zoneHeadIcon from '../../assets/srp-hud/clothing/icons/ZONE_HEAD.svg';
import zoneLeftArmIcon from '../../assets/srp-hud/clothing/icons/ZONE_LEFT_ARM.svg';
import zoneLeftLegIcon from '../../assets/srp-hud/clothing/icons/ZONE_LEFT_LEG.svg';
import zoneRightArmIcon from '../../assets/srp-hud/clothing/icons/ZONE_RIGHT_ARM.svg';
import zoneRightLegIcon from '../../assets/srp-hud/clothing/icons/ZONE_RIGHT_LEG.svg';
import zoneTorsoIcon from '../../assets/srp-hud/clothing/icons/ZONE_TORSO.svg';

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

const lipsIcon = {
	prefix: 'fas',
	iconName: 'lips',
	icon: [
		576,
		512,
		[128068, 128482],
		'f600',
		'M288 101.3c3-2.4 6.2-4.8 9.7-7.3c17.8-12.7 46.8-30 78.3-30c20.3 0 42.8 9.3 61.4 19.2c20 10.6 41.1 24.7 60.2 39.5c19.1 14.8 37.1 31.2 50.8 46.5c6.8 7.6 13.1 15.7 17.9 23.7c4.3 7.2 9.7 18.3 9.7 31c0 9.2-2.6 19.1-5.3 27.5c-3 9.1-7.4 19.4-12.8 30.3c-10.8 21.7-26.8 46.9-47.7 71.1C468.8 400.9 404.7 448 320 448h-64c-84.7 0-148.8-47.1-190.2-95.1C44.9 328.8 29 303.5 18.1 281.8C12.7 271 8.4 260.7 5.3 251.5C2.6 243.1 0 233.2 0 224c0-12.8 5.5-23.8 9.7-31c4.8-8.1 11.1-16.1 17.9-23.7c13.6-15.3 31.7-31.7 50.8-46.5c19.1-14.9 40.2-29 60.2-39.5C157.2 73.3 179.7 64 200 64c31.5 0 60.6 17.2 78.3 30c3.4 2.5 6.7 4.9 9.7 7.3zM64 224c0 7.9 80 96 224 96s224-88.1 224-96c0-7.7-46.3-31.1-138.8-32c-3.4 0-6.9 .5-10.1 1.5C350 197.6 313.7 208 288 208s-62-10.4-75.1-14.4c-3.3-1-6.7-1.6-10.1-1.5C110.3 192.9 64 216.3 64 224z',
	],
};

const clothingItems = [
	{ name: 'shirt', label: 'Shirt', icon: 'shirt', type: 'component', componentKey: 'torso2' },
	{ name: 'undershirt', label: 'Undershirt', icon: 'undershirt', type: 'component', componentKey: 'undershirt' },
	{ name: 'arms', label: 'Arms', icon: 'arms', type: 'component', componentKey: 'torso' },
	{ name: 'vests', label: 'Vests', icon: 'vests', type: 'component', componentKey: 'kevlar' },
	{ name: 'pants', label: 'Pants', icon: 'pants', type: 'component', componentKey: 'leg' },
	{ name: 'shoes', label: 'Shoes', icon: 'shoes', type: 'component', componentKey: 'shoes' },
	{ name: 'glasses', label: 'Glasses', icon: 'glasses', type: 'prop', propKey: 'glass' },
	{ name: 'earrings', label: 'Earrings', icon: 'earrings', type: 'prop', propKey: 'ear' },
	{ name: 'watch', label: 'Watch', icon: 'watch', type: 'prop', propKey: 'watch' },
	{ name: 'bracelet', label: 'Bracelet', icon: 'bracelet', type: 'prop', propKey: 'bracelet' },
	{ name: 'mask', label: 'Mask', icon: 'mask', type: 'component', componentKey: 'mask' },
	{ name: 'bag', label: 'Bag', icon: 'bag', type: 'component', componentKey: 'bag' },
	{ name: 'necklace', label: 'Accessories', icon: 'necklace', type: 'component', componentKey: 'accessory' },
	{ name: 'hat', label: 'Hat', icon: 'hat', type: 'prop', propKey: 'hat' },
	{ name: 'badge', label: 'Badge', icon: 'badge', type: 'component', componentKey: 'badge', showPhotos: false },
];

const categoryDefs = {
	face: {
		name: 'face',
		label: 'Face',
		icon: 'face',
		items: [
			{ name: 'face', label: 'Face', icon: 'face' },
			{ name: 'features', label: 'Face Features', icon: 'features' },
			{ name: 'overlays', label: 'Face Overlays', faIcon: ['far', 'face-flushed'] },
			{ name: 'makeup', label: 'Makeup', faIcon: lipsIcon },
		],
	},
	hair: {
		name: 'hair',
		label: 'Hair',
		icon: 'hair',
		items: [
			{ name: 'hair', label: 'Hair', icon: 'hair', type: 'component', componentKey: 'hair', colorName: 'hair' },
			{ name: 'beard', label: 'Beard', icon: 'beard' },
			{ name: 'eyebrows', label: 'Eyebrows', icon: 'eyebrows' },
			{ name: 'chesthair', label: 'Chest Hair', icon: 'chesthair' },
		],
	},
	cloth: {
		name: 'cloth',
		label: 'Clothes',
		icon: 'shirt',
		items: clothingItems,
	},
	body: {
		name: 'body',
		label: 'Body',
		icon: 'torso',
		items: [
			{ name: 'blemishes', label: 'Body Blemishes', icon: 'blemishes' },
		],
	},
	tattoo: {
		name: 'tattoo',
		label: 'Tattoos',
		icon: 'ZONE_TORSO',
		items: [
			{ name: 'ZONE_TORSO', label: 'Torso Tattoos', icon: 'ZONE_TORSO' },
			{ name: 'ZONE_HEAD', label: 'Head Tattoos', icon: 'ZONE_HEAD' },
			{ name: 'ZONE_LEFT_ARM', label: 'Left Arm Tattoos', icon: 'ZONE_LEFT_ARM' },
			{ name: 'ZONE_RIGHT_ARM', label: 'Right Arm Tattoos', icon: 'ZONE_RIGHT_ARM' },
			{ name: 'ZONE_LEFT_LEG', label: 'Left Leg Tattoos', icon: 'ZONE_LEFT_LEG' },
			{ name: 'ZONE_RIGHT_LEG', label: 'Right Leg Tattoos', icon: 'ZONE_RIGHT_LEG' },
		],
	},
	ped: {
		name: 'ped',
		label: 'Ped',
		icon: 'ped',
		items: [
			{ name: 'ped', label: 'Ped Selector', icon: 'ped' },
		],
	},
};

const modeCategories = {
	creator: ['face', 'hair', 'cloth', 'body', 'tattoo', 'ped'],
	clothing: ['cloth'],
	barber: ['face', 'hair', 'body'],
	surgery: ['face', 'hair', 'body'],
	tattoo: ['tattoo'],
};

const faceCounts = {
	face1: 92,
	face2: 92,
	face3: 46,
};

const overlayDefs = {
	ageing: { type: 'ageing', id: 3, label: 'Ageing', max: 14 },
	freckles: { type: 'freckles', id: 9, label: 'Moles / Freckles', max: 10 },
	complexion: { type: 'complexion', id: 6, label: 'Complexion', max: 11 },
	blemish: { type: 'blemish', id: 0, label: 'Blemishes', max: 23 },
	sundamage: { type: 'sundamage', id: 7, label: 'Sun Damage', max: 10 },
	blush: { type: 'blush', id: 5, label: 'Blush', max: 6, colorType: 'makeup' },
	lipstick: { type: 'lipstick', id: 8, label: 'Lipstick', max: 9, colorType: 'makeup' },
	makeup: { type: 'makeup', id: 4, label: 'Makeup', max: 74, colorType: 'makeup_both' },
	facialhair: { type: 'facialhair', id: 1, label: 'Facial Hair', max: 28, colorType: 'hair_both', colorName: 'facialhair' },
	eyebrows: { type: 'eyebrows', id: 2, label: 'Eyebrows', max: 28, colorType: 'hair_both', colorName: 'eyebrows' },
	chesthair: { type: 'chesthair', id: 10, label: 'Chest Hair', max: 16, colorType: 'hair', colorName: 'chesthair' },
	bodyblemish: { type: 'bodyblemish', id: 11, label: 'Body Blemishes', max: 10 },
	addbodyblemish: { type: 'addbodyblemish', id: 12, label: 'Additional Body Blemishes', max: 1 },
};

const faceOverlayOrder = ['ageing', 'freckles', 'complexion', 'blemish', 'sundamage'];
const makeupOverlayOrder = ['blush', 'lipstick', 'makeup'];
const bodyOverlayOrder = ['chesthair', 'bodyblemish', 'addbodyblemish'];

const faceFeatureLabels = [
	'Width',
	'Peak Height',
	'Peak Length',
	'Bone Height',
	'Peak Lowering',
	'Bone Twist',
	'Height',
	'Length',
	'Bone Height',
	'Bone Width',
	'Width',
	'Eye Opening',
	'Lip Thickness',
	'Jaw Width',
	'Jaw Length',
	'Chin Height',
	'Chin Length',
	'Chin Width',
	'Chin Dimple',
	'Neck Thickness',
];

const faceFeatureGroups = [
	{ label: 'Nose', indexes: [0, 1, 2, 3, 4, 5] },
	{ label: 'Eyebrows', indexes: [6, 7] },
	{ label: 'Cheek Bones', indexes: [8, 9, 10] },
	{ label: 'Jaw and Chin', indexes: [13, 14, 15, 16, 17, 18] },
	{ label: 'Other', indexes: [11, 12, 19] },
];

const eyeColorLabels = [
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

const eyeContext = require.context(
	'../../assets/srp-hud/clothing/eyes',
	false,
	/\.png$/,
);

const eyeImages = Array.from({ length: 32 }, (_, index) => {
	const fileName = `./eyeball-${String(index + 1).padStart(2, '0')}.png`;
	const image = eyeContext(fileName);
	return image.default || image;
});

const hairColors = [
	[28, 31, 33], [39, 42, 44], [49, 46, 44], [53, 38, 28], [75, 50, 31], [92, 59, 36], [109, 76, 53], [107, 80, 59],
	[118, 92, 69], [127, 104, 78], [153, 129, 93], [167, 147, 105], [175, 156, 112], [187, 160, 99], [214, 185, 123], [218, 195, 142],
	[159, 127, 89], [132, 80, 57], [104, 43, 31], [97, 18, 12], [100, 15, 10], [124, 20, 15], [160, 46, 25], [182, 75, 40],
	[162, 80, 47], [170, 78, 43], [98, 98, 98], [128, 128, 128], [170, 170, 170], [197, 197, 197], [70, 57, 85], [90, 63, 107],
];

const makeupColors = [
	[13, 17, 20], [28, 31, 33], [39, 42, 44], [49, 46, 44], [53, 38, 28], [75, 50, 31], [92, 59, 36], [109, 76, 53],
	[107, 80, 59], [118, 92, 69], [127, 104, 78], [153, 129, 93], [167, 147, 105], [175, 156, 112], [187, 160, 99], [214, 185, 123],
	[218, 195, 142], [159, 127, 89], [132, 80, 57], [104, 43, 31], [97, 18, 12], [100, 15, 10], [124, 20, 15], [160, 46, 25],
	[182, 75, 40], [162, 80, 47], [170, 78, 43], [98, 98, 98], [128, 128, 128], [170, 170, 170], [197, 197, 197], [70, 57, 85],
	[90, 63, 107], [118, 60, 118], [237, 116, 227], [235, 75, 147], [242, 153, 188], [4, 149, 158], [2, 95, 134], [2, 57, 116],
	[63, 161, 106], [33, 124, 97], [24, 92, 85], [182, 192, 52], [112, 169, 11], [67, 157, 19], [220, 184, 87], [229, 177, 3],
	[230, 145, 2], [242, 136, 49], [251, 128, 87], [226, 139, 88], [209, 89, 60], [206, 49, 32], [173, 9, 3], [136, 3, 2],
	[31, 24, 20], [41, 31, 25], [46, 34, 27], [55, 41, 30], [46, 33, 24], [35, 24, 18], [2, 2, 2], [112, 108, 102],
];

const cameraButtons = [
	{ key: 'face', icon: cameraFaceIcon, value: 'face' },
	{ key: 'upper', icon: cameraUpperIcon, value: 'upper' },
	{ key: 'lower', icon: cameraLowerIcon, value: 'lower' },
	{ key: 'shoes', icon: cameraShoesIcon, value: 'shoes' },
];

const undressItems = [
	{ key: 'head', icon: headIcon },
	{ key: 'torso', icon: torsoIcon },
	{ key: 'pants', icon: pantsIcon },
	{ key: 'shoes', icon: shoesIcon },
];

const emptyUndressState = {
	head: false,
	torso: false,
	pants: false,
	shoes: false,
};

const fullUndressState = {
	head: true,
	torso: true,
	pants: true,
	shoes: true,
};

const hasUndressedParts = (state) => Object.values(state || {}).some(Boolean);

const useStyles = makeStyles(() => ({
	root: {
		position: 'fixed',
		inset: 0,
		color: '#fff',
		fontFamily: "'Bai Jamjuree', sans-serif",
		pointerEvents: 'none',
		'--green-bg': '#425c2c',
		'--dark-green-bg': 'rgba(26, 31, 20, 0.85)',
		'--black': 'rgba(0, 0, 0, 0.5)',
		'--black-hover': 'rgba(0, 0, 0, 0.75)',
		'--bright-green': '#9eff00',
	},
	cameraMouseLayer: {
		position: 'fixed',
		inset: 0,
		zIndex: 0,
		pointerEvents: 'auto',
	},
	menuWrapper: {
		position: 'absolute',
		color: '#fff',
		top: '3.5rem',
		right: '5rem',
		zIndex: 2,
		width: '48rem',
		height: 'calc(100% - 7rem)',
		transform: 'none',
		transformOrigin: 'right center',
		display: 'flex',
		flexDirection: 'column',
		gap: '1.5rem',
		pointerEvents: 'auto',
	},
	title: {
		fontSize: '2rem',
		display: 'flex',
		justifyContent: 'space-between',
		alignItems: 'center',
	},
	close: {
		width: '3rem',
		height: '3rem',
		flexShrink: 0,
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
		border: '1px solid hsla(0,0%,100%,.25)',
		borderRadius: '.25rem',
		background: 'rgba(0,0,0,.5)',
		color: '#fff',
		cursor: 'pointer',
		'& svg': {
			width: '1.5rem',
			height: '1.5rem',
		},
		'&:hover': {
			background: 'rgba(0,0,0,.75)',
		},
	},
	topNav: {
		display: 'flex',
		alignItems: 'center',
		gap: '1.35rem',
		minWidth: 0,
		flex: 1,
		textTransform: 'uppercase',
	},
	topButton: {
		border: 0,
		background: 'transparent',
		color: 'hsla(0,0%,100%,.5)',
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: '1.75rem',
		fontWeight: 400,
		lineHeight: 1,
		padding: 0,
		whiteSpace: 'nowrap',
		textTransform: 'uppercase',
		cursor: 'pointer',
		borderBottom: '1px solid transparent',
		'&.active': {
			color: '#fff',
			borderBottomColor: 'var(--green-active)',
		},
	},
	side: {
		display: 'flex',
		flexDirection: 'column',
		gap: '.75rem',
	},
	sideTitle: {
		margin: 0,
		fontSize: '1.125rem',
		fontWeight: 400,
		lineHeight: 1,
		textTransform: 'uppercase',
		textShadow: '0 0 16px rgba(0,0,0,.75)',
	},
	iconGrid: {
		display: 'grid',
		gridTemplateColumns: 'repeat(12, minmax(0, 1fr))',
		gridGap: '1rem',
	},
	iconButton: {
		width: '100%',
		aspectRatio: '1',
		borderRadius: '.5rem',
		border: '1px solid transparent',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
		cursor: 'pointer',
		padding: '.625rem',
		transition: 'background .2s ease, border .2s ease',
		'& img, & svg': {
			maxWidth: '1.5rem',
			maxHeight: '1.5rem',
			objectFit: 'contain',
			transition: 'all .2s ease',
			color: '#fff',
		},
		'&:hover': {
			background: 'var(--dark-green-bg)',
			border: '1px solid hsla(0, 0%, 100%, .1)',
			'& img, & svg': {
				opacity: .8,
			},
		},
		'&.active': {
			border: '1px solid var(--bright-green)',
			background: 'var(--green-bg)',
			cursor: 'unset',
		},
	},
	content: {
		flex: '1 1 0',
		display: 'flex',
		flexDirection: 'column',
		gap: '1.5rem',
		minHeight: 0,
		overflow: 'hidden',
	},
	scrollContent: {
		minHeight: 0,
		overflowY: 'auto',
		overflowX: 'hidden',
		padding: '1rem 1rem 1rem 0',
		margin: '-1rem -1rem -1rem 0',
		WebkitMask: 'linear-gradient(180deg, transparent 0, #fff 1rem, #fff calc(100% - 1rem), transparent)',
	},
	componentScreen: {
		display: 'flex',
		flexDirection: 'column',
		gap: '1.5rem',
		minHeight: 0,
	},
	selectorRow: {
		display: 'grid',
		gridTemplateColumns: 'repeat(2, minmax(0, 1fr))',
		gap: '.75rem',
	},
	selectorPart: {
		minHeight: '5.25rem',
		padding: '1.25rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		alignItems: 'center',
		gap: '.75rem',
		lineHeight: '100%',
	},
	selectorName: {
		margin: 0,
		fontSize: '1.5rem',
		fontWeight: 400,
		textTransform: 'uppercase',
		whiteSpace: 'nowrap',
	},
	selectorAvail: {
		margin: 0,
		color: 'hsla(0,0%,100%,.5)',
		fontSize: '1.125rem',
		fontWeight: 400,
		textTransform: 'uppercase',
		whiteSpace: 'nowrap',
	},
	numberWheel: {
		marginLeft: 'auto',
		display: 'flex',
		alignItems: 'center',
		border: '1px solid hsla(0, 0%, 100%, .15)',
		borderRadius: '.5rem',
		overflow: 'hidden',
		background: 'var(--black)',
		height: '2.25rem',
		width: 'fit-content',
	},
	wheelButton: {
		width: '1.75rem',
		height: '100%',
		border: 0,
		background: 'transparent',
		color: 'hsla(0,0%,100%,.5)',
		fontSize: '.75rem',
		fontFamily: "'Bai Jamjuree', sans-serif",
		cursor: 'pointer',
		padding: 0,
		'&:hover': {
			background: 'var(--black-hover)',
			color: '#fff',
		},
	},
	wheelValue: {
		width: '2rem',
		textAlign: 'center',
		fontWeight: 700,
		fontSize: '1rem',
	},
	propToggle: {
		width: '1.2rem',
		height: '1.2rem',
		border: '2px solid rgba(255,255,255,.55)',
		borderRadius: '.15rem',
		background: 'transparent',
		cursor: 'pointer',
		flex: '0 0 auto',
		'&.active': {
			background: '#87da21',
			borderColor: '#87da21',
		},
	},
	photoWrap: {
		position: 'relative',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		padding: '2rem 1.5rem',
		height: '22rem',
		maxHeight: '22rem',
		minHeight: 0,
		flexShrink: 0,
		display: 'flex',
	},
	cameraList: {
		position: 'absolute',
		left: 0,
		top: '2rem',
		transform: 'translateX(-100%)',
		display: 'flex',
		flexDirection: 'column',
		gap: '.5rem',
	},
	cameraButton: {
		border: 0,
		borderRadius: '.5rem 0 0 .5rem',
		background: 'var(--dark-green-bg)',
		cursor: 'pointer',
		width: '2.85rem',
		height: '2.85rem',
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
		padding: '.55rem',
		'& img': {
			width: '1.6rem',
			height: '1.6rem',
			objectFit: 'contain',
		},
		'&:hover': {
			opacity: .85,
		},
	},
	photoGrid: {
		display: 'grid',
		gridTemplateColumns: 'repeat(4, minmax(0, 1fr))',
		gridTemplateRows: 'min-content',
		gap: '.75rem',
		flex: 1,
		overflowY: 'auto',
		overflowX: 'hidden',
		marginRight: '-2.5rem',
		marginTop: '-1rem',
		marginBottom: '-1rem',
		padding: '1rem 2.5rem 1rem 1px',
		WebkitMask: 'linear-gradient(180deg, transparent 0, #fff 1rem, #fff calc(100% - 1rem), transparent)',
		'&::-webkit-scrollbar-track': {
			marginTop: '1rem',
			marginBottom: '1rem',
		},
	},
	photoItem: {
		position: 'relative',
		isolation: 'isolate',
		height: '12rem',
		borderRadius: '.5rem',
		border: '1px solid rgba(255,255,255,.16)',
		background: 'linear-gradient(143deg, rgba(20,26,9,0) 2.22%, rgba(176,255,40,.25)), rgba(0,0,0,.55)',
		color: '#fff',
		display: 'flex',
		flexDirection: 'column',
		alignItems: 'center',
		overflow: 'hidden',
		cursor: 'pointer',
		transition: 'background .1s ease, border .2s ease, box-shadow .2s ease',
		'&:hover': {
			borderColor: '#87cd27',
			background: 'linear-gradient(0deg, rgba(158,255,0,.2), rgba(158,255,0,.2)), rgba(36,48,15,.75)',
		},
		'&.active': {
			borderColor: '#87cd27',
			background: 'linear-gradient(0deg, rgba(158,255,0,.2), rgba(158,255,0,.2)), rgba(36,48,15,.75)',
			boxShadow: '0 4px 24px rgba(135, 218, 33, .18)',
		},
	},
	photoImage: {
		position: 'absolute',
		top: '1rem',
		left: '50%',
		transform: 'translateX(-50%)',
		width: '80%',
		height: 'calc(100% - 4rem)',
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
		zIndex: -1,
		'& img': {
			width: '100%',
			height: '100%',
			objectFit: 'contain',
		},
	},
	missingImage: {
		fontSize: '3rem',
		color: 'rgba(255,255,255,.45)',
		fontWeight: 700,
	},
	photoLabel: {
		marginTop: 'auto',
		width: '100%',
		minHeight: '4rem',
		padding: '5rem 0 .75rem',
		display: 'flex',
		alignItems: 'flex-end',
		justifyContent: 'center',
		background: 'radial-gradient(circle at 50% calc(100% - .75rem), rgba(0,0,0,.25) 0, transparent 50%)',
		fontSize: '.875rem',
		fontWeight: 400,
		textAlign: 'center',
		'& span': {
			maxWidth: '100%',
			overflow: 'hidden',
			whiteSpace: 'nowrap',
			textOverflow: 'ellipsis',
		},
	},
	colorPanels: {
		display: 'grid',
		gridTemplateColumns: 'repeat(2, minmax(0, 1fr))',
		gap: '1rem',
	},
	colorPanel: {
		padding: '1.25rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		flexDirection: 'column',
		gap: '1rem',
	},
	colorTitle: {
		margin: 0,
		fontSize: '1.25rem',
		fontWeight: 400,
		textTransform: 'uppercase',
	},
	colorGrid: {
		display: 'grid',
		gridTemplateColumns: 'repeat(8, minmax(0, 1fr))',
		gap: '.5rem',
	},
	colorButton: {
		aspectRatio: '1',
		borderRadius: '.125rem',
		border: 0,
		outline: '1px solid hsla(0,0%,100%,.25)',
		cursor: 'pointer',
		'&.active': {
			outline: '3px solid #fff',
		},
	},
	undress: {
		position: 'absolute',
		left: '2.5rem',
		bottom: '2.5rem',
		zIndex: 2,
		display: 'flex',
		flexDirection: 'column',
		gap: '1.25rem',
		pointerEvents: 'auto',
	},
	undressTitle: {
		margin: 0,
		fontSize: '2rem',
		fontWeight: 600,
		textTransform: 'uppercase',
		textShadow: '0 0 16px rgba(0,0,0,.7)',
	},
	undressButtons: {
		display: 'grid',
		gridTemplateColumns: 'repeat(4, 3rem)',
		gap: '1rem',
	},
	bottomBar: {
		width: '100%',
		marginTop: 'auto',
		paddingTop: '1rem',
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'space-between',
	},
	saveButton: {
		border: '1.5px solid var(--green-active)',
		borderRadius: '.375rem',
		background: '#364d21',
		color: '#fff',
		height: 'fit-content',
		padding: '.75rem 1rem',
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: '1rem',
		fontWeight: 400,
		lineHeight: 1,
		cursor: 'pointer',
		'&:hover': {
			background: 'rgba(135,218,33,.2)',
		},
	},
	hideToggle: {
		border: 0,
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		color: '#fff',
		height: 'fit-content',
		padding: '.75rem 1rem',
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
		width: 'fit-content',
		gap: '.6125rem',
		fontFamily: "'Bai Jamjuree', sans-serif",
		fontSize: '1rem',
		fontWeight: 400,
		lineHeight: 1,
		cursor: 'pointer',
		'&.disabled': {
			opacity: .55,
			pointerEvents: 'none',
		},
	},
	switchTrack: {
		width: '1.5rem',
		height: '.75rem',
		borderRadius: '999px',
		background: 'hsla(0,0%,7%,.15)',
		border: '.05rem solid hsla(0,0%,100%,.15)',
		position: 'relative',
		'&:after': {
			content: '""',
			position: 'absolute',
			top: 'calc(50% - .375rem)',
			left: 0,
			width: '.75rem',
			height: '.75rem',
			borderRadius: '50%',
			background: '#9e9e9e',
			transition: 'left .15s ease, background .15s ease',
		},
		'&.active': {
			background: 'rgba(var(--green-active-rgb), .1)',
			borderColor: 'rgba(var(--green-active-rgb), .5)',
			'&:after': {
				left: 'calc(100% - .75rem)',
				background: 'var(--green-active)',
			},
		},
	},
	srpCheckbox: {
		appearance: 'none',
		background: '#0b1203',
		width: '1.75rem',
		height: '1.75rem',
		border: 0,
		borderRadius: '.325rem',
		margin: 0,
		position: 'relative',
		cursor: 'pointer',
		flex: '0 0 auto',
		'&:disabled': {
			pointerEvents: 'none',
			filter: 'contrast(.5)',
		},
		'&:before': {
			content: '""',
			display: 'block',
			width: '.75rem',
			height: '.75rem',
			transition: 'transform .12s ease-in-out',
			background: 'var(--green-active)',
			position: 'absolute',
			left: '50%',
			top: '50%',
			transform: 'translate(-50%, -50%) scale(0)',
			borderRadius: '50%',
		},
		'&:checked:before': {
			transform: 'translate(-50%, -50%) scale(1)',
		},
	},
	srpSliderWrapper: {
		position: 'relative',
		overflow: 'visible',
		width: '100%',
		height: 'fit-content',
		'&.disabled': {
			opacity: .4,
			pointerEvents: 'none',
		},
	},
	srpSlider: {
		width: '100%',
		height: '.25rem',
		border: 0,
		borderRadius: '2rem',
		appearance: 'none',
		background: 'linear-gradient(90deg, var(--green-active) var(--progress), rgba(255,255,255,.18) var(--progress))',
		'&::-webkit-slider-thumb': {
			appearance: 'none',
			width: '.75rem',
			height: '.75rem',
			borderRadius: '50%',
			background: '#fff',
			border: 0,
		},
		'&:focus': {
			outline: 'none',
		},
	},
	srpList: {
		display: 'flex',
		flexDirection: 'column',
		gap: '.75rem',
		maxHeight: '100%',
		minHeight: 0,
		overflowY: 'auto',
		overflowX: 'hidden',
		marginRight: '-1rem',
		marginTop: '-1rem',
		padding: '1rem 1rem 1rem 0',
		marginBottom: '-1rem',
		WebkitMask: 'linear-gradient(180deg, transparent 0, #fff 1rem, #fff calc(100% - 1rem), transparent)',
		'&::-webkit-scrollbar-track': {
			marginTop: '1rem',
			marginBottom: '1rem',
		},
	},
	faceSelectorWrapper: {
		display: 'flex',
		flexDirection: 'column',
	},
	faceSelectorPart: {
		padding: '1.25rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		alignItems: 'center',
		gap: '.75rem',
		lineHeight: '100%',
		cursor: 'pointer',
		'& svg': {
			width: '1.5rem',
			transition: 'transform .2s ease',
		},
		'&.open svg': {
			transform: 'rotate(180deg)',
		},
	},
	faceSelectorName: {
		fontSize: '1.5rem',
		textTransform: 'uppercase',
		marginRight: 'auto',
	},
	faceSelectorAvail: {
		color: 'hsla(0,0%,100%,.5)',
		fontSize: '1.125rem',
		textTransform: 'uppercase',
	},
	faceSelectorWheels: {
		display: 'grid',
		gridTemplateColumns: '12rem 12rem',
		gap: '2rem',
	},
	faceSelectorWheel: {
		display: 'flex',
		justifyContent: 'space-between',
		alignItems: 'center',
		gap: '.5rem',
		color: 'hsla(0,0%,100%,.5)',
		textTransform: 'uppercase',
	},
	faceSelectorPhotos: {
		maxHeight: 0,
		overflow: 'hidden',
		transition: 'max-height .4s ease, padding .4s ease',
		'&.open': {
			padding: '1rem 0',
			maxHeight: '26rem',
		},
	},
	faceMixPart: {
		padding: '2rem 1.5rem',
		paddingRight: '3.5rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		alignItems: 'center',
		gap: '.75rem',
		lineHeight: '100%',
	},
	faceMixName: {
		fontSize: '1.5rem',
		textTransform: 'uppercase',
		marginRight: 'auto',
	},
	faceMixSliders: {
		display: 'grid',
		gridTemplateColumns: '12rem 12rem',
		gap: '2rem',
	},
	faceMixSlider: {
		display: 'flex',
		alignItems: 'center',
		gap: '1rem',
		color: 'hsla(0,0%,100%,.5)',
		textTransform: 'uppercase',
		'& p': {
			margin: 0,
			minWidth: '3.25rem',
		},
	},
	faceEyePart: {
		padding: '1.25rem',
		paddingRight: '3.5rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		alignItems: 'center',
		gap: '.75rem',
		lineHeight: '100%',
	},
	faceEyeName: {
		fontSize: '1.5rem',
		textTransform: 'uppercase',
	},
	faceEyeLabel: {
		textTransform: 'uppercase',
		color: 'hsla(0,0%,100%,.5)',
		fontSize: '1.125rem',
		marginRight: 'auto',
	},
	faceFeatureCategoryWrapper: {
		display: 'flex',
		flexDirection: 'column',
		gap: '1rem',
	},
	faceFeatureCategory: {
		padding: '1.75rem 1.25rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'space-between',
		gap: '.75rem',
		lineHeight: '100%',
		fontSize: '1.5rem',
		textTransform: 'uppercase',
		cursor: 'pointer',
		'& svg': {
			width: '1.5rem',
			transition: 'transform .2s ease',
			fontSize: '1rem',
		},
		'&.open svg': {
			transform: 'rotate(180deg)',
		},
	},
	faceFeatureGrid: {
		display: 'flex',
		flexDirection: 'column',
		gap: '.75rem',
		overflow: 'hidden',
		maxHeight: 0,
		transition: 'max-height .25s ease',
		'&.open': {
			maxHeight: '50rem',
		},
	},
	faceFeaturePart: {
		padding: '1.875rem 1.5rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		alignItems: 'center',
		gap: '.75rem',
		lineHeight: '100%',
	},
	faceFeatureName: {
		fontSize: '1.5rem',
		textTransform: 'uppercase',
		width: '10rem',
	},
	featureWheel: {
		margin: '-.5rem auto -.5rem 0',
	},
	featureSliderWrap: {
		position: 'relative',
		bottom: '.2rem',
		width: '20%',
		minWidth: '9rem',
	},
	overlayWrapper: {
		display: 'flex',
		flexDirection: 'column',
	},
	overlayPart: {
		padding: '1.25rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		alignItems: 'center',
		gap: '.75rem',
		lineHeight: '100%',
		cursor: 'pointer',
		'&:not(.hasColor)': {
			paddingRight: '3.5rem',
		},
		'& svg': {
			width: '1.5rem',
			transition: 'transform .2s ease',
		},
		'&.open svg': {
			transform: 'rotate(180deg)',
		},
		'&.disabled $overlayName': {
			color: 'hsla(0,0%,100%,.5)',
		},
		'&.disabled $overlayAvail': {
			color: 'hsla(0,0%,100%,.1)',
		},
	},
	overlayName: {
		fontSize: '1.5rem',
		textTransform: 'uppercase',
		whiteSpace: 'nowrap',
	},
	overlayAvail: {
		color: 'hsla(0,0%,100%,.5)',
		fontSize: '1.125rem',
		marginRight: 'auto',
		textTransform: 'uppercase',
		whiteSpace: 'nowrap',
	},
	overlaySliderWrap: {
		position: 'relative',
		bottom: '.2rem',
		width: '9rem',
	},
	overlayWheel: {
		marginLeft: '2rem',
	},
	overlayColorsWrapper: {
		paddingTop: '.5rem',
		transition: 'max-height .4s ease, padding .5s ease',
		maxHeight: 0,
		overflow: 'hidden',
		'&.open': {
			maxHeight: '17rem',
		},
		'&.cols': {
			display: 'grid',
			gridTemplateColumns: 'repeat(2, minmax(0, 1fr))',
			gap: '1rem',
			'& $overlayColorGrid': {
				gridTemplateColumns: 'repeat(8, minmax(0, 1fr))',
			},
			'&.open': {
				maxHeight: '27rem',
			},
		},
	},
	overlayColors: {
		padding: '1.25rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		overflow: 'hidden',
		display: 'flex',
		flexDirection: 'column',
		gap: '1rem',
		'& p': {
			margin: 0,
			fontSize: '1.25rem',
			textTransform: 'uppercase',
		},
	},
	overlayColorGrid: {
		display: 'grid',
		gap: '.5rem',
		gridTemplateColumns: 'repeat(16, minmax(0, 1fr))',
	},
	overlayColor: {
		aspectRatio: '1',
		borderRadius: '.125rem',
		outline: '1px solid hsla(0,0%,100%,.25)',
		border: 0,
		cursor: 'pointer',
		'&.active': {
			outline: '3px solid #fff',
		},
	},
	photoWrapSmall: {
		padding: 0,
		background: 'transparent',
		height: '26rem',
		maxHeight: '26rem',
		'& $photoGrid': {
			marginRight: 0,
			padding: '1.5rem .5rem 1.5rem 0',
		},
	},
	photoWrapFluid: {
		flex: '1 1 0',
		height: 'auto',
		maxHeight: 'none',
		minHeight: 0,
	},
	tattooItem: {
		height: '16rem',
	},
	tattooImage: {
		top: 0,
	},
	tattooLabel: {
		gap: '1rem',
	},
	pedSelectorScreen: {
		display: 'flex',
		flexDirection: 'column',
		gap: '1.5rem',
		minHeight: 0,
		height: '100%',
	},
	pedSelectorPart: {
		padding: '1.25rem',
		borderRadius: '.5rem',
		background: 'var(--dark-green-bg)',
		display: 'flex',
		alignItems: 'center',
		gap: '.75rem',
		lineHeight: '100%',
		'&:not(.hasColor)': {
			paddingRight: '3.5rem',
		},
	},
	pedWarning: {
		color: 'hsla(0,0%,100%,.55)',
		fontSize: '1rem',
		lineHeight: 1.25,
		margin: 0,
	},
	tattooCount: {
		width: 'fit-content',
		marginBottom: '.75rem',
		fontSize: '1.125rem',
		fontWeight: 600,
		textTransform: 'uppercase',
		color: 'rgba(255,255,255,.5)',
		padding: '.85rem 1rem',
		background: 'var(--dark-green-bg)',
		borderRadius: '.5rem',
		'& span': {
			color: '#87da21',
		},
	},
}));

function getModel(state) {
	if (state.ped.model) return state.ped.model;
	return state.gender === 1 ? 'mp_f_freemode_01' : 'mp_m_freemode_01';
}

function getMapEntry(model, kind, componentId, drawableId) {
	const group = clothingMaps[kind]?.[model]?.[String(componentId)];
	return group?.[String(drawableId)] || null;
}

function getMappedDrawables(model, kind, componentId) {
	const group = clothingMaps[kind]?.[model]?.[String(componentId)];
	if (!group) return [];
	return Object.keys(group).map(Number).sort((a, b) => a - b);
}

function normalizeLabel(entry, fallback, index) {
	return `${fallback} ${index + 1}`;
}

function getAutoShotGender(model) {
	if (model === 'mp_f_freemode_01') return 'female';
	return 'male';
}

function pedAssetUrl(path) {
	if (typeof GetParentResourceName === 'function') {
		return `nui://${GetParentResourceName()}/ui/src/${path}`;
	}

	if (window.location.protocol.startsWith('http')) {
		return `/${path}`;
	}

	return path;
}

function localClothesImageUrl(model, kind, componentId, drawableId) {
	if (!model || !kind || componentId === undefined || drawableId === undefined) return null;
	return pedAssetUrl(`assets/autoshot/${getAutoShotGender(model)}/${kind}/${componentId}/${drawableId}.png`);
}

function imageUrl(entry, fallback, context = {}) {
	return localClothesImageUrl(context.model, context.kind, context.componentId, context.drawableId);
}

function NumberWheel({ value, min = 1, max = 1, disabled, onChange }) {
	const classes = useStyles();
	const inc = (delta) => {
		if (disabled) return;
		let next = value + delta;
		if (next > max) next = min;
		if (next < min) next = max;
		Nui.send('FrontEndSound', { sound: 'UPDOWN' });
		onChange(next);
	};

	return (
		<div className={classes.numberWheel}>
			<button className={classes.wheelButton} type="button" onClick={() => inc(-1)} disabled={disabled}>-</button>
			<div className={classes.wheelValue}>{disabled ? '' : value}</div>
			<button className={classes.wheelButton} type="button" onClick={() => inc(1)} disabled={disabled}>+</button>
		</div>
	);
}

function SrpCheckbox({ checked, disabled, onChange }) {
	const classes = useStyles();

	return (
		<input
			className={classes.srpCheckbox}
			type="checkbox"
			checked={checked}
			disabled={disabled}
			onClick={(e) => e.stopPropagation()}
			onChange={(e) => onChange(e.target.checked)}
		/>
	);
}

function SrpSlider({ value, min = 0, max = 100, disabled, onChange }) {
	const classes = useStyles();
	const safeMax = max === min ? min + 1 : max;
	const progress = ((Number(value) - min) / (safeMax - min)) * 100;

	return (
		<div className={`${classes.srpSliderWrapper} ${disabled ? 'disabled' : ''}`}>
			<input
				className={classes.srpSlider}
				type="range"
				min={min}
				max={max}
				value={value}
				disabled={disabled}
				style={{ '--progress': `${Math.max(0, Math.min(100, progress))}%` }}
				onClick={(e) => e.stopPropagation()}
				onChange={(e) => onChange(Number(e.target.value))}
			/>
		</div>
	);
}

function PhotoMenuList({
	items,
	activeIndex,
	onSelect,
	disabled,
	showCamera = false,
	small = false,
	fluid = false,
	tattoo = false,
}) {
	const classes = useStyles();
	const [errors, setErrors] = useState({});

	const onCamera = (value) => {
		Nui.send('ChangeCamera', { cameraType: value });
	};

	return (
		<div className={`${classes.photoWrap} ${small ? classes.photoWrapSmall : ''} ${fluid ? classes.photoWrapFluid : ''}`}>
			{showCamera ? (
				<div className={classes.cameraList}>
					{cameraButtons.map((camera) => (
						<button className={classes.cameraButton} key={camera.key} type="button" onClick={() => onCamera(camera.value)}>
							<img src={camera.icon} alt="" />
						</button>
					))}
				</div>
			) : null}
			<div className={classes.photoGrid}>
				{items.map((item, index) => (
					<div
						className={`${classes.photoItem} ${tattoo ? classes.tattooItem : ''} ${item.active || index === activeIndex ? 'active' : ''}`}
						key={item.key ?? index}
						role="button"
						tabIndex={disabled || item.disabled ? -1 : 0}
						aria-disabled={disabled || item.disabled}
						onClick={() => {
							if (!disabled && !item.disabled) onSelect(index, item);
						}}
					>
						<div className={`${classes.photoImage} ${tattoo ? classes.tattooImage : ''}`}>
							{item.src && !errors[item.key ?? index] ? (
								<img
									src={item.src}
									alt=""
									loading="lazy"
									onError={() => setErrors((prev) => ({ ...prev, [item.key ?? index]: true }))}
								/>
							) : (
								<FontAwesomeIcon icon={['fas', 'question']} className={classes.missingImage} />
							)}
						</div>
						<div className={`${classes.photoLabel} ${tattoo ? classes.tattooLabel : ''}`}>
							<span>{item.label}</span>
							{item.extra}
						</div>
					</div>
				))}
			</div>
		</div>
	);
}

function PhotoGrid({ model, kind, componentId, label, drawables, activeDrawable, disabled, onSelect }) {
	const classes = useStyles();
	const [errors, setErrors] = useState({});

	const activeIndex = drawables.indexOf(activeDrawable);

	const onCamera = (value) => {
		Nui.send('ChangeCamera', { cameraType: value });
	};

	return (
		<div className={classes.photoWrap}>
			<div className={classes.cameraList}>
				{cameraButtons.map((camera) => (
					<button className={classes.cameraButton} key={camera.key} type="button" onClick={() => onCamera(camera.value)}>
						<img src={camera.icon} alt="" />
					</button>
				))}
			</div>
			<div className={classes.photoGrid}>
				{drawables.map((drawableId, index) => {
					const entry = getMapEntry(model, kind, componentId, drawableId);
					const imageKey = `${componentId}-${drawableId}`;
					const src = imageUrl(entry, label, { model, kind, componentId, drawableId });
					return (
						<button
							className={`${classes.photoItem} ${index === activeIndex ? 'active' : ''}`}
							key={`${componentId}-${drawableId}`}
							type="button"
							disabled={disabled}
							onClick={() => onSelect(index)}
						>
							<div className={classes.photoImage}>
								{src && !errors[imageKey] ? (
									<img
										src={src}
										alt=""
										loading="lazy"
										onError={() => setErrors((prev) => ({ ...prev, [imageKey]: true }))}
									/>
								) : (
									null
								)}
							</div>
							<div className={classes.photoLabel}>
								<span>{normalizeLabel(entry, label, index)}</span>
							</div>
						</button>
					);
				})}
			</div>
		</div>
	);
}

function HairColorPanels({ name }) {
	const classes = useStyles();
	const dispatch = useDispatch();
	const colors = useSelector((state) => state.app.ped.customization.colors[name]);
	const palette = hairColors;

	const select = (type, index) => {
		Nui.send('FrontEndSound', { sound: 'SELECT' });
		dispatch(SetPedHairColor(index, { type, name }));
		Nui.send('GetPedHairRgbColor', { type, name, colorId: index });
	};

	const renderPanel = (title, type) => (
		<div className={classes.colorPanel}>
			<h4 className={classes.colorTitle}>{title}</h4>
			<div className={classes.colorGrid}>
				{palette.map((color, index) => (
					<button
						className={`${classes.colorButton} ${colors?.[type]?.index === index ? 'active' : ''}`}
						key={`${type}-${index}`}
						type="button"
						style={{ background: `rgb(${color.join(',')})` }}
						onClick={() => select(type, index)}
					/>
				))}
			</div>
		</div>
	);

	return (
		<div className={classes.colorPanels}>
			{renderPanel('Primary Color', 'color1')}
			{renderPanel('Secondary Color', 'color2')}
		</div>
	);
}

function OverlayColorPanels({ def, current, open, labels }) {
	const classes = useStyles();
	const dispatch = useDispatch();
	const colorCount = def.colorType?.includes('both') ? 2 : 1;
	const palette = def.colorType?.includes('hair') ? hairColors : makeupColors;
	const isHairColor = def.colorName && def.type !== 'chesthair';

	const getActive = (index) => {
		const key = `color${index}`;
		if (isHairColor) return current?.colors?.[key]?.index ?? 0;
		return current?.overlay?.[key] ?? 0;
	};

	const select = (colorIndex, paletteIndex) => {
		const key = `color${colorIndex}`;
		Nui.send('FrontEndSound', { sound: 'SELECT' });
		if (isHairColor) {
			dispatch(SetPedHairColor(paletteIndex, { type: key, name: def.colorName }));
			Nui.send('GetPedHairRgbColor', { type: key, name: def.colorName, colorId: paletteIndex });
			return;
		}

		dispatch(SetPedHeadOverlay(paletteIndex, {
			type: def.type,
			id: def.id,
			extraType: key,
		}));
	};

	if (!def.colorType) return null;

	return (
		<div className={`${classes.overlayColorsWrapper} ${open ? 'open' : ''} ${colorCount > 1 ? 'cols' : ''}`}>
			{Array.from({ length: colorCount }, (_, index) => {
				const colorIndex = index + 1;
				return (
					<div className={classes.overlayColors} key={colorIndex}>
						{labels ? <p>{colorIndex === 1 ? 'Primary Color' : 'Secondary Color'}</p> : null}
						<div className={classes.overlayColorGrid}>
							{palette.map((color, paletteIndex) => (
								<button
									className={`${classes.overlayColor} ${getActive(colorIndex) === paletteIndex ? 'active' : ''}`}
									key={`${colorIndex}-${paletteIndex}`}
									type="button"
									style={{ background: `rgb(${color.join(',')})` }}
									onClick={(e) => {
										e.stopPropagation();
										select(colorIndex, paletteIndex);
									}}
								/>
							))}
						</div>
					</div>
				);
			})}
		</div>
	);
}

function ComponentSelector({ option }) {
	const classes = useStyles();
	const dispatch = useDispatch();
	const app = useSelector((state) => state.app);
	const model = getModel(app);
	const isProp = option.type === 'prop';
	const kind = isProp ? 'props' : 'components';
	const name = isProp ? option.propKey : option.componentKey;
	const data = isProp ? app.ped.customization.props[name] : app.ped.customization.components[name];
	const componentId = data.componentId;
	const maxDrawables = app.drawables[kind]?.[componentId];
	const maxTextures = app.textures[kind]?.[componentId];
	const mappedDrawables = getMappedDrawables(model, kind, componentId);
	const drawables = maxDrawables?.length ? maxDrawables : mappedDrawables;
	const safeDrawables = drawables.length ? drawables : [0];
	const activeDrawable = data.drawableId;
	const activeIndex = Math.max(0, safeDrawables.indexOf(activeDrawable));
	const drawableDisplay = activeIndex + 1;
	const textureDisplay = (data.textureId || 0) + 1;
	const disabled = isProp && data.disabled;

	useEffect(() => {
		if (isProp) {
			Nui.send('GetNumberOfPedPropDrawableVariations', { componentId });
		} else {
			Nui.send('GetNumberOfPedDrawableVariations', { componentId });
		}
	}, [componentId, isProp]);

	useEffect(() => {
		if (isProp) {
			Nui.send('GetNumberOfPedPropTextureVariations', { componentId, drawableId: activeDrawable });
		} else {
			Nui.send('GetNumberOfPedTextureVariations', { componentId, drawableId: activeDrawable });
		}
	}, [activeDrawable, componentId, isProp]);

	const setDisabled = () => {
		if (!isProp) return;
		Nui.send('FrontEndSound', { sound: 'SELECT' });
		dispatch(SetPedPropIndex(!data.disabled, { type: 'disabled', name }));
	};

	const setDrawable = (displayValue) => {
		const drawable = safeDrawables[displayValue - 1] ?? 0;
		if (isProp) {
			if (data.disabled) dispatch(SetPedPropIndex(false, { type: 'disabled', name }));
			dispatch(SetPedPropIndex(drawable, { type: 'drawableId', name }));
			dispatch(SetPedPropIndex(0, { type: 'textureId', name }));
		} else {
			dispatch(SetPedComponentVariation(drawable, { type: 'drawableId', name }));
			dispatch(SetPedComponentVariation(0, { type: 'textureId', name }));
		}
	};

	const setTexture = (displayValue) => {
		const action = isProp ? SetPedPropIndex : SetPedComponentVariation;
		dispatch(action(displayValue - 1, { type: 'textureId', name }));
	};

	return (
		<div className={classes.componentScreen}>
			<div className={`${classes.selectorRow} ${disabled ? 'disabled' : ''}`}>
				<div className={classes.selectorPart}>
					{isProp ? (
						<button className={`${classes.propToggle} ${!data.disabled ? 'active' : ''}`} type="button" onClick={setDisabled} />
					) : null}
					<p className={classes.selectorName}>{option.label}</p>
					<p className={classes.selectorAvail}>{safeDrawables.length} Available</p>
					<NumberWheel value={drawableDisplay} min={1} max={safeDrawables.length} disabled={disabled} onChange={setDrawable} />
				</div>
				<div className={classes.selectorPart}>
					<p className={classes.selectorName}>Variants</p>
					<p className={classes.selectorAvail}>{maxTextures || 1} Available</p>
					<NumberWheel value={textureDisplay} min={1} max={maxTextures || 1} disabled={disabled} onChange={setTexture} />
				</div>
			</div>

			{option.showPhotos === false ? null : (
				<PhotoGrid
					model={model}
					kind={kind}
					componentId={componentId}
					label={option.label}
					drawables={safeDrawables}
					activeDrawable={activeDrawable}
					disabled={disabled}
					onSelect={(index) => setDrawable(index + 1)}
				/>
			)}

			{option.colorName ? <HairColorPanels name={option.colorName} /> : null}
		</div>
	);
}

function FaceSelector({ faceName, faceLabel, open, onOpen }) {
	const classes = useStyles();
	const dispatch = useDispatch();
	const face = useSelector((state) => state.app.ped.customization.face[faceName]);
	const availCount = faceCounts[faceName] || 46;
	const currentShape = (face?.index ?? 0) + 1;
	const currentTexture = (face?.texture ?? 0) + 1;
	const items = Array.from({ length: availCount }, (_, index) => ({
		key: `${faceName}-${index}`,
		label: `Face ${index + 1}`,
		src: `https://cdn.prodigyrp.net/clothes/SP_M_HEAD_${index}_0.webp`,
	}));

	const setFaceValue = (type, displayValue) => {
		dispatch(SetPedHeadBlendData(displayValue - 1, { face: faceName, type }));
	};

	return (
		<div className={classes.faceSelectorWrapper}>
			<div className={`${classes.faceSelectorPart} ${open ? 'open' : ''}`} onClick={onOpen}>
				<div className={classes.faceSelectorName}>{faceLabel}</div>
				<div className={classes.faceSelectorAvail}>{availCount} Available</div>
				<div className={classes.faceSelectorWheels}>
					<div className={classes.faceSelectorWheel} onClick={(e) => e.stopPropagation()}>
						Shape
						<NumberWheel value={currentShape} min={1} max={availCount} onChange={(value) => setFaceValue('index', value)} />
					</div>
					<div className={classes.faceSelectorWheel} onClick={(e) => e.stopPropagation()}>
						Color
						<NumberWheel value={currentTexture} min={1} max={45} onChange={(value) => setFaceValue('texture', value)} />
					</div>
				</div>
				<FontAwesomeIcon icon={['fas', 'chevron-down']} />
			</div>
			<div className={`${classes.faceSelectorPhotos} ${open ? 'open' : ''}`}>
				<PhotoMenuList
					items={items}
					activeIndex={currentShape - 1}
					small
					onSelect={(index) => setFaceValue('index', index + 1)}
				/>
			</div>
		</div>
	);
}

function FaceMixSlider() {
	const classes = useStyles();
	const dispatch = useDispatch();
	const face = useSelector((state) => state.app.ped.customization.face);

	const setMix = (faceName, value) => {
		dispatch(SetPedHeadBlendData(value, { face: faceName, type: 'mix' }));
	};

	return (
		<>
			<div className={classes.faceMixPart}>
				<div className={classes.faceMixName}>Face Mixing</div>
				<div className={classes.faceMixSliders}>
					<div className={classes.faceMixSlider}>
						<p>Shape</p>
						<SrpSlider value={face.face1.mix} min={0} max={100} onChange={(value) => setMix('face1', value)} />
					</div>
					<div className={classes.faceMixSlider}>
						<p>Color</p>
						<SrpSlider value={face.face2.mix} min={0} max={100} onChange={(value) => setMix('face2', value)} />
					</div>
				</div>
			</div>
			<div className={classes.faceMixPart}>
				<div className={classes.faceMixName}>Third Face Mix</div>
				<div className={classes.faceMixSliders}>
					<div aria-hidden="true" />
					<div className={classes.faceMixSlider}>
						<p>Both</p>
						<SrpSlider value={face.face3.mix} min={0} max={100} onChange={(value) => setMix('face3', value)} />
					</div>
				</div>
			</div>
		</>
	);
}

function EyeColorPanel() {
	const classes = useStyles();
	const dispatch = useDispatch();
	const eyeColor = useSelector((state) => state.app.ped.customization.eyeColor);
	const items = eyeColorLabels.map((label, index) => ({
		key: `eye-${index}`,
		label,
		src: eyeImages[index],
	}));

	const setEyeColor = (value) => {
		Nui.send('FrontEndSound', { sound: 'SELECT' });
		dispatch(SetPedEyeColor(value));
	};

	return (
		<>
			<div className={classes.faceEyePart}>
				<div className={classes.faceEyeName}>Eye Color</div>
				<p className={classes.faceEyeLabel}>{eyeColorLabels[eyeColor] || eyeColorLabels[0]}</p>
				<NumberWheel value={eyeColor} min={0} max={eyeColorLabels.length - 1} onChange={setEyeColor} />
			</div>
			<PhotoMenuList
				items={items}
				activeIndex={eyeColor}
				small
				onSelect={(index) => setEyeColor(index)}
			/>
		</>
	);
}

function SrpFaceShape() {
	const classes = useStyles();
	const model = useSelector((state) => getModel(state.app));
	const [openFace, setOpenFace] = useState(null);
	const isCustomPed = model !== 'mp_m_freemode_01' && model !== 'mp_f_freemode_01';

	if (isCustomPed) {
		return <ComponentSelector option={{ label: 'Face', type: 'component', componentKey: 'face', showPhotos: false }} />;
	}

	return (
		<div className={classes.srpList}>
			{['face1', 'face2', 'face3'].map((faceName, index) => (
				<FaceSelector
					key={faceName}
					faceName={faceName}
					faceLabel={`Face ${index + 1}`}
					open={openFace === faceName}
					onOpen={() => setOpenFace((prev) => (prev === faceName ? null : faceName))}
				/>
			))}
			<FaceMixSlider />
			<EyeColorPanel />
		</div>
	);
}

function FaceFeaturePart({ index }) {
	const classes = useStyles();
	const dispatch = useDispatch();
	const value = useSelector((state) => state.app.ped.customization.face.features[index] ?? 0);
	const percent = Math.round((Number(value) + 100) / 2);

	const setValue = (nextValue) => {
		dispatch(SetPedFaceFeature(nextValue, { index }));
	};

	return (
		<div className={classes.faceFeaturePart}>
			<p className={classes.faceFeatureName}>{faceFeatureLabels[index]}</p>
			<div className={classes.featureWheel}>
				<NumberWheel value={percent} min={0} max={100} onChange={(next) => setValue((next * 2) - 100)} />
			</div>
			<div className={classes.featureSliderWrap}>
				<SrpSlider value={value} min={-100} max={100} onChange={setValue} />
			</div>
		</div>
	);
}

function FaceFeatureCategory({ group }) {
	const classes = useStyles();
	const [open, setOpen] = useState(false);

	return (
		<div className={classes.faceFeatureCategoryWrapper}>
			<div className={`${classes.faceFeatureCategory} ${open ? 'open' : ''}`} onClick={() => setOpen((prev) => !prev)}>
				{group.label}
				<FontAwesomeIcon icon={['fas', 'chevron-down']} />
			</div>
			<div className={`${classes.faceFeatureGrid} ${open ? 'open' : ''}`}>
				{group.indexes.map((index) => <FaceFeaturePart key={index} index={index} />)}
			</div>
		</div>
	);
}

function SrpFaceFeatures() {
	const classes = useStyles();

	return (
		<div className={classes.srpList}>
			{faceFeatureGroups.map((group) => <FaceFeatureCategory key={group.label} group={group} />)}
		</div>
	);
}

function OverlayPanelItem({ name, alwaysOpen = false }) {
	const classes = useStyles();
	const dispatch = useDispatch();
	const def = overlayDefs[name];
	const customization = useSelector((state) => state.app.ped.customization);
	const overlay = customization.overlay[def.type] || {};
	const [open, setOpen] = useState(alwaysOpen);
	const enabled = !overlay.disabled;
	const displayValue = (overlay.index ?? 0) + 1;
	const colorOpen = alwaysOpen || (open && enabled);
	const colorState = {
		colors: customization.colors[def.colorName || def.type],
		overlay,
	};

	useEffect(() => {
		if (alwaysOpen) setOpen(true);
	}, [alwaysOpen]);

	const setEnabled = (checked) => {
		Nui.send('FrontEndSound', { sound: 'SELECT' });
		dispatch(SetPedHeadOverlay(!checked, { type: def.type, id: def.id, extraType: 'disabled' }));
	};

	const setIndex = (value) => {
		dispatch(SetPedHeadOverlay(value - 1, { type: def.type, id: def.id, extraType: 'index' }));
	};

	const setOpacity = (value) => {
		dispatch(SetPedHeadOverlay(value, { type: def.type, id: def.id, extraType: 'opacity' }));
	};

	const toggleOpen = () => {
		if (alwaysOpen || !def.colorType) return;
		setOpen((prev) => !prev);
	};

	return (
		<div className={classes.overlayWrapper} onClick={toggleOpen}>
			<div className={`${classes.overlayPart} ${def.colorType ? 'hasColor' : ''} ${colorOpen ? 'open' : ''} ${enabled ? '' : 'disabled'}`}>
				<SrpCheckbox checked={enabled} onChange={setEnabled} />
				<div className={classes.overlayName}>{def.label}</div>
				<div className={classes.overlayAvail}>{def.max + 1} Available</div>
				<div className={classes.overlaySliderWrap}>
					<SrpSlider value={overlay.opacity ?? 100} min={0} max={100} disabled={!enabled} onChange={setOpacity} />
				</div>
				<div className={classes.overlayWheel} onClick={(e) => e.stopPropagation()}>
					<NumberWheel value={displayValue} min={1} max={def.max + 1} disabled={!enabled} onChange={setIndex} />
				</div>
				{def.colorType && !alwaysOpen ? <FontAwesomeIcon icon={['fas', 'chevron-down']} /> : null}
			</div>
			<OverlayColorPanels def={def} current={colorState} open={colorOpen} labels={alwaysOpen} />
		</div>
	);
}

function OverlayList({ names, alwaysOpenName }) {
	const classes = useStyles();

	return (
		<div className={classes.srpList}>
			{names.map((name) => (
				<OverlayPanelItem key={name} name={name} alwaysOpen={alwaysOpenName === name} />
			))}
		</div>
	);
}

function HairOverlayPanel({ option }) {
	const classes = useStyles();
	const name = option.name === 'beard' ? 'facialhair' : option.name;

	return (
		<div className={classes.componentScreen}>
			<OverlayPanelItem name={name} alwaysOpen />
		</div>
	);
}

function SrpPedSelector() {
	const classes = useStyles();
	const dispatch = useDispatch();
	const model = useSelector((state) => state.app.ped.model);
	const whitelistedPeds = useSelector((state) => state.app.whitelistedPeds);
	const [isFemale, setIsFemale] = useState(() => PedModels[1].includes(model));
	const [disabled, setDisabled] = useState(false);
	const basePeds = PedModels[isFemale ? 1 : 0];
	const whitelist = whitelistedPeds.map((ped) => ped.model).filter(Boolean);
	const availablePeds = Array.from(new Set([...basePeds, ...whitelist]));
	const currentIndex = availablePeds.indexOf(model);
	const displayValue = currentIndex === -1 ? 1 : currentIndex + 1;
	const items = availablePeds.map((pedModel) => ({
		key: pedModel,
		label: pedModel,
		src: `https://cdn.prodigyrp.net/peds/${pedModel}.webp`,
	}));

	useEffect(() => {
		if (PedModels[1].includes(model)) setIsFemale(true);
		else if (PedModels[0].includes(model)) setIsFemale(false);
	}, [model]);

	const setPed = async (pedModel) => {
		if (!pedModel) return;
		try {
			setDisabled(true);
			const payload = { value: pedModel };
			const res = await (await Nui.send('SetPed', payload)).json();
			if (res) dispatch({ type: 'UPDATE_PED', payload });
		} catch (err) {
			console.log(err);
		} finally {
			setDisabled(false);
		}
	};

	const onFemaleChange = (checked) => {
		Nui.send('FrontEndSound', { sound: 'SELECT' });
		setIsFemale(checked);
		const nextList = PedModels[checked ? 1 : 0];
		if (!nextList.includes(model)) setPed(nextList[0]);
	};

	return (
		<div className={classes.pedSelectorScreen}>
			<div className={classes.pedSelectorPart}>
				<SrpCheckbox checked={isFemale} disabled={disabled} onChange={onFemaleChange} />
				<div className={classes.selectorName}>Use Female Peds</div>
			</div>
			<div className={classes.pedSelectorPart}>
				<div className={classes.selectorName}>Ped Model</div>
				<div className={classes.selectorAvail}>{availablePeds.length} Available</div>
				<NumberWheel
					value={displayValue}
					min={1}
					max={availablePeds.length}
					disabled={disabled}
					onChange={(value) => setPed(availablePeds[value - 1])}
				/>
			</div>
			<PhotoMenuList
				items={items}
				activeIndex={displayValue - 1}
				fluid
				disabled={disabled}
				onSelect={(index) => setPed(availablePeds[index])}
			/>
		</div>
	);
}

function tattooImageUrl(tattoo) {
	let name = tattoo?.Name || tattoo?.Hash || tattoo?.name || '';
	name = name.replaceAll('_F_', '_M_');
	if (name.endsWith('_F')) name = `${name.substring(0, name.length - 2)}_M`;
	if (!name) return null;
	return `https://cdn.prodigyrp.net/tattoos/${encodeURIComponent(name.split(' ').join('_'))}.webp`;
}

function sameTattoo(a, b, zone) {
	if (!a || !b) return false;
	const aName = a.Name || a.Hash || a.name;
	const bName = b.Name || b.Hash || b.name;
	const aCollection = a.Collection || a.collection;
	const bCollection = b.Collection || b.collection;
	return a.Zone === zone && aName === bName && aCollection === bCollection;
}

function TattooPanel({ option }) {
	const classes = useStyles();
	const dispatch = useDispatch();
	const ped = useSelector((state) => state.app.ped);
	const allTattoos = useSelector((state) => state.app.tattoos);
	const availableTattoos = (allTattoos || []).filter((tattoo) => tattoo?.Zone === option.name);
	const currentTattoos = ped.customization.tattoos || [];

	const setTattooCount = (tattoo, nextCount) => {
		const matchingIndexes = currentTattoos
			.map((current, index) => (sameTattoo(current, tattoo, option.name) ? index : -1))
			.filter((index) => index !== -1);
		const currentCount = matchingIndexes.length;
		const clampedCount = Math.max(0, Math.min(10, Math.min(nextCount, 25 - currentTattoos.length + currentCount)));

		if (clampedCount > currentCount) {
			for (let i = currentCount; i < clampedCount; i += 1) {
				const index = currentTattoos.length + (i - currentCount);
				const addPayload = { type: option.name };
				const setPayload = { type: option.name, data: tattoo, index };
				Nui.send('AddPedTattoo', addPayload);
				Nui.send('SetPedTattoo', setPayload);
				dispatch({ type: 'ADD_PED_TATTOO', payload: addPayload });
				dispatch({ type: 'UPDATE_PED_TATTOO', payload: setPayload });
			}
			return;
		}

		if (clampedCount < currentCount) {
			matchingIndexes
				.slice(clampedCount)
				.sort((a, b) => b - a)
				.forEach((index) => {
					const payload = { type: option.name, index };
					Nui.send('RemovePedTattoo', payload);
					dispatch({ type: 'REMOVE_PED_TATTOO', payload });
				});
		}
	};

	const items = availableTattoos.map((tattoo, index) => {
		const count = currentTattoos.filter((current) => sameTattoo(current, tattoo, option.name)).length;
		return {
			key: tattoo.Name || tattoo.Hash || index,
			label: tattoo.Label || tattoo.Name || tattoo.Hash || `Tattoo ${index + 1}`,
			src: tattooImageUrl(tattoo),
			active: count > 0,
			extra: (
				<div onClick={(e) => e.stopPropagation()}>
					<NumberWheel value={count} min={0} max={10} onChange={(value) => setTattooCount(tattoo, value)} />
				</div>
			),
		};
	});

	return (
		<div className={classes.pedSelectorScreen}>
			<div className={classes.tattooCount}>
				<span>{currentTattoos.length}</span> / <span>25</span> Tattoos
			</div>
			{items.length ? (
				<PhotoMenuList items={items} activeIndex={-1} fluid tattoo onSelect={() => {}} />
			) : (
				<div className={`${classes.photoWrap} ${classes.photoWrapFluid}`}>
					<div className={`${classes.photoGrid} noGrid`}>
						<p style={{ fontSize: '1.5rem' }}>No tattoos found...</p>
					</div>
				</div>
			)}
		</div>
	);
}

function ActiveContent({ category, option }) {
	if (category.name === 'cloth') return <ComponentSelector option={option} />;

	if (category.name === 'hair') {
		if (option.name === 'hair') return <ComponentSelector option={option} />;
		return <HairOverlayPanel option={option} />;
	}

	if (category.name === 'face') {
		if (option.name === 'face') return <SrpFaceShape />;
		if (option.name === 'features') return <SrpFaceFeatures />;
		if (option.name === 'overlays') return <OverlayList names={faceOverlayOrder} />;
		if (option.name === 'makeup') return <OverlayList names={makeupOverlayOrder} />;
	}

	if (category.name === 'body') return <OverlayList names={bodyOverlayOrder} />;
	if (category.name === 'tattoo') return <TattooPanel option={option} />;
	if (category.name === 'ped') return <SrpPedSelector />;

	return null;
}

function HideClothesToggle({ undressState, onToggleAll }) {
	const classes = useStyles();
	const isNekked = useSelector((state) => state.app.isNekked);
	const isForced = useSelector((state) => state.app.forcedNekked);
	const gender = useSelector((state) => state.app.gender);
	const model = useSelector((state) => state.app.ped.model);
	const peds = PedModels[gender];
	const curr = peds.indexOf(model) === -1 ? 0 : peds.indexOf(model);
	const active = isNekked || isForced || hasUndressedParts(undressState);
	const disabled = isForced || curr !== 0;

	const onClick = () => {
		if (disabled) return;
		Nui.send('FrontEndSound', { sound: 'SELECT' });
		onToggleAll(!active);
	};

	return (
		<button className={`${classes.hideToggle} ${disabled ? 'disabled' : ''}`} type="button" onClick={onClick}>
			<span className={`${classes.switchTrack} ${active ? 'active' : ''}`} />
			Hide Clothes
		</button>
	);
}

function CameraMouseLayer() {
	const classes = useStyles();
	const dragging = useRef(false);

	useEffect(() => {
		const onMouseMove = (event) => {
			if (!dragging.current) return;

			Nui.send('rotation:rotatePlayer', {
				x: event.clientX,
				y: event.clientY,
				control: event.ctrlKey,
				shift: event.shiftKey,
			});
		};

		const onMouseUp = (event) => {
			if (event.button !== 0) return;

			dragging.current = false;
			document.body.style.cursor = 'auto';
			Nui.send('rotation:setClicked', { state: false });
		};

		window.addEventListener('mousemove', onMouseMove);
		window.addEventListener('mouseup', onMouseUp);

		return () => {
			document.body.style.cursor = 'auto';
			window.removeEventListener('mousemove', onMouseMove);
			window.removeEventListener('mouseup', onMouseUp);
		};
	}, []);

	const onMouseDown = (event) => {
		if (event.button !== 0) return;

		event.preventDefault();
		dragging.current = true;
		document.body.style.cursor = 'e-resize';
		Nui.send('rotation:setClicked', {
			state: true,
			x: event.clientX,
			y: event.clientY,
		});
	};

	return (
		<div
			className={classes.cameraMouseLayer}
			onContextMenu={(event) => event.preventDefault()}
			onMouseDown={onMouseDown}
		/>
	);
}

export default function SrpPedMenu({
	mode = 'creator',
	saveLabel = 'Save Everything',
	onSave,
	onDiscard,
}) {
	const classes = useStyles();
	const dispatch = useDispatch();
	const categories = useMemo(
		() => (modeCategories[mode] || modeCategories.creator).map((name) => categoryDefs[name]),
		[mode],
	);
	const defaultCategory = mode === 'creator' || mode === 'barber' || mode === 'surgery'
		? 'hair'
		: categories[0]?.name;
	const [categoryIndex, setCategoryIndex] = useState(() => Math.max(
		0,
		categories.findIndex((category) => category.name === defaultCategory),
	));
	const [itemIndexes, setItemIndexes] = useState({});
	const [undressState, setUndressState] = useState(emptyUndressState);
	const activeCategory = categories[Math.min(categoryIndex, categories.length - 1)] || categories[0];
	const activeItemIndex = Math.min(itemIndexes[activeCategory.name] || 0, activeCategory.items.length - 1);
	const activeItem = activeCategory.items[activeItemIndex];

	const sendUndressState = (nextState, options = {}) => {
		const normalized = { ...emptyUndressState, ...nextState };
		const active = hasUndressedParts(normalized);
		setUndressState(normalized);
		Nui.send('ToggleNekked', { toggle: active, ...normalized });
		if (!options.forced) {
			dispatch({ type: 'SET_NEKKED', payload: { state: active } });
		}
	};

	useEffect(() => {
		Nui.send('GetNumHairColors');
	}, []);

	useEffect(() => {
		const shouldForceNekked = activeCategory.name === 'tattoo';
		dispatch({ type: 'FORCE_NEKKED', payload: { state: shouldForceNekked } });
		if (shouldForceNekked) {
			sendUndressState(fullUndressState, { forced: true });
		}
		return () => {
			if (shouldForceNekked) {
				dispatch({ type: 'FORCE_NEKKED', payload: { state: false } });
				sendUndressState(emptyUndressState, { forced: true });
			}
		};
	}, [activeCategory.name, dispatch]);

	const setActiveItem = (index) => {
		setItemIndexes((prev) => ({ ...prev, [activeCategory.name]: index }));
	};

	const jumpTo = (categoryName, itemName) => {
		const nextCategoryIndex = categories.findIndex((cat) => cat.name === categoryName);
		if (nextCategoryIndex === -1) return;
		const nextCategory = categories[nextCategoryIndex];
		const nextItemIndex = Math.max(0, nextCategory.items.findIndex((item) => item.name === itemName));
		setCategoryIndex(nextCategoryIndex);
		setItemIndexes((prev) => ({ ...prev, [nextCategory.name]: nextItemIndex }));
	};

	const onUndress = (key) => {
		Nui.send('FrontEndSound', { sound: 'SELECT' });
		sendUndressState({
			...undressState,
			[key]: !undressState[key],
		});
	};

	const close = () => {
		if (onDiscard) onDiscard();
		else dispatch(CancelEdits());
	};

	return (
		<div className={classes.root}>
			<CameraMouseLayer />

			<section className={classes.menuWrapper} data-no-camera-controls>
				<div className={classes.title}>
					<nav className={classes.topNav}>
						{categories.map((category, index) => (
							<button
								key={category.name}
								type="button"
								className={`${classes.topButton} ${categoryIndex === index ? 'active' : ''}`}
								onClick={() => setCategoryIndex(index)}
							>
								{category.label}
							</button>
						))}
					</nav>
					<button className={classes.close} type="button" onClick={close}>
						<FontAwesomeIcon icon={['fas', 'xmark']} />
					</button>
				</div>

				<div className={classes.side}>
					<h4 className={classes.sideTitle}>Categories</h4>
					<div className={classes.iconGrid}>
						{activeCategory.items.map((item, index) => (
							<button
								key={item.name}
								type="button"
								className={`${classes.iconButton} ${activeItemIndex === index ? 'active' : ''}`}
								title={item.label}
								onClick={() => setActiveItem(index)}
							>
								{item.faIcon ? (
									<FontAwesomeIcon icon={item.faIcon} />
								) : (
									<img src={icons[item.icon || item.name] || faceIcon} alt="" />
								)}
							</button>
						))}
					</div>
				</div>

				<main className={classes.content}>
					<ActiveContent category={activeCategory} option={activeItem} />
				</main>

				<div className={classes.bottomBar}>
					<HideClothesToggle
						undressState={undressState}
						onToggleAll={(enabled) => sendUndressState({
							head: enabled,
							torso: enabled,
							pants: enabled,
							shoes: enabled,
						})}
					/>
					<button className={classes.saveButton} type="button" onClick={onSave}>
						{saveLabel}
					</button>
				</div>
			</section>

			<div className={classes.undress} data-no-camera-controls>
				<p className={classes.undressTitle}>Undress</p>
				<div className={classes.undressButtons}>
					{undressItems.map((item) => (
						<button
							className={`${classes.iconButton} ${undressState[item.key] ? 'active' : ''}`}
							key={item.key}
							type="button"
							onClick={() => onUndress(item.key)}
						>
							<img src={item.icon} alt="" />
						</button>
					))}
				</div>
			</div>
		</div>
	);
}
