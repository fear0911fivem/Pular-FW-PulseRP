import React, { useEffect, useMemo, useRef, useState } from 'react';
import { useSelector } from 'react-redux';
import { Fade } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import VOIP from '../../Status/components/VOIP';
import Ammo from '../../Ammo';
import EngineWarningIcon from '../components/EngineWarningIcon';

const ACTIVE_RGB = [135, 218, 33];
const WARNING_RGB = [255, 0, 0];
const FUEL_RGB = [255, 153, 0];
const NOS_RGB = [0, 178, 255];
const MAX_RPM = 7;

const clamp = (value, min = 0, max = 1) => Math.min(max, Math.max(min, value));

const smoothValue = (current, target, delta, speed = 14) => {
    const next =
        current + (target - current) * (1 - Math.exp((-speed * delta) / 1000));

    return Math.abs(next - target) < 0.001 ? target : next;
};

const getUnit = (element) => {
    if (typeof window === 'undefined' || !element) return 16;

    const size = parseFloat(window.getComputedStyle(element).fontSize);

    return Number.isFinite(size) ? size : 16;
};

const em = (element, value) => value * getUnit(element);

const rgb = (color) => `rgb(${color.join(', ')})`;

const rgba = (color, alpha) => `rgba(${color.join(', ')}, ${alpha})`;

const blendColor = (from, to, amount) => {
    const eased = clamp(amount);

    return from.map((value, index) =>
        Math.floor(
            Math.pow(
                Math.sqrt(value / 255) * (1 - eased) +
                    Math.sqrt(to[index] / 255) * eased,
                2,
            ) * 255,
        ),
    );
};

const getRpmColor = (rpm) =>
    rpm > 0.9
        ? blendColor(ACTIVE_RGB, WARNING_RGB, (rpm - 0.9) / 0.05)
        : ACTIVE_RGB;

const getCanvasSize = (canvas) => {
    const rect = canvas.getBoundingClientRect();

    return {
        width: Math.max(1, Math.round(rect.width)),
        height: Math.max(1, Math.round(rect.height)),
    };
};

const drawGauge = (canvas, { rpm, nos }) => {
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const { width, height } = getCanvasSize(canvas);

    if (canvas.width !== width) canvas.width = width;
    if (canvas.height !== height) canvas.height = height;

    ctx.clearRect(0, 0, width, height);
    ctx.save();
    ctx.translate(width / 2, height / 2);

    const trackWidth = em(canvas, 0.5);
    const inset = em(canvas, 2);
    const radius = width / 2 - 2 * trackWidth - inset;
    const startAngle = (-5 * Math.PI) / 4;
    const endAngle = Math.PI / 4;
    const arcSize = endAngle - startAngle;
    const value = clamp(Number(rpm) || 0);
    const progressAngle = startAngle + value * arcSize;
    const tickExtra = em(canvas, 0.25);
    const maxTick = MAX_RPM + 1;

    const trackGradient = ctx.createLinearGradient(0, 0, width, height);
    trackGradient.addColorStop(0, '#000000A0');
    trackGradient.addColorStop(0.55, 'transparent');

    ctx.strokeStyle = trackGradient;
    ctx.lineWidth = trackWidth;
    ctx.lineCap = 'butt';
    ctx.beginPath();
    ctx.arc(0, 0, radius, startAngle, endAngle);
    ctx.stroke();
    ctx.closePath();

    if (value > 0) {
        const color = getRpmColor(value);

        ctx.save();
        ctx.strokeStyle = rgb(color);
        ctx.shadowColor = rgb(color);
        ctx.shadowBlur = 10;
        ctx.lineCap = 'butt';
        ctx.lineWidth = trackWidth;
        ctx.beginPath();
        ctx.arc(0, 0, radius, startAngle, progressAngle);
        ctx.stroke();

        ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
        ctx.shadowColor = 'rgba(255, 255, 255, 1)';
        ctx.shadowBlur = 5;
        ctx.stroke();
        ctx.closePath();
        ctx.restore();
    }

    for (let index = 0; index < maxTick; index += 1) {
        const percentage = index / (maxTick - 1);
        const angle = startAngle + percentage * arcSize;
        const x = Math.cos(angle);
        const y = Math.sin(angle);
        const base = radius - trackWidth + 2;
        const outer = base + trackWidth + tickExtra;
        const label = String(index);
        const textX = (radius - em(canvas, 1.25)) * x;
        const textY = (radius - em(canvas, 1.25)) * y;

        ctx.strokeStyle = 'rgba(255, 255, 255, 0.85)';
        ctx.lineWidth = tickExtra;
        ctx.lineCap = 'round';
        ctx.beginPath();
        ctx.moveTo(x * base, y * base);
        ctx.lineTo(x * outer, y * outer);
        ctx.stroke();
        ctx.closePath();

        ctx.font = `500 ${em(canvas, 0.75)}px Bai Jamjuree, Arial, sans-serif`;
        ctx.fillStyle = 'rgba(255, 255, 255, 0.75)';

        const metrics = ctx.measureText(label);
        const ascent = metrics.actualBoundingBoxAscent || em(canvas, 0.75);

        ctx.fillText(label, textX - metrics.width / 2, textY + ascent / 2);
    }

    const nitro = clamp((Number(nos) || 0) / 100);

    if (nitro > 0) {
        const nitroWidth = em(canvas, 0.25);
        const nitroRadius = radius + trackWidth + em(canvas, 0.75);
        const nitroStart = startAngle + Math.PI / 8;
        const nitroEnd = -Math.PI / 2 - Math.PI / 16;
        const burstStart = -Math.PI / 2 + Math.PI / 16;
        const burstEnd = endAngle - Math.PI / 8;

        ctx.save();
        ctx.lineCap = 'round';
        ctx.lineWidth = nitroWidth;
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
        ctx.beginPath();
        ctx.arc(0, 0, nitroRadius, nitroStart, nitroEnd);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(0, 0, nitroRadius, burstStart, burstEnd);
        ctx.stroke();

        ctx.strokeStyle = rgb(NOS_RGB);
        ctx.shadowColor = rgba(NOS_RGB, 0.6);
        ctx.shadowBlur = 8;
        ctx.beginPath();
        ctx.arc(
            0,
            0,
            nitroRadius,
            nitroStart,
            nitroStart + (nitroEnd - nitroStart) * nitro,
        );
        ctx.stroke();

        ctx.strokeStyle = rgb(ACTIVE_RGB);
        ctx.shadowColor = rgba(ACTIVE_RGB, 0.6);
        ctx.beginPath();
        ctx.arc(
            0,
            0,
            nitroRadius,
            burstStart,
            burstStart + (burstEnd - burstStart) * nitro,
        );
        ctx.stroke();
        ctx.restore();
    }

    ctx.restore();
};

