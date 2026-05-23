import React, { useMemo } from 'react';
import { useSelector } from 'react-redux';
import { Fade } from '@mui/material';
import { makeStyles } from '@mui/styles';

const MapIcon = () => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path d="m3 6 6-3 6 3 6-3v15l-6 3-6-3-6 3V6Z" />
        <path d="M9 3v15" />
        <path d="M15 6v15" />
    </svg>
);

const useStyles = makeStyles(() => ({
    section: {
        position: 'absolute',
        display: 'flex',
        alignItems: 'center',
        gap: '0.375rem',
        padding: '0.5rem 1rem',
        borderRadius: '0.75rem',
        background: 'rgba(0, 0, 0, 0.5)',
        transform: 'rotateY(8deg)',
        transformOrigin: 'left center',
        color: '#fff',
        pointerEvents: 'none',
        zIndex: 16,
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        perspective: '12rem',

        '& svg': {
            width: '1rem',
            height: '1rem',
            color: '#87da21',
            stroke: 'currentColor',
            strokeWidth: 2,
            strokeLinecap: 'round',
            strokeLinejoin: 'round',
            filter: 'drop-shadow(0 0 0.35rem rgba(135, 218, 33, 0.45))',
        },

        '& p': {
            margin: 0,
            color: '#fff',
            fontSize: '0.875rem',
            fontWeight: 500,
            lineHeight: '100%',
            whiteSpace: 'nowrap',
        },
    },
}));

export default () => {
    const classes = useStyles();
    const hudShowing = useSelector((state) => state.hud.showing);
    const vehicleShowing = useSelector((state) => state.vehicle.showing);
    const markerDist = useSelector((state) => state.vehicle.markerDist);
    const position = useSelector((state) => state.hud.position);
    const isBlindfolded = useSelector((state) => state.app.blindfolded);

    const distance = Number(markerDist);
    const visible =
        hudShowing && vehicleShowing && !isBlindfolded && Number(distance) > 0;

    const positionStyle = useMemo(() => {
        const leftX = Number(position?.leftX);
        const topY = Number(position?.topY);

        if (Number.isFinite(leftX) && Number.isFinite(topY)) {
            return {
                left: `${Math.max(0, leftX + 0.005) * 100}vw`,
                top: `${Math.max(0, topY - 0.025) * 100}vh`,
            };
        }

        return {
            left: '2.2vw',
            top: '77vh',
        };
    }, [position?.leftX, position?.topY]);

    return (
        <Fade in={visible} timeout={220} unmountOnExit>
            <div className={classes.section} style={positionStyle}>
                <MapIcon />
                <p>{`${Number.isFinite(distance) ? distance.toFixed(1) : markerDist} mil left`}</p>
            </div>
        </Fade>
    );
};
