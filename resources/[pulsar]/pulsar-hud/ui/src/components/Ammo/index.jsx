import React, { useEffect, useRef, useState } from 'react';
import { useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import longAmmoIcon from '../../assets/ammo-long.svg';
import shortAmmoIcon from '../../assets/ammo-short.svg';

const ACTIVE = '#87da21';
const ammoIcons = {
    long: longAmmoIcon,
    short: shortAmmoIcon,
};

const useStyles = makeStyles(() => ({
    slot: {
        height: '2.75em',
        display: 'flex',
        alignItems: 'flex-end',
        justifyContent: 'center',
        overflow: 'visible',
        transition:
            'width 0.28s ease, margin-left 0.28s ease, margin-right 0.28s ease',
    },
    wrapper: {
        display: 'flex',
        alignItems: 'center',
        gap: '0.5em',
        color: ACTIVE,
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        pointerEvents: 'none',
        minWidth: '4.5em',
        opacity: 0,
        transform: 'translateY(0.15em)',
        transition: 'opacity 0.18s ease',
    },
    visible: {
        opacity: 1,
    },
    icon: {
        width: '2em',
        height: '2em',
        display: 'block',
        flex: '0 0 auto',
        filter:
            'drop-shadow(0 0 0.22em rgba(135, 218, 33, 0.55)) drop-shadow(0 0 0.65em rgba(135, 218, 33, 0.25))',
    },
    column: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        width: '2em',
        transform: 'translateX(-0.32em)',
    },
    large: {
        color: ACTIVE,
        textShadow:
            '0 0.25em 0.25em rgba(135, 218, 33, 0.25), 0 0.25em 1em rgba(135, 218, 33, 0.35)',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '2em',
        fontStyle: 'normal',
        fontWeight: 700,
        lineHeight: '100%',
        margin: 0,
        transition: 'text-shadow 0.2s ease, color 0.2s ease',
    },
    gray: {
        color: 'rgba(255, 255, 255, 0.5)',
        textShadow: 'none',
    },
    small: {
        color: 'rgba(255, 255, 255, 0.5)',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '1.25em',
        fontStyle: 'normal',
        fontWeight: 400,
        lineHeight: '100%',
        margin: 0,
    },
}));

const useAnimatedNumber = (value, duration = 120) => {
    const target = Math.max(0, Math.floor(Number(value) || 0));
    const [displayValue, setDisplayValue] = useState(target);
    const displayValueRef = useRef(target);

    useEffect(() => {
        let animationFrame;
        const from = displayValueRef.current;
        const start = performance.now();

        const render = (time) => {
            const progress = Math.min(1, (time - start) / duration);
            const eased = 1 - Math.pow(1 - progress, 3);
            const next = Math.round(from + (target - from) * eased);

            displayValueRef.current = next;
            setDisplayValue(next);

            if (progress < 1) {
                animationFrame = window.requestAnimationFrame(render);
            } else {
                displayValueRef.current = target;
            }
        };

        animationFrame = window.requestAnimationFrame(render);

        return () => {
            window.cancelAnimationFrame(animationFrame);
        };
    }, [duration, target]);

    return displayValue;
};

const AmmoIcon = ({ type, className }) => (
    <img
        className={className}
        src={ammoIcons[String(type).toLowerCase()] || longAmmoIcon}
        alt=""
        aria-hidden="true"
    />
);

export default () => {
    const classes = useStyles();
    const visible = useSelector((state) => state.ammo.visible);
    const ammoType = useSelector((state) => state.ammo.ammoType);
    const magazine = useSelector((state) => state.ammo.magazine);
    const total = useSelector((state) => state.ammo.total);
    const grayOut = useSelector((state) => state.ammo.grayOut);
    const magazineDisplay = useAnimatedNumber(magazine, 85);
    const totalDisplay = useAnimatedNumber(total, 160);

    return (
        <div
            className={classes.slot}
            style={{
                width: visible ? '4.5em' : 0,
                marginLeft: visible ? '0.35em' : 0,
                marginRight: visible ? '0.35em' : 0,
            }}
        >
            <div
                className={`${classes.wrapper} ${
                    visible ? classes.visible : ''
                }`}
            >
                <AmmoIcon type={ammoType} className={classes.icon} />
                <div className={classes.column}>
                    <p
                        className={`${classes.large} ${
                            grayOut ? classes.gray : ''
                        }`}
                    >
                        {magazineDisplay}
                    </p>
                    <p className={classes.small}>{totalDisplay}</p>
                </div>
            </div>
        </div>
    );
};