const useStyles = makeStyles(() => ({
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
    hudRight: {
        position: 'absolute',
        bottom: '2.5em',
        right: '2.75em',
        height: '5em',
        display: 'flex',
        flexDirection: 'row-reverse',
        alignItems: 'flex-end',
        gap: 0,
        fontSize: 'min(0.9vw, 1.6vh)',
        pointerEvents: 'none',
    },
    carAnchor: {
        height: '5em',
        transformOrigin: 'right center',
        transform: 'rotateY(-8deg)',
        display: 'flex',
        alignItems: 'flex-end',
    },
    carHud: {
        width: '17.375em',
        height: '17.4375em',
        color: '#fff',
        position: 'relative',
        top: '2em',
        margin: '0 -1em',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
    },
    canvas: {
        position: 'absolute',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
    },
    nitroIcons: {
        width: '100%',
        display: 'flex',
        justifyContent: 'space-between',
        position: 'absolute',
        bottom: '18%',
        left: 0,
        transform: 'translateY(-50%)',
        padding: '0 1.5em',
        color: '#87da21',

        '& svg': {
            fontSize: '1.25em',
            filter: 'drop-shadow(0 0 0.5em rgba(135, 218, 33, 0.5))',
        },
    },
    center: {
        position: 'absolute',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '0.5em',
    },
    speed: {
        color: '#fff',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '3.5em',
        fontWeight: 400,
        lineHeight: '100%',
        width: '5em',
        textAlign: 'center',
        margin: 0,
        textShadow: '0 0.25em 1em rgba(0, 0, 0, 0.45)',
    },
    unit: {
        color: 'rgba(255, 255, 255, 0.75)',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '1.5em',
        fontWeight: 400,
        lineHeight: '100%',
        margin: 0,
        textTransform: 'uppercase',
        textShadow: '0 0.25em 1em rgba(0, 0, 0, 0.45)',
    },
    checkEngine: {
        width: '1.5em',
        height: '1.5em',
        color: '#ff4040',
        fontSize: '1.25em',
        filter: 'drop-shadow(0 0 0.5em rgba(255, 0, 0, 0.55))',
        animation: '$flash linear 1s infinite',
    },
    controls: {
        position: 'absolute',
        bottom: '1.875em',
        left: '50%',
        transform: 'translateX(-50%)',
        display: 'flex',
        justifyContent: 'center',
        gap: '0.5em',
    },
    control: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        gap: 0,
        color: '#fff',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '1em',
        fontWeight: 400,
        lineHeight: '100%',
        textShadow: '0 0.25em 1em rgba(0, 0, 0, 0.5)',
        minWidth: '1.75em',
    },
    horizontalProgress: {
        height: '0.1875em',
        width: '1.5em',
        borderRadius: '0.125em',
        background: 'rgba(48, 48, 48, 0.95)',
        marginTop: '0.1875em',
        overflow: 'hidden',
    },
    internal: {
        width: '100%',
        height: '100%',
        transformOrigin: 'left center',
        transform: 'scaleX(var(--val))',
        background: 'rgb(var(--bg))',
        borderRadius: 'inherit',
        boxShadow:
            '0 0.25em 0.25em 0 rgba(var(--bg), 0.25), 0 0.25em 1em 0 rgba(var(--bg), 0.35)',
        transition: 'transform 0.5s ease',
    },
}));

