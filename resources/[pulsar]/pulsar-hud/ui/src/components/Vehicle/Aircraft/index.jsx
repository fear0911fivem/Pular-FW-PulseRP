import React, { useEffect, useRef, useState } from 'react';
import { useSelector } from 'react-redux';
import { Fade } from '@mui/material';
import { makeStyles } from '@mui/styles';

const ACTIVE_RGB = [135, 218, 33];
const TRACK_RGB = [209, 209, 209];
const WARNING_RGB = [206, 127, 8];
const SCALE_LINES = 6;
const SCALE_LINE_LIMIT = SCALE_LINES / 2 + 1;

const clamp = (value, min = 0, max = 1) => Math.min(max, Math.max(min, value));

const smoothValue = (current, target, delta, speed = 22) => {
    const next =
        current + (target - current) * (1 - Math.exp((-speed * delta) / 1000));

    return Math.abs(next - target) < 0.01 ? target : next;
};

const getUnit = (element) => {
    if (typeof window === 'undefined' || !element) return 16;

    const size = parseFloat(window.getComputedStyle(element).fontSize);

    return Number.isFinite(size) ? size : 16;
};

const em = (element, value) => value * getUnit(element);

const rgb = (color) => color.join(', ');

const blendColor = (from, to, amount) =>
    from.map((value, index) =>
        Math.round(value + (to[index] - value) * clamp(amount)),
    );

const drawIndicatorScale = (
    canvas,
    { displayValue, scale, showScale, invert },
) => {
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const width = canvas.clientWidth;
    const height = canvas.clientHeight;

    if (!width || !height) return;

    canvas.width = width;
    canvas.height = height;

    const drawHeight = height - 2;

    ctx.clearRect(0, 0, width, height);
    ctx.lineWidth = 2;

    if (!showScale) {
        const step = drawHeight / 2;

        for (let section = 0; section <= 2; section += 1) {
            let x = width * 0.4;
            if (invert) x = width - x;

            const y = 1 + section * step;

            ctx.beginPath();
            ctx.moveTo(x, y);
            ctx.lineTo(invert ? 0 : width, y);
            ctx.strokeStyle = section === 2 ? '#ce7f08' : '#d1d1d1';
            ctx.stroke();

            if (section !== 2) {
                for (let tick = 0; tick < 5; tick += 1) {
                    let tickX = width * 0.7;
                    if (invert) tickX = width - tickX;

                    const tickY = 1 + section * step + (tick * step) / 5;

                    ctx.beginPath();
                    ctx.moveTo(tickX, tickY);
                    ctx.lineTo(invert ? 0 : width, tickY);

                    if (section === 1) {
                        ctx.strokeStyle = `rgb(${rgb(
                            blendColor(TRACK_RGB, WARNING_RGB, tick / 5),
                        )})`;
                    } else {
                        ctx.strokeStyle = '#d1d1d1';
                    }

                    ctx.stroke();
                }
            }
        }

        return;
    }

    const safeScale = Math.max(1, Number(scale) || 1);
    const step = drawHeight / SCALE_LINES;
    const ceiling = Math.ceil(displayValue / safeScale) * safeScale;
    const floor = Math.floor(displayValue / safeScale) * safeScale;
    const closest =
        Math.abs(ceiling - displayValue) < Math.abs(displayValue - floor)
            ? ceiling
            : floor;
    const offset = (displayValue - closest) / safeScale;
    const centerY = drawHeight / 2 + offset * step;

    ctx.font = `${em(canvas, 0.75)}px "Bai Jamjuree", Arial, sans-serif`;
    ctx.fillStyle = '#d1d1d1';

    for (
        let lineIndex = -SCALE_LINE_LIMIT;
        lineIndex <= SCALE_LINE_LIMIT;
        lineIndex += 1
    ) {
        let x = width * 0.6;
        if (invert) x = width - x;

        const y = centerY + lineIndex * step;

        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(invert ? 0 : width, y);
        ctx.strokeStyle = '#d1d1d1';
        ctx.stroke();

        for (let tick = 0; tick < 5; tick += 1) {
            let tickX = width * 0.8;
            if (invert) tickX = width - tickX;

            const tickY = y + (tick * step) / 5;

            ctx.beginPath();
            ctx.moveTo(tickX, tickY);
            ctx.lineTo(invert ? 0 : width, tickY);
            ctx.stroke();
        }

        const label = String(closest - lineIndex * safeScale);
        const metrics = ctx.measureText(label);
        const labelX = invert ? width * 0.5 : width * 0.5 - metrics.width;

        ctx.fillText(
            label,
            labelX,
            y + (metrics.actualBoundingBoxAscent || em(canvas, 0.75)) / 2,
        );
    }
};

