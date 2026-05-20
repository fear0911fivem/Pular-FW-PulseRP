import React from 'react';
import { Fade } from '@mui/material';
import { makeStyles, withTheme } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { useSelector } from 'react-redux';

const STATUS_COLORS = {
    PLAYER_HUNGER: '#ffe500',
    PLAYER_THIRST: '#62eafd',
    PLAYER_STRESS: '#b559fe',
};

const hexToRgb = (color, fallback = '255, 255, 255') => {
    if (!color || typeof color !== 'string') return fallback;

    const rgbMatch = color.match(/rgba?\(([^)]+)\)/i);

    if (rgbMatch) return rgbMatch[1].split(',').slice(0, 3).join(',').trim();

    const normalized = color.replace('#', '').trim();

    if (normalized.length !== 6) return fallback;

    const value = Number.parseInt(normalized, 16);

    if (!Number.isFinite(value)) return fallback;

    return `${(value >> 16) & 255}, ${(value >> 8) & 255}, ${value & 255}`;
};

const getStatusColor = (status) => STATUS_COLORS[status?.name] || status.color;

const getStatusPercent = (status) =>
    Boolean(status?.options?.customMax)
        ? (status.value / status.options.customMax) * 100
        : status.value;

const getGlow = (color) => {
    const rgb = hexToRgb(color);

    return `0 0.25rem 0.25rem 0 rgba(${rgb}, 0.25), 0 0.25rem 1rem 0 rgba(${rgb}, 0.35)`;
};

const useStyles = makeStyles((theme) => ({
    '@keyframes glowFlash': {
        '0%, 100%': {
            boxShadow:
                '0 0 0.5rem 0 rgba(255, 0, 0, 0.25), 0 0 1rem 0 rgba(255, 0, 0, 0.35)',
        },
        '50%': {
            boxShadow:
                '0 0 0.5rem 0 rgba(255, 0, 0, 0.5), 0 0 1rem 0 rgba(255, 0, 0, 0.65)',
        },
    },
    container: {
        lineHeight: '25px',
        display: 'flex',
        transition: 'background 0.2s ease, border 0.2s ease',
        '&.low $bar': {
            animation: '$glowFlash linear 1s infinite',
        },
        '&.transparent': {
            background: `${theme.palette.secondary.dark}80`,
            border: `2px solid ${theme.palette.secondary.dark}80`,
        },
        '&.solid': {
            background: theme.palette.secondary.dark,
            border: `2px solid ${theme.palette.secondary.dark}`,
        },
    },
    icon: {
        width: 24,
        display: 'block',
        textAlign: 'center',
        fontSize: 14,
        borderRight: `1px solid ${theme.palette.border.divider}`,
    },
    barWrapper: {
        height: '100%',
        flex: 1,
    },
    bar: {
        height: '100%',
        transition:
            'width ease-in 0.15s, background 0.2s ease, box-shadow 0.2s ease',
    },
}));

export default withTheme(({ status }) => {
    const classes = useStyles();

    const config = useSelector((state) => state.hud.config);
    const isDead = useSelector((state) => state.status.isDead);

    if (
        (status.options.hideZero && status.value <= 0) ||
        (status.value >= (Boolean(status?.options?.customMax) ? status?.options?.customMax / 0.9 : 90) && status?.options?.hideHigh) ||
        (status.value == 0 && status?.options?.hideZero) ||
        (isDead && !status?.options?.visibleWhileDead)
    )
        return null;

    const color = getStatusColor(status);
    const percent = getStatusPercent(status);
    const isLow =
        (((!status.inverted && percent <= 10) ||
            (status.inverted && percent >= 90)) &&
            status.flash) ||
        status?.options?.critical;

    return (
        <Fade in={true}>
            <div
                className={`${classes.container} ${
                    isLow
                        ? ' low'
                        : ''
                } ${config.transparentBg ? 'transparent' : 'solid'}`}
                style={{ width: config.largeBars ? 124.5 : 81 }}
            >
                <div className={classes.icon}>
                    <FontAwesomeIcon
                        icon={status.icon}
                        className={classes.iconTxt}
                    />
                </div>
                <div className={classes.barWrapper}>
                    <div
                        className={classes.bar}
                        style={{
                            background: color,
                            boxShadow: getGlow(color),
                            width: `${percent}%`,
                        }}
                    ></div>
                </div>
            </div>
        </Fade>
    );
});
