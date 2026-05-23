import React, { useEffect, useMemo, useRef, useState } from 'react';
import { useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const ACTIVE_COLOR = '135, 218, 33';
const ARMOR_COLOR = '0, 178, 255';
const LOW_HEALTH_COLOR = '255, 0, 0';
const OVER_HEALTH_COLOR = '224, 254, 188';

const STATUS_META = {
    PLAYER_HUNGER: {
        id: 2,
        alwaysVisible: true,
        color: '255, 229, 0',
        icon: 'Salad',
        order: 5,
    },
    PLAYER_THIRST: {
        id: 3,
        alwaysVisible: true,
        color: '98, 234, 253',
        icon: 'GlassWater',
        order: 6,
    },
    PLAYER_STRESS: {
        id: 4,
        color: '181, 89, 254',
        icon: 'Brain',
        order: 4,
    },
};

const clamp = (value, min = 0, max = 1) => Math.min(max, Math.max(min, value));

const easeInOutExpo = (value) => {
    if (value === 0 || value === 1) return value;

    return value < 0.5
        ? Math.pow(2, 20 * value - 10) / 2
        : (2 - Math.pow(2, -20 * value + 10)) / 2;
};

const hexToRgb = (color, fallback = '255, 255, 255') => {
    if (!color || typeof color !== 'string') return fallback;

    const normalized = color.replace('#', '').trim();

    if (normalized.length !== 6) return fallback;

    const value = Number.parseInt(normalized, 16);

    if (!Number.isFinite(value)) return fallback;

    return `${(value >> 16) & 255}, ${(value >> 8) & 255}, ${value & 255}`;
};

const getNumber = (value, fallback = 0) => {
    const parsed = Number(value);

    return Number.isFinite(parsed) ? parsed : fallback;
};

const useAnimatedNumber = (value, duration = 1000) => {
    const [displayValue, setDisplayValue] = useState(value);
    const frameRef = useRef(null);

    useEffect(() => {
        window.cancelAnimationFrame(frameRef.current);

        const startTime = performance.now();
        const startValue = displayValue;
        const targetValue = value;

        const animate = (time) => {
            const progress = clamp((time - startTime) / duration);
            const eased = easeInOutExpo(progress);

            setDisplayValue(targetValue * eased + startValue * (1 - eased));

            if (progress < 1) {
                frameRef.current = window.requestAnimationFrame(animate);
            }
        };

        frameRef.current = window.requestAnimationFrame(animate);

        return () => window.cancelAnimationFrame(frameRef.current);
    }, [duration, value]);

    return displayValue;
};

const useStyles = makeStyles(() => ({
    '@keyframes blink': {
        '0%, 100%': {
            stroke: 'currentColor',
        },
        '50%': {
            stroke: 'transparent',
        },
    },
    '@keyframes blinkHeart': {
        '0%, 100%': {
            stroke: 'currentColor',
            fill: 'currentColor',
        },
        '50%': {
            stroke: 'transparent',
            fill: 'transparent',
        },
    },
    '@keyframes dyingShadow': {
        '0%, 100%': {
            boxShadow:
                '0 0 0.5em 0 rgba(255, 0, 0, 0.25), 0 0 1em 0 rgba(255, 0, 0, 0.35)',
        },
        '50%': {
            boxShadow:
                '0 0 0.5em 0 rgba(255, 0, 0, 0.5), 0 0 1em 0 rgba(255, 0, 0, 0.65)',
        },
    },
    '@keyframes dying': {
        '0%, 100%': {
            color: 'rgba(255, 0, 0, 0.5)',
            transform: 'scale(1)',
        },
        '50%': {
            color: 'red',
            transform: 'scale(1.25)',
        },
    },
    '@keyframes armorReveal': {
        '0%': {
            opacity: 0,
            transform: 'translateY(0.35em) scaleY(0.75)',
        },
        '100%': {
            opacity: 1,
            transform: 'translateY(0) scaleY(1)',
        },
    },
    status: {
        width: 'fit-content',
        fontSize: 'min(0.833333vw, 1.481481vh)',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        color: '#fff',
        pointerEvents: 'none',
    },
    hud: {
        display: 'flex',
        alignItems: 'center',
        gap: '1.35em',
    },
    col: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        gap: '0.25em',
        height: '3.375em',
    },
    barElement: {
        display: 'flex',
        gap: '0.82em',
        alignItems: 'center',
        position: 'relative',
        transition: 'opacity 0.35s ease, transform 0.35s ease',
    },
    armorElement: {
        transformOrigin: 'left bottom',
        animation: '$armorReveal 0.38s cubic-bezier(0.22, 1, 0.36, 1)',
    },
    data: {
        display: 'flex',
        gap: 'calc(0.25em / 0.725)',
        alignItems: 'center',
        fontSize: '0.725em',
        fontWeight: 500,
        lineHeight: '100%',

        '& p': {
            width: 'calc(1em / 0.725)',
            margin: 0,
            textShadow:
                '1px 1px 1px rgba(0, 0, 0, 0.5), 0 0 0.35em rgba(var(--dataGlow, 255, 255, 255), 0.22)',
        },

        '& svg': {
            height: 'calc(1em / 0.725)',
            width: 'calc(1em / 0.725)',
            color: 'rgba(255, 255, 255, 0.5)',
            fill: 'currentColor',
            stroke: 'currentColor',
            filter:
                'drop-shadow(0 0 0.18em rgba(var(--dataGlow, 255, 255, 255), 0.18))',
        },

        '& svg.dying': {
            animation: '$dying 2s infinite',
            color: 'rgba(255, 0, 0, 0.5)',
        },
    },
    progress: {
        width: '14.45em',
        transform: 'translateX(-0.42em)',
        transition: 'box-shadow 0.2s ease',

        '&.dyingShadow': {
            animation: '$dyingShadow 2s infinite',
        },

        '&.hit': {
            boxShadow:
                '0 0 0.5em 0 rgba(255, 0, 0, 0.9), 0 0 1em 0 rgba(255, 0, 0, 0.65)',
        },
    },
    separatedProgress: {
        width: '100%',
        height: '0.5625em',
        display: 'grid',
        gap: '0.25em',
        gridTemplateColumns: 'repeat(var(--parts), 1fr)',
    },
    progressPart: {
        position: 'relative',
        overflow: 'visible',
        borderRadius: '0.125em',
        border: '0.25px solid rgba(255, 255, 255, 0.1)',
        background: 'rgba(18, 18, 18, 0.6)',
    },
    innerPart: {
        width: '100%',
        height: '100%',
        background: 'rgb(var(--bg))',
        borderRadius: 'inherit',
        transform: 'scaleX(var(--val))',
        transformOrigin: 'left center',
        boxShadow:
            '0 0.25em 0.25em rgba(var(--bg), 0.18), 0 0.25em 0.85em rgba(var(--bg), 0.28)',
        transition: 'background 0.2s ease, box-shadow 0.2s ease',
    },
    overPart: {
        position: 'absolute',
        top: 0,
    },
    elements: {
        display: 'flex',
        alignItems: 'center',
        gap: '0.75em',
    },
    element: {
        display: 'flex',
        gap: '0.25em',
        alignItems: 'center',
        transition: 'opacity 0.35s ease, transform 0.35s ease',

        '& svg': {
            height: '1.25em',
            width: '1.25em',
            color: '#fff',
            fill: 'none',
            stroke: 'currentColor',
            transition: 'fill 0.2s ease, stroke 0.2s ease, color 0.2s ease',
        },

        '& svg.blink': {
            animation: '$blink 1s infinite',
        },
    },
    buffText: {
        minWidth: '1.25em',
        color: '#fff',
        fontSize: '0.85em',
        fontWeight: 600,
        lineHeight: 1,
        textAlign: 'center',
        textShadow: '0 0 0.25em rgba(var(--buffGlow), 255, 255, 255, 0.3)',
    },
    verticalProgress: {
        width: '0.1875em',
        height: '1.5em',
        borderRadius: '0.125em',
        background: 'rgba(48, 48, 48, 0.95)',
        overflow: 'visible',
    },
    verticalInternal: {
        width: '100%',
        height: '100%',
        transformOrigin: 'bottom center',
        transform: 'scaleY(var(--val))',
        background: 'rgb(var(--bg))',
        borderRadius: 'inherit',
        boxShadow:
            '0 0.25em 0.25em rgba(var(--bg), 0.18), 0 0.25em 0.8em rgba(var(--bg), 0.28)',
        transition: 'transform 0.5s ease, box-shadow 0.2s ease',
    },
}));

