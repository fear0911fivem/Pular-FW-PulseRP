import React, { useState, useRef } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Box, Flex, Text, Button } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../util/Nui';
import SpawnButton from './components/SpawnButton';
import { STATE_CHARACTERS } from '../../util/States';
import { PlayCharacter } from '../../util/NuiEvents';
import { ACCENT, TEXT_PRIMARY, TEXT_FAINT, TEXT_DIM, BORDER_SUBTLE, BG_BASE } from '../../theme';
import mapImg from '../../assets/imgs/gta_map.png';

function worldToPercent(x, y) {
	const px = 0.0009381290 * x + -0.0056268303 * y + 61.864066
	         + 0.00000018186850 * x * y
	         + -0.00000108144598 * x * x
	         + -0.00000005722823 * y * y;
	const py = -0.0128792853 * x + 0.0009390601 * y + 52.077199
	         + -0.00000005014422 * x * y
	         + 0.00000133202165 * x * x
	         + -0.00000018458756 * y * y;
	return { px, py };
}

function getCoords(spawn) {
	if (spawn.Coords) return { x: spawn.Coords.x, y: spawn.Coords.y };
	if (spawn.location) return { x: spawn.location.x, y: spawn.location.y };
	return null;
}

function isInteriorSpawn(spawn) {
	return spawn.event === 'Apartment:SpawnInside';
}

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

function useCoverRect(imgRef) {
	const [rect, setRect] = React.useState(null);
	React.useEffect(() => {
		const img = imgRef.current;
		if (!img) return;
		function calc() {
			const cw = img.parentElement.clientWidth;
			const ch = img.parentElement.clientHeight;
			const nw = img.naturalWidth || cw;
			const nh = img.naturalHeight || ch;
			const scale = Math.min(cw / nw, ch / nh);
			const rw = nw * scale;
			const rh = nh * scale;
			const ox = (cw - rw) / 2;
			const oy = (ch - rh) / 2;
			setRect({ ox, oy, rw, rh, cw, ch });
		}
		img.addEventListener('load', calc);
		window.addEventListener('resize', calc);
		if (img.complete) calc();
		return () => {
			img.removeEventListener('load', calc);
			window.removeEventListener('resize', calc);
		};
	}, [imgRef]);
	return rect;
}

