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

const getGlow = (color) => {
    const rgb = hexToRgb(color);

    return `0 0.25rem 0.25rem 0 rgba(${rgb}, 0.25), 0 0.25rem 1rem 0 rgba(${rgb}, 0.35)`;
};

const useStyles = makeStyles((theme) => ({
    '@keyframes flash': {
        '0%': {
            opacity: 1,
        },
        '50%': {
            opacity: 0.1,
        },
        '100%': {
            opacity: 1,
        },
    },
    container: {
        paddingLeft: 5,
        lineHeight: '25px',
        display: 'flex',
        transition: 'background 0.2s ease, box-shadow 0.2s ease',
        '&.transparent': {
            background: `${theme.palette.secondary.dark}80`,
        },
        '&.solid': {
            background: theme.palette.secondary.dark,
        },
    },
    icon: {
        width: 24,
        display: 'block',
        fontSize: 18,
        padding: (data) =>
            Boolean(data.status?.options?.force) &&
            data.status.options.force != data.config.statusType
                ? 0
                : 5,
        paddingLeft: '0 !important',
        borderRight: `1px solid ${theme.palette.border.divider}`,
    },
    number: {
        fontSize: 18,
        lineHeight: (data) =>
            Boolean(data.status?.options?.force) &&
            data.status.options.force != data.config.statusType
                ? '24px'
                : '34px',
        flex: 1,
        textAlign: 'center',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
        '&.low': {
            animation: '$flash linear 1s infinite',
        },
    },
}));

export default withTheme(({ status }) => {
    const config = useSelector((state) => state.hud.config);
    const isDead = useSelector((state) => state.status.isDead);
    const classes = useStyles({ status, config });

    if (
        (status.options.hideZero && status.value <= 0) ||
        (status.value >= 90 && status?.options?.hideHigh) ||
        (status.value == 0 && status?.options?.hideZero) ||
        (isDead && !status?.options?.visibleWhileDead)
    )
        return null;

    const color = getStatusColor(status);

    return (
        <Fade in={true}>
            <div
                className={`${classes.container}${
                    Boolean(status?.options?.force) &&
                    status.options.force != config.statusType &&
                    !config.transparentBg
                        ? ' solid'
                        : ' transparent'
                }`}
                style={{
                    borderLeft: `4px solid ${color}`,
                    boxShadow: getGlow(color),
                    width:
                        Boolean(status?.options?.force) &&
                        status.options.force != config.statusType &&
                        config.largeBars
                            ? 124.5
                            : 81,
                }}
            >
                <div className={classes.icon}>
                    <FontAwesomeIcon
                        icon={status.icon}
                        className={classes.iconTxt}
                    />
                </div>
                <div
                    className={`${classes.number} ${
                        ((!status.inverted && status.value <= 10) ||
                            (status.inverted && status.value >= 90)) &&
                        status.flash
                            ? ' low'
                            : ''
                    }`}
                >
                    {status.value}
                </div>
            </div>
        </Fade>
    );
});
