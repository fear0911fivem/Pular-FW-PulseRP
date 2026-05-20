import React, { useEffect, useMemo, useState } from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { makeStyles } from '@mui/styles';
import { useSelector } from 'react-redux';

const VOICE_COUNT = 7;
const VOLUME_COUNT = 3;
const ACTIVE_COLOR = '135, 218, 33';
const RADIO_COLOR = '0, 178, 255';

const clamp = (value, min = 0, max = 1) => Math.min(max, Math.max(min, value));

const useStyles = makeStyles(() => ({
    voiceWrapper: {
        display: 'flex',
        flexDirection: 'column',
        gap: '0.6875rem',
        width: '2.125rem',
        position: 'relative',
        margin: '0 auto',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        pointerEvents: 'none',
    },
    indicator: {
        position: 'absolute',
        top: 0,
        left: '50%',
        transform: 'translate(-50%, calc(-100% - 0.5rem))',

        '& svg': {
            height: '1.5rem',
            width: '1.5rem',
            color: '#87da21',
            filter: 'drop-shadow(0 0.25rem 1rem rgba(135, 218, 33, 0.35))',
        },
    },
    voiceBars: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        height: '2rem',
    },
    voiceBar: {
        width: 3,
        height: 'var(--height)',
        borderRadius: 2,
        background: '#545454',
        transition:
            'height 0.1s ease, background 0.2s ease, box-shadow 0.2s ease',

        '&.fake': {
            transition:
                'height 0.2s ease, background 0.2s ease, box-shadow 0.2s ease',
        },

        '&.active': {
            background: '#87da21',
            boxShadow:
                '0 0.25rem 0.25rem 0 rgba(135, 218, 33, 0.25), 0 0.25rem 1rem 0 rgba(135, 218, 33, 0.35)',
        },

        '&.radio': {
            background: '#00b2ff',
            boxShadow:
                '0 0.25rem 0.25rem 0 rgba(0, 178, 255, 0.25), 0 0.25rem 1rem 0 rgba(0, 178, 255, 0.35)',
        },
    },
    voiceProg: {
        display: 'grid',
        gridTemplateColumns: `repeat(${VOLUME_COUNT}, 1fr)`,
        gap: '0.125rem',
        width: '100%',
        height: '0.3125rem',
    },
    part: {
        position: 'relative',
        overflow: 'hidden',
        borderRadius: '0.125rem',
        border: '0.25px solid rgba(255, 255, 255, 0.25)',
        background: 'rgba(18, 18, 18, 0.5)',
    },
    innerPart: {
        width: '100%',
        height: '100%',
        transform: 'scaleX(var(--val))',
        transformOrigin: 'left center',
        background: 'rgb(var(--bg))',
        borderRadius: 'inherit',
        boxShadow:
            '0 0.25rem 0.25rem 0 rgba(var(--bg), 0.25), 0 0.25rem 1rem 0 rgba(var(--bg), 0.35)',
        transition:
            'transform 0.35s ease, background 0.2s ease, box-shadow 0.2s ease',
    },
}));

const getIndicatorIcon = (icon) => {
    switch (icon) {
        case 'walkie-talkie':
            return 'walkie-talkie';
        case 'phone-volume':
            return 'phone-volume';
        case 'megaphone':
            return 'bullhorn';
        case 'microphone-stand':
            return 'microphone-lines';
        default:
            return null;
    }
};

const VoiceBar = ({ isTalking, isRadio, value }) => {
    const classes = useStyles();
    const height = isTalking ? 0.5 + 1.5 * value : 0.5;

    return (
        <div
            className={`${classes.voiceBar}${isTalking ? ' active fake' : ''}${
                isRadio ? ' radio' : ''
            }`}
            style={{ '--height': `${height}rem` }}
        />
    );
};

const VoiceProgress = ({ level, isRadio }) => {
    const classes = useStyles();
    const color = isRadio ? RADIO_COLOR : ACTIVE_COLOR;

    return (
        <div className={classes.voiceProg}>
            {Array.from({ length: VOLUME_COUNT }, (_, index) => (
                <div className={classes.part} key={`voice-part-${index}`}>
                    <div
                        className={classes.innerPart}
                        style={{
                            '--bg': color,
                            '--val': clamp(level - index),
                        }}
                    />
                </div>
            ))}
        </div>
    );
};

export default () => {
    const classes = useStyles();
    const voip = useSelector((state) => state.hud.voip);
    const talking = useSelector((state) => state.hud.talking);
    const voipIcon = useSelector((state) => state.hud.voipIcon);
    const [voiceValues, setVoiceValues] = useState(
        new Array(VOICE_COUNT).fill(0),
    );

    const level = clamp(Number(voip) || 0, 0, VOLUME_COUNT);
    const talkingState = Number(talking) || 0;
    const isTalking = talking === true || talkingState > 0;
    const isRadio = talkingState === 2;
    const indicatorIcon = useMemo(() => getIndicatorIcon(voipIcon), [voipIcon]);

    useEffect(() => {
        if (!isTalking) {
            setVoiceValues(new Array(VOICE_COUNT).fill(0));
            return undefined;
        }

        let timeout;
        let mounted = true;

        const queueNextFrame = () => {
            timeout = window.setTimeout(() => {
                if (!mounted) return;

                setVoiceValues((values) => values.map(() => Math.random()));
                queueNextFrame();
            }, 100 * Math.random() + 200);
        };

        setVoiceValues((values) => values.map(() => Math.random()));
        queueNextFrame();

        return () => {
            mounted = false;
            window.clearTimeout(timeout);
        };
    }, [isTalking]);

    return (
        <div className={classes.voiceWrapper}>
            {indicatorIcon && (
                <div className={classes.indicator}>
                    <FontAwesomeIcon icon={indicatorIcon} />
                </div>
            )}
            <div className={classes.voiceBars}>
                {voiceValues.map((value, index) => (
                    <VoiceBar
                        isRadio={isRadio}
                        isTalking={isTalking}
                        key={`voice-bar-${index}`}
                        value={value}
                    />
                ))}
            </div>
            <VoiceProgress isRadio={isRadio} level={level} />
        </div>
    );
};
