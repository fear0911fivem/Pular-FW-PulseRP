import React from 'react';
import { Avatar, CircularProgress, Fade } from '@mui/material';
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

    return `drop-shadow(0 0.25rem 0.25rem rgba(${rgb}, 0.25)) drop-shadow(0 0.25rem 1rem rgba(${rgb}, 0.35))`;
};

const useStyles = makeStyles((theme) => ({
    status: {
        position: 'relative',
        height: 45,
        width: 45,
    },
    bar: {
        position: 'absolute',
        height: 45,
        width: 45,
        top: 0,
        bottom: 0,
        right: 0,
        left: 0,
        margin: 'auto',
        transition: 'filter 0.2s ease, color 0.2s ease',
    },
    background: {
        position: 'absolute',
        height: 45,
        width: 45,
        top: 0,
        bottom: 0,
        right: 0,
        left: 0,
        margin: 'auto',
        zIndex: -1,
        background: theme.palette.secondary.dark,
        color: theme.palette.text.main,
        fontSize: 16,
        boxShadow:
            '0 0.25rem 0.75rem rgba(0, 0, 0, 0.45), inset 0 0 0.75rem rgba(255, 255, 255, 0.035)',
    },
    number: {
        zIndex: 1,

        '& svg': {
            display: 'block',
            width: 22,
            height: 22,
            fontSize: 22,
            position: 'absolute',
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            margin: 'auto',
            zIndex: 0,

            '&.faded': {
                opacity: 0.17,
            },
        },
    },
}));

export default withTheme(({ status }) => {
    const config = useSelector((state) => state.hud.config);
    const isDead = useSelector((state) => state.status.isDead);
    const classes = useStyles({ status, config });

    if (
        (status.options.hideZero && status.value <= 0) ||
        (status.value >=
            (Boolean(status?.options?.customMax)
                ? status?.options?.customMax / 0.9
                : 90) &&
            status?.options?.hideHigh) ||
        (status.value == 0 && status?.options?.hideZero) ||
        (isDead && !status?.options?.visibleWhileDead)
    )
        return null;

    const color = getStatusColor(status);
    const percent = getStatusPercent(status);

    return (
        <Fade in={true}>
            <div className={classes.status}>
                <CircularProgress
                    className={classes.bar}
                    variant="determinate"
                    value={percent}
                    thickness={5}
                    size={45}
                    style={{
                        color,
                        filter: getGlow(color),
                    }}
                />
                <Avatar className={classes.background}>
                    {config.circleNumbers && !status?.options?.forceIcon ? (
                        <span className={classes.number}>
                            {status.value}
                            <FontAwesomeIcon
                                className="faded"
                                icon={status.icon}
                            />
                        </span>
                    ) : (
                        <FontAwesomeIcon icon={status.icon} />
                    )}
                </Avatar>
            </div>
        </Fade>
    );
});