const drawHorizon = (canvas, { pitch, roll }) => {
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const width = canvas.clientWidth;
    const height = canvas.clientHeight;

    if (!width || !height) return;

    canvas.width = width;
    canvas.height = height;

    const unit = em(canvas, 1);
    const safePitch = Number(pitch) || 0;
    const safeRoll = Number(roll) || 0;

    ctx.clearRect(0, 0, width, height);
    ctx.save();
    ctx.translate(width / 2, height / 2);

    ctx.save();
    ctx.rotate((safeRoll * Math.PI) / 180);
    ctx.translate(0, (safePitch * height) / 90);
    ctx.fillStyle = 'rgba(99, 207, 254, 0.5)';
    ctx.fillRect(-width / 2, -height, width, height);
    ctx.fillStyle = 'rgba(37, 32, 24, 0.5)';
    ctx.fillRect(-width / 2, 0, width, height);
    ctx.strokeStyle = '#e0e0e0';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(-width, 0);
    ctx.lineTo(width, 0);
    ctx.stroke();

    const pitchMarkWidth = 1.5 * unit;

    ctx.font = `${em(canvas, 0.75)}px "Bai Jamjuree", Arial, sans-serif`;

    for (let mark = -30; mark <= 30; mark += 5) {
        ctx.beginPath();

        const length =
            (mark % 10 === 0 ? pitchMarkWidth : pitchMarkWidth / 2) +
            (Math.floor(Math.abs(mark) / 10) * pitchMarkWidth) / 4;
        const y = (mark * height) / 90;

        ctx.moveTo(-length, y);
        ctx.lineTo(length, y);
        ctx.strokeStyle = 'rgba(224, 224, 244, 0.5)';
        ctx.lineWidth = 2;
        ctx.stroke();

        if (mark !== 0 && mark % 10 === 0) {
            const label = Math.abs(mark).toString();
            const metrics = ctx.measureText(label);

            ctx.fillStyle = '#e0e0e0';
            ctx.fillText(label, -length - metrics.width - 5, y + 5);
            ctx.fillText(label, length + 5, y + 5);
        }
    }

    ctx.restore();
    ctx.rotate((safeRoll * Math.PI) / 180);

    const small = 0.25 * unit;
    const large = 0.5 * unit;

    for (let mark = -9; mark <= 9; mark += 1) {
        let inner = height / 2 - large - small;
        const outer = height / 2 - small;
        let spread = Math.PI / 300;

        if (mark % 3 === 0) {
            inner = height / 2 - 1.5 * large - small;
            spread *= 2.5;
        }

        if (mark === 0) {
            inner = height / 2 - 2 * large - small;
            spread *= 2;
        }

        const angle = (mark * Math.PI) / 18 - Math.PI / 2;

        ctx.beginPath();
        ctx.moveTo(
            inner * Math.cos(angle - spread),
            inner * Math.sin(angle - spread),
        );
        ctx.lineTo(
            outer * Math.cos(angle - spread),
            outer * Math.sin(angle - spread),
        );
        ctx.arc(0, 0, outer, angle - spread, angle + spread, false);
        ctx.lineTo(
            outer * Math.cos(angle + spread),
            outer * Math.sin(angle + spread),
        );
        ctx.arc(0, 0, inner, angle + spread, angle - spread, true);
        ctx.closePath();
        ctx.fillStyle = '#e0e0e0';
        ctx.fill();
    }

    for (let mark = -2; mark <= 2; mark += 1) {
        const radius = height / 2 - small;
        const angle = (mark * Math.PI) / 6 + Math.PI / 2;

        ctx.beginPath();
        ctx.moveTo(radius * Math.cos(angle), radius * Math.sin(angle));
        ctx.lineTo(
            (radius - large) * Math.cos(angle),
            (radius - large) * Math.sin(angle),
        );
        ctx.strokeStyle = '#e0e0e0';
        ctx.lineWidth = 2;
        ctx.stroke();
    }

    ctx.rotate((-safeRoll * Math.PI) / 180);

    const pointerTop = 1.5 * unit;
    const pointerBottom = 1.375 * unit;

    ctx.beginPath();
    ctx.moveTo(0, -height / 2 + pointerTop);
    ctx.lineTo(-pointerBottom / 2, -height / 2 + pointerBottom + pointerTop);
    ctx.lineTo(pointerBottom / 2, -height / 2 + pointerBottom + pointerTop);
    ctx.fillStyle = `rgb(${rgb(ACTIVE_RGB)})`;
    ctx.fill();
    ctx.closePath();
    ctx.restore();
};