const Counter = ({ value }) => {
    const displayValue = useAnimatedNumber(value, 900);

    return <>{Math.round(displayValue)}</>;
};

const StatusIcon = ({ className, color, name, strokeWidth = 2 }) => {
    const props = {
        className,
        style: color ? { color } : undefined,
        viewBox: '0 0 24 24',
        fill: 'none',
        stroke: 'currentColor',
        strokeLinecap: 'round',
        strokeLinejoin: 'round',
        strokeWidth,
        xmlns: 'http://www.w3.org/2000/svg',
    };

    switch (name) {
        case 'Heart':
            return (
                <svg {...props}>
                    <path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z" />
                </svg>
            );
        case 'Shield':
            return (
                <svg {...props}>
                    <path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1Z" />
                </svg>
            );
        case 'Salad':
            return (
                <svg {...props}>
                    <path d="M7 21h10" />
                    <path d="M12 21a9 9 0 0 0 9-9H3a9 9 0 0 0 9 9Z" />
                    <path d="M11.38 12a2.4 2.4 0 0 0-.4-4.77 2.4 2.4 0 0 0-4.76.42A2.4 2.4 0 0 0 3 10.5c0 .56.19 1.08.5 1.5" />
                    <path d="M12.62 12a2.4 2.4 0 0 1 .4-4.77 2.4 2.4 0 0 1 4.76.42A2.4 2.4 0 0 1 21 10.5c0 .56-.19 1.08-.5 1.5" />
                </svg>
            );
        case 'GlassWater':
            return (
                <svg {...props}>
                    <path d="M15.2 22H8.8a2 2 0 0 1-2-1.79L5 3h14l-1.81 17.21A2 2 0 0 1 15.2 22Z" />
                    <path d="M6 12a5 5 0 0 1 6 0 5 5 0 0 0 6 0" />
                </svg>
            );
        case 'Brain':
            return (
                <svg {...props}>
                    <path d="M12 5a3 3 0 1 0-5.997.125 4 4 0 0 0-2.526 5.77 4 4 0 0 0 .556 6.588A4 4 0 1 0 12 18Z" />
                    <path d="M12 5a3 3 0 1 1 5.997.125 4 4 0 0 1 2.526 5.77 4 4 0 0 1-.556 6.588A4 4 0 1 1 12 18Z" />
                    <path d="M15 13a4.5 4.5 0 0 1-3-4 4.5 4.5 0 0 1-3 4" />
                    <path d="M17.599 6.5a3 3 0 0 0 .399-1.375" />
                    <path d="M6.003 5.125A3 3 0 0 0 6.401 6.5" />
                    <path d="M3.477 10.896a4 4 0 0 1 .585-.396" />
                    <path d="M19.938 10.5a4 4 0 0 1 .585.396" />
                    <path d="M6 18a4 4 0 0 1-1.967-.516" />
                    <path d="M19.967 17.484A4 4 0 0 1 18 18" />
                </svg>
            );
        default:
            return (
                <svg {...props}>
                    <circle cx="12" cy="12" r="8" />
                    <path d="M12 8v4" />
                    <path d="M12 16h.01" />
                </svg>
            );
    }
};

