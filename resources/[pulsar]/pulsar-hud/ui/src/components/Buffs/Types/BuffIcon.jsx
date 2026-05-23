import React from 'react';
import { useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const hexToRgb = (color, fallback = '135, 218, 33') => {
    if (!color || typeof color !== 'string') return fallback;

    const normalized = color.replace('#', '').trim();

    if (normalized.length !== 6) return fallback;

    const value = Number.parseInt(normalized, 16);

    if (!Number.isFinite(value)) return fallback;

    return `${(value >> 16) & 255}, ${(value >> 8) & 255}, ${value & 255}`;
};

const clamp = (value, min = 0, max = 100) =>
    Math.min(max, Math.max(min, Number(value) || 0));

const useStyles = makeStyles(() => ({
    container: {
        width: '2.35rem',
        minHeight: '2.35rem',
        display: 'flex',
        flexDirection: 'column',
        gap: '.25rem',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        pointerEvents: 'none',
    },
    icon: {
        position: 'relative',
        width: '2.35rem',
        height: '2.35rem',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        overflow: 'hidden',
        borderRadius: '.25rem',
        border: '1px solid rgba(255, 255, 255, 0.15)',
        background: 'rgba(26, 31, 20, 0.78)',
        color: 'rgb(var(--buff-rgb))',
        boxShadow:
            '0 .25rem .75rem rgba(var(--buff-rgb), 0.16), inset 0 0 0 1px rgba(0, 0, 0, 0.25)',

        '&:before': {
            content: '""',
            position: 'absolute',
            inset: 0,
            background:
                'linear-gradient(180deg, rgba(var(--buff-rgb), 0.16), transparent 58%)',
            opacity: 0.8,
        },

        '&:after': {
            content: '""',
            position: 'absolute',
            left: '.35rem',
            right: '.35rem',
            bottom: '.25rem',
            height: '.125rem',
            borderRadius: '.125rem',
            background: 'rgb(var(--buff-rgb))',
            boxShadow: '0 0 .45rem rgba(var(--buff-rgb), 0.45)',
        },
    },
    fa: {
        position: 'relative',
        zIndex: 1,
        fontSize: '1.1rem',
        color: '#fff',
        filter: 'drop-shadow(0 0 .22rem rgba(var(--buff-rgb), 0.35))',
    },
    txt: {
        position: 'relative',
        zIndex: 1,
        color: '#fff',
        fontSize: '.8rem',
        lineHeight: 1,
        fontWeight: 600,
        textShadow: '0 0 .35rem rgba(var(--buff-rgb), 0.55)',
    },
    progressTrack: {
        width: '100%',
        height: '.1875rem',
        borderRadius: '.125rem',
        border: '.25px solid rgba(255, 255, 255, 0.12)',
        background: 'rgba(18, 18, 18, 0.6)',
        overflow: 'hidden',
    },
    progressFill: {
        width: '100%',
        height: '100%',
        borderRadius: 'inherit',
        background: 'rgb(var(--buff-rgb))',
        boxShadow:
            '0 .25rem .25rem rgba(var(--buff-rgb), 0.25), 0 .25rem 1rem rgba(var(--buff-rgb), 0.35)',
        transform: 'scaleX(var(--progress))',
        transformOrigin: 'left center',
        transition: 'transform .25s ease',
    },
}));

export default ({ buff, progress }) => {
    const classes = useStyles();
    const buffDefs = useSelector((state) => state.status.buffDefs);
    const buffDef = buffDefs[buff?.buff] || {};
    const rgb = hexToRgb(buffDef.color);
    const hasProgress = progress !== undefined && progress !== null;

    return (
        <div
            className={classes.container}
            style={{
                '--buff-rgb': rgb,
                '--progress': clamp(progress) / 100,
            }}
        >
            <div className={classes.icon}>
                {Boolean(buff?.override) ? (
                    <span className={classes.txt}>{buff.override}</span>
                ) : (
                    <FontAwesomeIcon
                        className={classes.fa}
                        icon={buffDef.icon || 'circle'}
                    />
                )}
            </div>
            {hasProgress && (
                <div className={classes.progressTrack}>
                    <div className={classes.progressFill} />
                </div>
            )}
        </div>
    );
};