const useAnimatedNumber = (value, duration = 500) => {
    const target = Number(value) || 0;
    const [displayValue, setDisplayValue] = useState(target);
    const displayValueRef = useRef(target);

    useEffect(() => {
        let animationFrame;
        const from = displayValueRef.current;
        const start = performance.now();

        const render = (time) => {
            const progress = Math.min(1, (time - start) / duration);
            const eased = 1 - Math.pow(1 - progress, 3);
            const next = from + (target - from) * eased;

            displayValueRef.current = next;
            setDisplayValue(next);

            if (progress < 1) {
                animationFrame = window.requestAnimationFrame(render);
            }
        };

        animationFrame = window.requestAnimationFrame(render);

        return () => {
            window.cancelAnimationFrame(animationFrame);
        };
    }, [duration, target]);

    return displayValue;
};

const useStyles = makeStyles(() => ({
    anchor: {
        position: 'absolute',
        left: '50%',
        bottom: '2.5rem',
        minWidth: '20rem',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '1rem',
        transform: 'translateX(-50%)',
        pointerEvents: 'none',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
    },
    aircraftHud: {
        display: 'flex',
        gap: '0.75rem',
        height: '15rem',
        alignItems: 'flex-end',
        transform: 'scale(0.8)',
        transformOrigin: 'bottom center',
        '--col': rgb(ACTIVE_RGB),
    },
    indicator: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        borderRadius: '0.25rem',
        background: 'rgba(29, 29, 29, 0.75)',
        gap: '0.5rem',
        padding: '0 0.25rem 0.25rem',
        width: '4rem',
        color: '#fff',
        height: '100%',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
    },
    smallIndicator: {
        width: '2.25rem',
        height: '6.125rem',
    },
    title: {
        fontSize: '0.75rem',
        lineHeight: '1rem',
        fontWeight: 600,
        margin: 0,
    },
    values: {
        flex: 1,
        width: '100%',
        position: 'relative',
        display: 'flex',
        flexDirection: 'column',
        minHeight: 0,

        '& canvas': {
            width: '100%',
            maxHeight: '100%',
            flex: 1,
        },
    },
    invert: {
        '& $indicatorLine $indicatorValue': {
            left: 'unset',
            right: 0,
            transform: 'translate(0.1rem, -50%)',
        },
    },
    indicatorLine: {
        position: 'absolute',
        background: '#d9d9d9',
        boxShadow: '0 0 3px 0 rgb(var(--col)) inset',
        filter: 'drop-shadow(0 0 8px rgba(var(--col), 0.6))',
        width: 'calc(100% + 0.5rem)',
        left: '-0.25rem',
        top: 'calc(var(--v) * 100%)',
        padding: 0,
        height: '0.15rem',
        borderRadius: '0.125rem',
        transform: 'translateY(-50%)',

        '&:before, &:after': {
            position: 'absolute',
            content: '""',
            background: '#d9d9d9',
            boxShadow: '0 0 3px 0 rgb(var(--col)) inset',
            filter: 'drop-shadow(0 0 8px rgba(var(--col), 0.6))',
            borderRadius: 'inherit',
            width: '0.125rem',
            height: '0.875rem',
            top: '50%',
            transform: 'translateY(-50%)',
        },

        '&:before': {
            left: 0,
        },

        '&:after': {
            right: 0,
        },
    },
    indicatorValue: {
        position: 'absolute',
        left: 0,
        top: '50%',
        transform: 'translate(-0.1rem, -50%)',
        zIndex: 2,
        padding: '0 0.25rem',
        justifyContent: 'center',
        alignItems: 'center',
        gap: '0.625rem',
        borderRadius: '0.125rem',
        border: '0.5px solid #464646',
        background: '#111112',
        color: 'rgb(var(--col))',
        textShadow: '0 0 4px rgba(var(--col), 0.6)',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '1.25rem',
        lineHeight: '1.5rem',
    },
    horizonWrapper: {
        width: '15rem',
        height: '15rem',
        position: 'relative',
    },
    horizon: {
        width: '100%',
        height: '100%',
        aspectRatio: '1',
        borderRadius: '50%',
        background: 'rgba(29, 29, 29, 0.75)',
        padding: '0.5rem',

        '& canvas': {
            width: '100%',
            height: '100%',
            borderRadius: '50%',
            boxShadow: 'inset 0 0 0.5rem 0 #1d1d1d',
        },
    },
    control: {
        position: 'absolute',
        left: 0,
        bottom: 0,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        color: '#fff',
        gap: 0,
        fontSize: '0.75rem',
        fontWeight: 600,
        lineHeight: '1rem',
    },
    controlRight: {
        left: 'unset',
        right: 0,
    },
    horizontalProgress: {
        height: '0.1875rem',
        width: '1.5rem',
        borderRadius: '0.125rem',
        background: 'rgba(48, 48, 48, 0.95)',
        overflow: 'hidden',
    },
    horizontalInternal: {
        width: '100%',
        height: '100%',
        transformOrigin: 'left center',
        transform: 'scaleX(var(--val))',
        background: 'rgb(var(--bg))',
        borderRadius: 'inherit',
        boxShadow:
            '0 4px 4px 0 rgba(var(--bg), 0.25), 0 4px 16px 0 rgba(var(--bg), 0.35)',
        transition: 'transform 0.5s ease',
    },
    aglIndicator: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'flex-start',
        color: '#fff',
        fontSize: '0.75rem',
    },
    aglLabel: {
        display: 'flex',
        width: 'fit-content',
        padding: '0 0.625rem 0.5rem',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        gap: '0.5rem',
        borderRadius: '0.125rem',
        background: 'rgba(29, 29, 29, 0.75)',
        lineHeight: '1rem',
        fontWeight: 600,
    },
    aglValue: {
        padding: '0 0.25rem',
        borderRadius: '0.125rem',
        border: '0.5px solid #464646',
        background: '#111112',
        boxShadow: '0 0 4px 1px rgba(0, 0, 0, 0.5)',
        color: 'rgb(var(--col))',
        textShadow: '0 0 8px rgba(var(--col), 0.6)',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '1.25rem',
        lineHeight: '1.5rem',
    },
}));