export default () => {
    const dispatch = useDispatch();
    const [hoveredPin, setHoveredPin] = useState(null);
    const imgRef = useRef(null);
    const coverRect = useCoverRect(imgRef);

    const motd     = useSelector((state) => state.characters.motd);
    const spawns   = useSelector((state) => state.spawn.spawns);
    const selected = useSelector((state) => state.spawn.selected);
    const char     = useSelector((state) => state.characters.selected);

    const onSpawn = () => {
        if (!selected) return;
        Nui.send(PlayCharacter, { spawn: selected, character: char });
        dispatch({ type: 'LOADING_SHOW', payload: { message: 'Spawning' } });
        dispatch({ type: 'UPDATE_PLAYED' });
        dispatch({ type: 'DESELECT_CHARACTER' });
        dispatch({ type: 'DESELECT_SPAWN' });
    };

    const goBack = () => {
        dispatch({ type: 'DESELECT_CHARACTER' });
        dispatch({ type: 'DESELECT_SPAWN' });
        dispatch({ type: 'SET_STATE', payload: { state: STATE_CHARACTERS } });
    };

    const handleSelect = (spawn) => {
        Nui.send('SelectSpawn', { spawn });
        dispatch({ type: 'SELECT_SPAWN', payload: spawn });
    };

    function imgToContainer(imgPctX, imgPctY) {
        if (!coverRect) return { left: imgPctX, top: imgPctY };
        const { ox, oy, rw, rh, cw, ch } = coverRect;
        const left = ((ox + (imgPctX / 100) * rw) / cw) * 100;
        const top = ((oy + (imgPctY / 100) * rh) / ch) * 100;
        return { left, top };
    }

    return (
        <Box style={{ height: '100vh', width: '100vw', position: 'relative', fontFamily: "'Rajdhani', sans-serif" }}>
            <Box style={{ position: 'absolute', inset: 0, overflow: 'hidden' }}>
                <img
                    ref={imgRef}
                    src={mapImg}
                    alt="GTA Map"
                    style={{
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover',
                        objectPosition: 'center',
                        filter: 'brightness(0.55) saturate(0.8)',
                        userSelect: 'none',
                        pointerEvents: 'none',
                        display: 'block',
                    }}
                />
                <Box style={{
                    position: 'absolute',
                    inset: 0,
                    background: 'radial-gradient(ellipse at center, transparent 30%, rgba(12,16,24,0.85) 100%)',
                    pointerEvents: 'none',
                }} />
                <Box style={{
                    position: 'absolute',
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: '35%',
                    background: 'linear-gradient(to top, rgba(12,16,24,0.95) 0%, transparent 100%)',
                    pointerEvents: 'none',
                }} />
                <Box style={{
                    position: 'absolute',
                    inset: 0,
                    backgroundImage: `
                        linear-gradient(rgba(255,141,36,0.015) 1px, transparent 1px),
                        linear-gradient(90deg, rgba(255,141,36,0.015) 1px, transparent 1px)
                    `,
                    backgroundSize: '120px 120px',
                    pointerEvents: 'none',
                }} />
            </Box>

            <Box style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
                {spawns.map((spawn, i) => {
                    if (isInteriorSpawn(spawn)) return null;
                    const coords = getCoords(spawn);
                    if (!coords) return null;
                    const { px, py } = worldToPercent(coords.x, coords.y);
                    const { left, top } = imgToContainer(px, py);
                    const isSelected = selected?.id === spawn.id;

                    return (
                        <Box
                            key={i}
                            style={{
                                position: 'absolute',
                                transform: 'translate(-50%, -100%)',
                                pointerEvents: 'all',
                                cursor: 'pointer',
                                zIndex: isSelected ? 20 : 10,
                                left: `${left}%`,
                                top: `${top}%`,
                            }}
                            onClick={() => handleSelect(spawn)}
                            onMouseEnter={() => setHoveredPin(i)}
                            onMouseLeave={() => setHoveredPin(null)}
                        >
                            <Box style={{
                                display: 'flex',
                                flexDirection: 'column',
                                alignItems: 'center',
                            }}>
                                <Text
                                    style={{
                                        background: 'transparent',
                                        border: 'none',
                                        borderRadius: 2,
                                        padding: '4px 10px',
                                        marginBottom: 6,
                                        opacity: hoveredPin === i || isSelected ? 1 : 0,
                                        transform: hoveredPin === i || isSelected ? 'translateX(-50%) translateY(-4px)' : 'translateX(-50%) translateY(4px)',
                                        transition: 'all 0.2s ease',
                                        whiteSpace: 'nowrap',
                                        fontSize: 11,
                                        fontWeight: 700,
                                        letterSpacing: '0.1em',
                                        textTransform: 'uppercase',
                                        color: '#ffffff',
                                        textShadow: '0 1px 4px rgba(0,0,0,0.9), 0 0 12px rgba(0,0,0,0.8)',
                                        position: 'relative',
                                    }}
                                >
                                    {getLabel(spawn)}
                                </Text>
                                <Box style={{ position: 'relative', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                                    {isSelected && (
                                        <Box style={{
                                            position: 'absolute',
                                            width: 30,
                                            height: 30,
                                            borderRadius: '50%',
                                            border: `1px solid ${ACCENT}`,
                                            opacity: 0.5,
                                            top: '50%',
                                            left: '50%',
                                            transform: 'translate(-50%, -50%)',
                                            animation: 'pinRipple 1.5s ease-out infinite',
                                            pointerEvents: 'none',
                                        }} />
                                    )}
                                    <Box style={{
                                        width: 14,
                                        height: 14,
                                        borderRadius: '50%',
                                        background: isSelected ? ACCENT : `rgba(255,141,36,0.6)`,
                                        border: '2px solid rgba(255,255,255,0.8)',
                                        boxShadow: isSelected
                                            ? `0 0 0 5px rgba(255,141,36,0.3), 0 0 24px ${ACCENT}`
                                            : `0 0 0 3px rgba(255,141,36,0.2), 0 0 10px rgba(255,141,36,0.4)`,
                                        transition: 'all 0.2s ease',
                                        transform: hoveredPin === i || isSelected ? 'scale(1.3)' : 'scale(1)',
                                        flexShrink: 0,
                                    }} />
                                    <Box style={{
                                        width: 2,
                                        height: 10,
                                        background: isSelected ? ACCENT : 'rgba(255,255,255,0.6)',
                                        transition: 'background 0.2s ease',
                                        boxShadow: isSelected ? `0 0 6px ${ACCENT}` : 'none',
                                    }} />
                                </Box>
                            </Box>
                        </Box>
                    );
                })}
            </Box>

            <Box style={{ position: 'absolute', left: 28, top: 24, zIndex: 30 }}>
                <Text fz={10} fw={700} tt="uppercase" c={TEXT_DIM} style={{ letterSpacing: '0.4em', marginBottom: 4, textShadow: '0 2px 8px rgba(0,0,0,0.8)' }}>
                    Choose where to appear
                </Text>
                <Text style={{
                    fontFamily: "'Orbitron', sans-serif",
                    fontSize: '2.2vw',
                    fontWeight: 900,
                    color: TEXT_PRIMARY,
                    letterSpacing: '0.05em',
                    lineHeight: 1,
                    textShadow: '0 2px 20px rgba(0,0,0,0.9), 0 0 40px rgba(255,141,36,0.2)',
                    textTransform: 'uppercase',
                }}>
                    SPAWN SELECT
                </Text>
                <Flex align="center" gap={5} style={{ marginTop: 8, fontSize: 10, fontWeight: 700, letterSpacing: '0.2em', textTransform: 'uppercase', color: TEXT_DIM }}>
                    <FontAwesomeIcon icon="location-dot" />
                    {spawns.length} location{spawns.length !== 1 ? 's' : ''} available
                </Flex>
            </Box>

            {char && (
                <Box style={{
                    position: 'absolute',
                    top: 24,
                    right: 28,
                    zIndex: 30,
                    display: 'flex',
                    alignItems: 'center',
                    gap: 10,
                    background: 'transparent',
                    border: 'none',
                    borderRadius: 2,
                    padding: '10px 16px',
                }}>
                    <Box style={{
                        width: 30,
                        height: 30,
                        borderRadius: 2,
                        background: `rgba(255,141,36,0.15)`,
                        border: `1px solid ${BORDER_SUBTLE}`,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        color: ACCENT,
                        fontSize: 12,
                    }}>
                        <FontAwesomeIcon icon={Number(char.Gender) === 0 ? 'male' : 'female'} />
                    </Box>
                    <Box>
                        <Text style={{
                            fontFamily: "'Orbitron', sans-serif",
                            fontSize: 12,
                            fontWeight: 700,
                            color: TEXT_PRIMARY,
                            letterSpacing: '0.05em',
                        }}>
                            {char.First} {char.Last}
                        </Text>
                        <Text style={{ fontSize: 10, color: TEXT_DIM, letterSpacing: '0.08em', marginTop: 1 }}>
                            #{char.SID}
                        </Text>
                    </Box>
                </Box>
            )}

            {selected && (
                <Box style={{
                    position: 'absolute',
                    bottom: 80,
                    left: 28,
                    zIndex: 30,
                    background: 'transparent',
                    border: 'none',
                    borderRadius: 2,
                    padding: '10px 14px',
                    minWidth: 200,
                    animation: 'slideUp 0.3s ease both',
                }}>
                    <Text style={{ fontSize: 8, fontWeight: 700, letterSpacing: '0.3em', textTransform: 'uppercase', color: TEXT_DIM, marginBottom: 4 }}>
                        Selected Spawn
                    </Text>
                    <Text style={{
                        fontFamily: "'Rajdhani', sans-serif",
                        fontSize: 12,
                        fontWeight: 700,
                        color: ACCENT,
                        letterSpacing: '0.05em',
                        marginBottom: 1,
                    }}>
                        {getLabel(selected)}
                    </Text>
                    <Text style={{ fontSize: 9, color: TEXT_FAINT, letterSpacing: '0.05em' }}>
                        {getSubLabel(selected)}
                    </Text>
                </Box>
            )}

            <Box style={{
                position: 'absolute',
                bottom: 80,
                right: 28,
                zIndex: 30,
                width: 220,
                maxHeight: '50vh',
                display: 'flex',
                flexDirection: 'column',
                background: 'transparent',
                border: 'none',
                borderRadius: 2,
                overflow: 'hidden',
            }}>
                <Box style={{ padding: '8px 12px', borderBottom: `1px solid ${BORDER_SUBTLE}`, fontSize: 8, fontWeight: 700, letterSpacing: '0.3em', textTransform: 'uppercase', color: TEXT_DIM, flexShrink: 0 }}>
                    Available Spawns
                </Box>
                <Box style={{ overflowY: 'auto', flex: 1 }}>
                    {spawns.map((spawn, i) => (
                        <SpawnButton key={`spawn-${i}`} spawn={spawn} onSelect={handleSelect} index={i} />
                    ))}
                </Box>
            </Box>

            <Flex align="center" gap={12} style={{
                position: 'absolute',
                bottom: 0,
                left: 0,
                right: 0,
                zIndex: 30,
                padding: '14px 28px',
                justifyContent: 'center',
                background: 'transparent',
                borderTop: 'none',
            }}>
                <Button
                    variant="outline"
                    onClick={goBack}
                    leftSection={<FontAwesomeIcon icon="arrow-left" />}
                    style={{
                        padding: '11px 28px',
                        background: 'transparent',
                        border: `1px solid ${BORDER_SUBTLE}`,
                        borderRadius: 2,
                        color: TEXT_FAINT,
                        fontSize: 13,
                        fontWeight: 700,
                        letterSpacing: '0.15em',
                        textTransform: 'uppercase',
                        cursor: 'pointer',
                        transition: 'all 0.2s ease',
                        gap: 8,
                        '&:hover': {
                            borderColor: ACCENT,
                            color: TEXT_DIM,
                        },
                    }}
                >
                    Back
                </Button>
                {selected ? (
                    <Button
                        onClick={onSpawn}
                        color="brand"
                        style={{
                            padding: '11px 28px',
                            background: `rgba(255,141,36,0.15)`,
                            border: `1px solid ${ACCENT}`,
                            borderRadius: 2,
                            color: ACCENT,
                            fontSize: 13,
                            fontWeight: 700,
                            letterSpacing: '0.15em',
                            textTransform: 'uppercase',
                            cursor: 'pointer',
                            transition: 'all 0.2s ease',
                            display: 'flex',
                            alignItems: 'center',
                            gap: 8,
                        }}
                    >
                        <FontAwesomeIcon icon="location-dot" />
                        Spawn at {getLabel(selected)}
                    </Button>
                ) : (
                    <Text style={{
                        flex: 1,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: 11,
                        color: TEXT_FAINT,
                        letterSpacing: '0.1em',
                        fontStyle: 'italic',
                    }}>
                        Click a pin on the map or select from the list
                    </Text>
                )}
            </Flex>

            <style>{`
                @keyframes pinRipple {
                    0% { transform: translate(-50%, -50%) scale(0.5); opacity: 0.8; }
                    100% { transform: translate(-50%, -50%) scale(2.5); opacity: 0; }
                }
                @keyframes slideUp {
                    0% { opacity: 0; transform: translateY(10px); }
                    100% { opacity: 1; transform: translateY(0); }
                }
            `}</style>
        </Box>
    );
};