const SeparatedProgress = ({
    className,
    color,
    height,
    overColor,
    parts,
    showOver = false,
    value,
    width = '100%',
}) => {
    const classes = useStyles();
    const displayValue = useAnimatedNumber(value, 1000);
    const count = Math.max(1, Math.round(parts));

    return (
        <div
            className={`${classes.separatedProgress} ${className || ''}`}
            style={{
                '--parts': count,
                height,
                width,
            }}
        >
            {Array.from({ length: count }, (_, index) => {
                const size = 1 / count;
                const partValue = clamp((displayValue - index * size) / size);
                const overValue = showOver
                    ? clamp((displayValue - 1 - index * size) / size)
                    : 0;

                return (
                    <div
                        className={classes.progressPart}
                        key={index}
                        style={{ '--bg': color }}
                    >
                        <div
                            className={classes.innerPart}
                            style={{
                                '--val': partValue,
                            }}
                        />
                        {overValue > 0 && (
                            <div
                                className={`${classes.innerPart} ${classes.overPart}`}
                                style={{
                                    '--bg': overColor,
                                    '--val': overValue,
                                }}
                            />
                        )}
                    </div>
                );
            })}
        </div>
    );
};

const VerticalProgress = ({ color, value }) => {
    const classes = useStyles();
    const displayValue = useAnimatedNumber(value, 500);

    return (
        <div className={classes.verticalProgress} style={{ '--bg': color }}>
            <div
                className={classes.verticalInternal}
                style={{
                    '--val': clamp(displayValue),
                }}
            />
        </div>
    );
};

