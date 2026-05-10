import React from 'react';
import { useSelector } from 'react-redux';
import { Box, Flex, Text } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { ACCENT, TEXT_PRIMARY, TEXT_DIM, BORDER_SUBTLE } from '../../../theme';

function getLabel(spawn) {
	return spawn.Name || spawn.label || 'Unknown';
}

const getIcon = (spawn) => {
	if (spawn.icon) return spawn.icon;
	const label = getLabel(spawn).toLowerCase();
	if (label.includes('last') || label.includes('location')) return 'location-dot';
	if (label.includes('prison') || label.includes('penitentiary') || label.includes('jail')) return 'lock';
	if (label.includes('hospital') || label.includes('icu') || label.includes('medical') || label.includes('zonah')) return 'hospital';
	if (label.includes('airport') || label.includes('lsia')) return 'plane';
	if (label.includes('creation') || label.includes('new')) return 'star';
	if (label.includes(' pd') || label.includes('police') || label.includes('sheriff')) return 'shield-halved';
	return 'map-pin';
};

const getSubLabel = (spawn) => {
	const label = getLabel(spawn).toLowerCase();
	if (label.includes('last') || label.includes('location')) return 'Recent location';
	if (label.includes('prison') || label.includes('penitentiary') || label.includes('jail')) return 'Custody';
	if (label.includes('hospital') || label.includes('icu') || label.includes('zonah')) return 'Medical';
	if (label.includes('creation') || label.includes('new')) return 'New character';
	if (label.includes(' pd') || label.includes('police') || label.includes('sheriff')) return 'Law Enforcement';
	return 'Spawn point';
};

export default ({ spawn, onSelect, index }) => {
	const selected = useSelector((state) => state.spawn.selected);
	const isSelected = selected?.id === spawn?.id;

	return (
		<Box
			onClick={() => onSelect(spawn)}
			style={{
				padding: '8px 12px',
				display: 'flex',
				alignItems: 'center',
				gap: 8,
				cursor: 'pointer',
				borderBottom: `1px solid rgba(255,141,36,0.06)`,
				transition: 'background 0.15s ease',
				background: isSelected ? 'rgba(255,141,36,0.12)' : 'transparent',
				'&:hover': { background: 'rgba(255,141,36,0.07)' },
				animation: `slideInLeft 0.3s ease both`,
				animationDelay: `${index * 0.05}s`,
			}}
			onMouseEnter={(e) => {
				if (!isSelected) e.currentTarget.style.background = 'rgba(255,141,36,0.07)';
			}}
			onMouseLeave={(e) => {
				if (!isSelected) e.currentTarget.style.background = 'transparent';
			}}
		>
			<Box style={{
				width: 24,
				height: 24,
				borderRadius: 2,
				background: isSelected ? 'rgba(255,141,36,0.2)' : 'rgba(255,141,36,0.08)',
				border: isSelected ? `1px solid ${ACCENT}` : 'rgba(255,141,36,0.15)',
				display: 'flex',
				alignItems: 'center',
				justifyContent: 'center',
				color: isSelected ? ACCENT : 'rgba(255,141,36,0.5)',
				fontSize: 10,
				flexShrink: 0,
				transition: 'all 0.15s ease',
			}}>
				<FontAwesomeIcon icon={getIcon(spawn)} />
			</Box>

			<Box style={{ flex: 1, minWidth: 0 }}>
				<Text style={{
					fontSize: 11,
					fontWeight: isSelected ? 600 : 400,
					color: isSelected ? ACCENT : TEXT_PRIMARY,
					letterSpacing: '0.03em',
					whiteSpace: 'nowrap',
					overflow: 'hidden',
					textOverflow: 'ellipsis',
					transition: 'color 0.15s ease',
				}}>
					{getLabel(spawn)}
				</Text>
				<Text style={{
					fontSize: 8,
					fontWeight: 600,
					letterSpacing: '0.15em',
					textTransform: 'uppercase',
					color: TEXT_DIM,
					marginTop: 0,
				}}>
					{getSubLabel(spawn)}
				</Text>
			</Box>

			{isSelected && (
				<FontAwesomeIcon icon="check" style={{ color: ACCENT, fontSize: 9 }} />
			)}
		</Box>
	);
};