const HorizontalProgress = ({ color, value }) => {
    const classes = useStyles();

    return (
        <div className={classes.horizontalProgress}>
            <div
                className={classes.internal}
                style={{
                    '--bg': color.join(', '),
                    '--val': clamp(value),
                }}
            />
        </div>
    );
};

export default () => {
    const classes = useStyles();
    const canvasRef = useRef(null);
    const targetValuesRef = useRef({ rpm: 0, nos: 0, speed: 0 });
    const animatedValuesRef = useRef({ rpm: 0, nos: 0, speed: 0 });
    const displayedSpeedRef = useRef(0);
    const [animatedSpeed, setAnimatedSpeed] = useState(0);

    const showing = useSelector((state) => state.vehicle.showing);
    const ignition = useSelector((state) => state.vehicle.ignition);
    const speed = useSelector((state) => state.vehicle.speed);
    const speedMeasure = useSelector((state) => state.vehicle.speedMeasure);
    const seatbelt = useSelector((state) => state.vehicle.seatbelt);
    const checkEngine = useSelector((state) => state.vehicle.checkEngine);
    const seatbeltHide = useSelector((state) => state.vehicle.seatbeltHide);
    const fuelHide = useSelector((state) => state.vehicle.fuelHide);
    const fuel = useSelector((state) => state.vehicle.fuel);
    const rpm = useSelector((state) => state.vehicle.rpm);
    const nos = useSelector((state) => state.vehicle.nos);
    const aircraftData = useSelector((state) => state.vehicle.aircraftData);

    const hasNos = ignition && Number(nos) > 0;
    const isAircraft = Boolean(aircraftData);
    const controlColor = ignition ? ACTIVE_RGB : WARNING_RGB;
    const displaySpeed = ignition ? animatedSpeed : 0;

    const controls = useMemo(() => {
        const items = [];

        if (!fuelHide) {
            items.push({
                label: 'FUEL',
                color: FUEL_RGB,
                value: clamp((Number(fuel) || 0) / 100),
            });
        }

        items.push({
            label: 'ENG',
            color: controlColor,
            value: ignition ? 1 : 0,
        });

        if (!seatbeltHide) {
            items.push({
                label: 'BELT',
                color: seatbelt ? ACTIVE_RGB : WARNING_RGB,
                value: seatbelt ? 1 : 0,
            });
        }

        if (hasNos) {
            items.push({
                label: 'FLOW',
                color: NOS_RGB,
                value: clamp((Number(nos) || 0) / 100),
            });
        }

        return items;
    }, [
        controlColor,
        fuel,
        fuelHide,
        hasNos,
        ignition,
        nos,
        seatbelt,
        seatbeltHide,
    ]);

    useEffect(() => {
        targetValuesRef.current = {
            rpm: ignition ? clamp(Number(rpm) || 0) : 0,
            nos: hasNos ? Number(nos) || 0 : 0,
            speed: ignition ? Number(speed) || 0 : 0,
        };
    }, [hasNos, ignition, nos, rpm, speed]);

    useEffect(() => {
        let animationFrame;
        let lastFrame = performance.now();

        const render = (time) => {
            const delta = Math.min(50, Math.max(0, time - lastFrame));
            const target = targetValuesRef.current;
            const animated = animatedValuesRef.current;

            lastFrame = time;
            animatedValuesRef.current = {
                rpm: smoothValue(animated.rpm, target.rpm, delta, 18),
                nos: smoothValue(animated.nos, target.nos, delta, 12),
                speed: smoothValue(animated.speed, target.speed, delta, 14),
            };

            drawGauge(canvasRef.current, animatedValuesRef.current);

            const nextSpeed = Math.floor(animatedValuesRef.current.speed);

            if (displayedSpeedRef.current !== nextSpeed) {
                displayedSpeedRef.current = nextSpeed;
                setAnimatedSpeed(nextSpeed);
            }

            animationFrame = window.requestAnimationFrame(render);
        };

        animationFrame = window.requestAnimationFrame(render);

        return () => {
            window.cancelAnimationFrame(animationFrame);
        };
    }, []);

    return (
        <div className={classes.hudRight}>
            <VOIP />
            <Ammo />
            <Fade in={showing && !isAircraft}>
                <div className={classes.carAnchor}>
                    <div className={classes.carHud}>
                        <canvas ref={canvasRef} className={classes.canvas} />
                        {hasNos && (
                            <div className={classes.nitroIcons}>
                                <FontAwesomeIcon icon={['fas', 'bolt']} />
                                <FontAwesomeIcon icon={['fas', 'fire']} />
                            </div>
                        )}
                        <div className={classes.center}>
                            <h3 className={classes.speed}>{displaySpeed}</h3>
                            <h4 className={classes.unit}>{speedMeasure}</h4>
                            {Boolean(checkEngine) && (
                                <EngineWarningIcon
                                    className={classes.checkEngine}
                                />
                            )}
                        </div>
                        <div className={classes.controls}>
                            {controls.map((control) => (
                                <div
                                    className={classes.control}
                                    key={control.label}
                                >
                                    {control.label}
                                    <HorizontalProgress
                                        color={control.color}
                                        value={control.value}
                                    />
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </Fade>
        </div>
    );
};