const getStatusValue = (status) => getNumber(status?.value);

const getStatusMax = (status) => {
    const max = getNumber(status?.options?.customMax ?? status?.max, 100);

    if (status?.name === 'PLAYER_STRESS' && max <= 1) {
        return 100;
    }

    return Math.max(1, max);
};

const isStatusInverted = (status) => {
    if (status?.name === 'PLAYER_STRESS') {
        return false;
    }

    return status?.options?.inverted || status.inverted;
};

const shouldShowStatus = (status, meta) => {
    const value = getStatusValue(status);
    const max = getStatusMax(status);
    const percent = clamp(value / max);
    const options = status?.options || {};

    if (meta.alwaysVisible) return true;
    if (options.hideZero && value <= 0) return false;
    if (options.hideHigh && percent >= 0.9) return false;

    return true;
};

const getSideStatus = (status) => {
    const meta = STATUS_META[status.name] || {};
    const max = getStatusMax(status);
    const value = getStatusValue(status);
    const color = meta.color || hexToRgb(status.color);
    const inverted = isStatusInverted(status);
    const progress = inverted ? clamp(1 - value / max) : clamp(value / max);

    return {
        color,
        hideProgress: meta.hideProgress || status?.options?.hideProgress,
        icon: meta.icon || status.icon,
        id: meta.id || status?.options?.id || status?.options?.order || 99,
        name: status.name,
        order: meta.order || status?.options?.order || 99,
        progress,
        value,
        visible: shouldShowStatus(status, meta),
    };
};

const getBuffStatus = (buff, buffDef, now) => {
    if (!buff || !buffDef) return null;

    let progress = 1;

    if (buffDef.type === 'timed') {
        const duration = getNumber(buff.val, getNumber(buffDef.duration));

        if (duration <= 0) return null;

        const elapsed = Math.max(0, now - getNumber(buff.startTime, now));
        const remaining = Math.max(0, duration - elapsed);

        if (remaining <= 0) return null;

        progress = clamp(remaining / duration);
    } else if (buffDef.type === 'value') {
        progress = clamp(getNumber(buff.val) / 100);
    }

    return {
        color: hexToRgb(buffDef.color, ACTIVE_COLOR),
        icon: buffDef.icon,
        name: buff.buff,
        override: buff.override,
        progress,
    };
};