const Counter = ({ value }) => {
    const displayValue = useAnimatedNumber(value, 250);

    return <>{Math.floor(displayValue)}</>;
};

const HorizontalProgress = ({ color, value }) => {
    const classes = useStyles();

    return (
        <div className={classes.horizontalProgress}>
            <div
                className={classes.horizontalInternal}
                style={{
                    '--bg': color,
                    '--val': clamp(Number(value) || 0),
                }}
            />
        </div>
    );
};

const AircraftIndicator = ({
    title,
    value,
    scale,
    showScale = false,
    showValue = false,
    invert = false,
    small = false,
}) => {
    const classes = useStyles();
    const canvasRef = useRef(null);
    const displayValue = useAnimatedNumber(value, 500);
    const safeScale = Math.max(1, Number(scale) || 1);
    const indicatorPosition = showScale
        ? 0.5
        : 1 - clamp(displayValue / safeScale);

    useEffect(() => {
        drawIndicatorScale(canvasRef.current, {
            displayValue,
            scale: safeScale,
            showScale,
            invert,
        });
    }, [displayValue, invert, safeScale, showScale]);

    useEffect(() => {
        const redraw = () =>
            drawIndicatorScale(canvasRef.current, {
                displayValue,
                scale: safeScale,
                showScale,
                invert,
            });

        window.addEventListener('resize', redraw);
        const timeout = window.setTimeout(redraw, 150);

        return () => {
            window.removeEventListener('resize', redraw);
            window.clearTimeout(timeout);
        };
    }, [displayValue, invert, safeScale, showScale]);

    return (
        <div
            className={`${classes.indicator} ${
                small ? classes.smallIndicator : ''
            }`}
        >
            <div className={classes.title}>{title}</div>
            <div
                className={`${classes.values} ${invert ? classes.invert : ''}`}
            >
                <canvas ref={canvasRef} />
                <div
                    className={classes.indicatorLine}
                    style={{ '--v': indicatorPosition }}
                >
                    {showValue && (
                        <div className={classes.indicatorValue}>
                            {Math.floor(displayValue)}
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

const ArtificialHorizon = ({ pitch, roll, active }) => {
    const classes = useStyles();
    const canvasRef = useRef(null);
    const targetRef = useRef({ pitch: 0, roll: 0 });
    const currentRef = useRef({ pitch: 0, roll: 0 });

    useEffect(() => {
        targetRef.current = {
            pitch: Number(pitch) || 0,
            roll: Number(roll) || 0,
        };
    }, [pitch, roll]);

    useEffect(() => {
        if (!active) return undefined;

        let animationFrame;
        let lastFrame = performance.now();

        const render = (time) => {
            const delta = Math.min(50, Math.max(0, time - lastFrame));
            const target = targetRef.current;
            const current = currentRef.current;

            lastFrame = time;
            currentRef.current = {
                pitch: smoothValue(current.pitch, target.pitch, delta),
                roll: smoothValue(current.roll, target.roll, delta),
            };

            drawHorizon(canvasRef.current, currentRef.current);
            animationFrame = window.requestAnimationFrame(render);
        };

        animationFrame = window.requestAnimationFrame(render);

        return () => {
            window.cancelAnimationFrame(animationFrame);
        };
    }, [active]);

    useEffect(() => {
        const redraw = () => drawHorizon(canvasRef.current, currentRef.current);

        window.addEventListener('resize', redraw);
        const timeout = window.setTimeout(redraw, 150);

        return () => {
            window.removeEventListener('resize', redraw);
            window.clearTimeout(timeout);
        };
    }, []);

    return (
        <div className={classes.horizon}>
            <canvas ref={canvasRef} />
        </div>
    );
};

export default () => {
    const classes = useStyles();
    const showing = useSelector((state) => state.vehicle.showing);
    const fuel = useSelector((state) => state.vehicle.fuel);
    const ignition = useSelector((state) => state.vehicle.ignition);
    const aircraftData = useSelector((state) => state.vehicle.aircraftData);
    const visible = showing && Boolean(aircraftData);
    const data = aircraftData || {};

    return (
        <Fade in={visible}>
            <div className={classes.anchor}>
                <div className={classes.aircraftHud}>
                    <AircraftIndicator
                        title="FUEL"
                        small
                        scale={1}
                        value={clamp((Number(fuel) || 0) / 100)}
                    />
                    <AircraftIndicator
                        title="AIRSPEED"
                        scale={10}
                        showScale
                        showValue
                        value={Number(data.airSpeed) || 0}
                    />
                    <div className={classes.horizonWrapper}>
                        {data.gear !== null && data.gear !== undefined && (
                            <div className={classes.control}>
                                GEAR
                                <HorizontalProgress
                                    color={rgb(ACTIVE_RGB)}
                                    value={Number(data.gear)}
                                />
                            </div>
                        )}
                        <div
                            className={`${classes.control} ${classes.controlRight}`}
                        >
                            ENG
                            <HorizontalProgress
                                color={rgb(ACTIVE_RGB)}
                                value={Number(ignition)}
                            />
                        </div>
                        <ArtificialHorizon
                            active={visible}
                            pitch={Number(data.pitch) || 0}
                            roll={Number(data.roll) || 0}
                        />
                    </div>
                    <AircraftIndicator
                        title="ALTITUDE"
                        scale={100}
                        showScale
                        showValue
                        invert
                        value={Number(data.altitude) || 0}
                    />
                    <div className={classes.aglIndicator}>
                        <div className={classes.aglLabel}>AGL</div>
                        <div className={classes.aglValue}>
                            <Counter value={Number(data.agl) || 0} />
                        </div>
                    </div>
                </div>
            </div>
        </Fade>
    );
};
