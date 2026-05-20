import React, { useMemo } from 'react';
import { Avatar, CircularProgress, Fade } from '@mui/material';
import { makeStyles, withTheme } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { useSelector } from 'react-redux';

const VOIP_COLORS = {
    normal: '#a7a7a7',
    talking: '#87da21',
    radio: '#00b2ff',
};

const hexToRgb = (color, fallback = '255, 255, 255') => {
    if (!color || typeof color !== 'string') return fallback;

    const normalized = color.replace('#', '').trim();

    if (normalized.length !== 6) return fallback;

    const value = Number.parseInt(normalized, 16);

    if (!Number.isFinite(value)) return fallback;

    return `${(value >> 16) & 255}, ${(value >> 8) & 255}, ${value & 255}`;
};

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
        color: VOIP_COLORS.normal,
        transition: 'filter 0.2s ease, color 0.2s ease',

        '&.talking': {
            color: VOIP_COLORS.talking,
        },
        '&.radio': {
            color: VOIP_COLORS.radio,
        },
    },
    background: {
        position: 'absolute',
        height: 45,
        width: 45,
        top: 0,
        bottom: 0,
        right: 0,
        left: 0,
        zIndex: -1,
        background: theme.palette.secondary.dark,
        color: theme.palette.text.main,
        fontSize: 16,
        boxShadow:
            '0 0.25rem 0.75rem rgba(0, 0, 0, 0.45), inset 0 0 0.75rem rgba(255, 255, 255, 0.035)',
    },
    number: {
        fontSize: '0.75rem',
    },
}));

export default withTheme(() => {
    const classes = useStyles();

    const statuses = useSelector((state) => state.status.statuses);

    const radioFreq = useMemo(
        () => statuses.filter((s) => s.name == 'radio-freq')[0],
        [statuses],
    );

    const voip = useSelector((state) => state.hud.voip);
    const voipIcon = useSelector((state) => state.hud.voipIcon);
    const config = useSelector((state) => state.hud.config);
    const isTalking = useSelector((state) => state.hud.talking);

    const getTalkingLevel = () => {
        switch (voip) {
            case 1:
                return 33.333;
            case 2:
                return 66.666;
            case 3:
                return 100.0;
        }
    };

    const voipColor =
        isTalking == 2
            ? VOIP_COLORS.radio
            : isTalking == 1
            ? VOIP_COLORS.talking
            : VOIP_COLORS.normal;

    return (
        <Fade in={true}>
            <div className={classes.status}>
                <CircularProgress
                    className={`${classes.bar}${
                        isTalking == 1
                            ? ' talking'
                            : isTalking == 2
                            ? ' radio'
                            : ''
                    }`}
                    variant="determinate"
                    value={getTalkingLevel()}
                    thickness={5}
                    size={45}
                    style={{
                        color: voipColor,
                        filter: getGlow(voipColor),
                    }}
                />
                <Avatar className={classes.background}>
                    {Boolean(radioFreq) && radioFreq.value > 0 ? (
                        config.maskRadio ? (
                            <FontAwesomeIcon icon={voipIcon} />
                        ) : (
                            <span className={classes.number}>
                                {radioFreq.value}
                            </span>
                        )
                    ) : (
                        <FontAwesomeIcon icon={voipIcon ?? 'microphone'} />
                    )}
                </Avatar>
            </div>
        </Fade>
    );
});