export default () => {
    const classes = useStyles();

    const statuses = useSelector((state) => state.status.statuses);
    const isDead = useSelector((state) => state.status.isDead);
    const health = useSelector((state) => state.status.health);
    const maxHealth = useSelector((state) => state.status.maxHealth);
    const armor = useSelector((state) => state.status.armor);
    const buffDefs = useSelector((state) => state.status.buffDefs);
    const buffs = useSelector((state) => state.status.buffs);
    const lastHealth = useRef(health);
    const [hit, setHit] = useState(false);
    const [now, setNow] = useState(Math.floor(Date.now() / 1000));

    const healthPercent = isDead
        ? 0
        : clamp(getNumber(health) / Math.max(1, getNumber(maxHealth, 100)));
    const armorPercent = clamp(getNumber(armor) / 100);
    const healthColor = healthPercent < 0.1 ? LOW_HEALTH_COLOR : ACTIVE_COLOR;

    const sideStatuses = useMemo(
        () =>
            statuses
                .filter((status) => status.name !== 'radio-freq')
                .map(getSideStatus)
                .filter((status) => status.visible)
                .sort((a, b) => a.id - b.id || a.order - b.order),
        [statuses],
    );

    const sideBuffs = useMemo(
        () =>
            buffs
                .map((buff) => getBuffStatus(buff, buffDefs[buff?.buff], now))
                .filter(Boolean),
        [buffDefs, buffs, now],
    );

    useEffect(() => {
        if (health < lastHealth.current) {
            setHit(true);
            window.setTimeout(() => setHit(false), 350);
        }

        lastHealth.current = health;
    }, [health]);

    useEffect(() => {
        if (
            !buffs.some(
                (buff) => buffDefs[buff?.buff]?.type === 'timed',
            )
        ) {
            return undefined;
        }

        const interval = window.setInterval(() => {
            setNow(Math.floor(Date.now() / 1000));
        }, 1000);

        return () => window.clearInterval(interval);
    }, [buffDefs, buffs]);

    return (
        <div className={classes.status}>
            <div className={classes.hud}>
                <div className={classes.col}>
                    {armorPercent > 0.01 && (
                        <div
                            className={`${classes.barElement} ${classes.armorElement}`}
                        >
                            <div
                                className={classes.data}
                                style={{ '--dataGlow': ARMOR_COLOR }}
                            >
                                <StatusIcon name="Shield" />
                                <p style={{ color: '#00B2FF' }}>
                                    <Counter value={armor} />
                                </p>
                            </div>
                            <SeparatedProgress
                                className={classes.progress}
                                color={ARMOR_COLOR}
                                height="0.5625em"
                                parts={5}
                                value={armorPercent}
                                width="14.45em"
                            />
                        </div>
                    )}
                    <div className={classes.barElement}>
                        <div
                            className={classes.data}
                            style={{ '--dataGlow': healthColor }}
                        >
                            <StatusIcon
                                className={healthPercent < 0.1 ? 'dying' : ''}
                                name="Heart"
                            />
                            <p style={{ color: `rgb(${healthColor})` }}>
                                <Counter value={isDead ? 0 : health} />
                            </p>
                        </div>
                        <SeparatedProgress
                            className={`${classes.progress} ${
                                healthPercent < 0.1 ? 'dyingShadow' : ''
                            } ${hit ? 'hit' : ''}`}
                            color={healthColor}
                            height="0.5625em"
                            overColor={OVER_HEALTH_COLOR}
                            parts={1}
                            showOver
                            value={healthPercent}
                            width="14.45em"
                        />
                    </div>
                </div>
                <div className={classes.elements}>
                    {sideStatuses.map((status) => (
                        <div className={classes.element} key={status.name}>
                            {!status.hideProgress && (
                                <VerticalProgress
                                    color={status.color}
                                    value={status.progress}
                                />
                            )}
                            <StatusIcon
                                color="#fff"
                                name={status.icon}
                                strokeWidth={2}
                            />
                        </div>
                    ))}
                    {sideBuffs.map((buff) => (
                        <div
                            className={classes.element}
                            key={`buff-${buff.name}`}
                        >
                            <VerticalProgress
                                color={buff.color}
                                value={buff.progress}
                            />
                            {Boolean(buff.override) ? (
                                <span
                                    className={classes.buffText}
                                    style={{ '--buffGlow': buff.color }}
                                >
                                    {buff.override}
                                </span>
                            ) : (
                                <FontAwesomeIcon icon={buff.icon || 'circle'} />
                            )}
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};
