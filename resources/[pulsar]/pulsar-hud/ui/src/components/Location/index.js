import React, { useLayoutEffect, useMemo, useRef, useState } from 'react';
import { useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { CSSTransition, SwitchTransition } from 'react-transition-group';

const CompassIcon = () => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <circle cx="12" cy="12" r="10" />
        <path d="m16.24 7.76-2.12 6.36-6.36 2.12 2.12-6.36 6.36-2.12Z" />
    </svg>
);

const MapPinIcon = () => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path d="M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 0 1 16 0Z" />
        <circle cx="12" cy="10" r="3" />
    </svg>
);

const MapIcon = () => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path d="m3 6 6-3 6 3 6-3v15l-6 3-6-3-6 3V6Z" />
        <path d="M9 3v15" />
        <path d="M15 6v15" />
    </svg>
);

const useStyles = makeStyles(() => ({
    wrapper: {
        position: 'fixed',
        top: '2.5em',
        left: '50%',
        transform: 'translateX(-50%)',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '1em',
        color: '#fff',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: 'min(0.74vw, 1.32vh)',
        pointerEvents: 'none',
        zIndex: 15,
    },
    topInfo: {
        display: 'flex',
        gap: '0.75em',

        '& svg': {
            width: '1.5em',
            height: '1.5em',
            stroke: 'currentColor',
            strokeWidth: 2,
            strokeLinecap: 'round',
            strokeLinejoin: 'round',
        },
    },
    section: {
        position: 'relative',
        color: '#fff',
        minHeight: '2.2em',
        padding: '0.28em 0.75em',
        borderRadius: '0.75em',
        border: 0,
        background: 'rgba(0, 0, 0, 0.36)',
        display: 'flex',
        alignItems: 'center',
        gap: '0.625em',
        overflow: 'hidden',
        width: 'fit-content',
        boxSizing: 'content-box',
        transition: 'width .25s ease',

        '& svg': {
            color: '#87da21',
            filter: 'drop-shadow(0 0 0.35em rgba(135, 218, 33, 0.45))',
            flexShrink: 0,
        },

        '& p': {
            margin: 0,
            fontSize: '0.95em',
            fontWeight: 500,
            lineHeight: '100%',
            whiteSpace: 'nowrap',
        },
    },
    directionSection: {
        justifyContent: 'center',
    },
    wideSection: {},
    sectionContent: {
        display: 'flex',
        alignItems: 'center',
        gap: '0.625em',
        width: 'fit-content',
        whiteSpace: 'nowrap',
    },
    measure: {
        position: 'absolute',
        visibility: 'hidden',
        pointerEvents: 'none',
        left: 0,
        top: 0,
        height: 0,
        overflow: 'hidden',
        display: 'flex',
        alignItems: 'center',
        gap: '0.625em',
        whiteSpace: 'nowrap',
    },
    textEnter: {
        opacity: 0,
        transform: 'translateY(0.35em)',
    },
    textEnterActive: {
        opacity: 1,
        transform: 'translateY(0)',
        transition: 'opacity .25s ease, transform .25s ease',
    },
    textExit: {
        opacity: 1,
        transform: 'translateY(0)',
    },
    textExitActive: {
        opacity: 0,
        transform: 'translateY(-0.35em)',
        transition: 'opacity .2s ease, transform .2s ease',
    },
    rotateEnter: {
        opacity: 0,
        transform: 'translateY(-100%) rotateX(20deg)',
    },
    rotateEnterActive: {
        opacity: 1,
        transform: 'translateY(0) rotateX(0)',
        transition: 'all .3s ease-out',
    },
    rotateExit: {
        opacity: 1,
        transform: 'translateY(0) rotateX(0)',
    },
    rotateExitActive: {
        opacity: 0,
        transform: 'translateY(-100%) rotateX(20deg)',
        transition: 'all .3s ease-out',
    },
}));

const AnimatedText = ({ value, classes }) => {
    const nodeRef = useRef(null);
    const safeValue = String(value ?? '');
    const transitionClasses = useMemo(
        () => ({
            enter: classes.textEnter,
            enterActive: classes.textEnterActive,
            exit: classes.textExit,
            exitActive: classes.textExitActive,
        }),
        [classes],
    );

    return (
        <SwitchTransition mode="out-in">
            <CSSTransition
                key={safeValue}
                nodeRef={nodeRef}
                timeout={250}
                classNames={transitionClasses}
            >
                <p ref={nodeRef}>{safeValue}</p>
            </CSSTransition>
        </SwitchTransition>
    );
};

const LocationSection = ({ Icon, value, className, classes }) => {
    const measureRef = useRef(null);
    const [contentWidth, setContentWidth] = useState(null);
    const safeValue = String(value ?? '');

    useLayoutEffect(() => {
        if (!measureRef.current) return;

        setContentWidth(measureRef.current.getBoundingClientRect().width);
    }, [safeValue]);

    return (
        <div
            className={`${classes.section} ${className}`}
            style={{
                width:
                    contentWidth === null ? 'fit-content' : `${contentWidth}px`,
            }}
        >
            <div className={classes.sectionContent}>
                <Icon />
                <AnimatedText value={safeValue} classes={classes} />
            </div>
            <div
                ref={measureRef}
                className={classes.measure}
                aria-hidden="true"
            >
                <Icon />
                <p>{safeValue}</p>
            </div>
        </div>
    );
};

export default () => {
    const classes = useStyles();
    const nodeRef = useRef(null);

    const isShowing = useSelector((state) => state.location.showing);
    const location = useSelector((state) => state.location.location);
    const isBlindfolded = useSelector((state) => state.app.blindfolded);
    const config = useSelector((state) => state.hud.config);
    const inVehicle = useSelector((state) => state.vehicle.showing);

    const visible = isShowing && !isBlindfolded && inVehicle;
    const street = useMemo(() => {
        if (location.cross !== '' && !config.hideCrossStreet) {
            return `${location.main} x ${location.cross}`;
        }

        return location.main;
    }, [config.hideCrossStreet, location.cross, location.main]);

    const transitionClasses = useMemo(
        () => ({
            appear: classes.rotateEnter,
            appearActive: classes.rotateEnterActive,
            enter: classes.rotateEnter,
            enterActive: classes.rotateEnterActive,
            exit: classes.rotateExit,
            exitActive: classes.rotateExitActive,
        }),
        [classes],
    );

    return (
        <div className={classes.wrapper}>
            <CSSTransition
                in={visible}
                nodeRef={nodeRef}
                timeout={300}
                classNames={transitionClasses}
                appear
                unmountOnExit
            >
                <div ref={nodeRef} className={classes.topInfo}>
                    <LocationSection
                        Icon={CompassIcon}
                        value={location.direction}
                        className={classes.directionSection}
                        classes={classes}
                    />
                    <LocationSection
                        Icon={MapPinIcon}
                        value={street}
                        className={classes.wideSection}
                        classes={classes}
                    />
                    <LocationSection
                        Icon={MapIcon}
                        value={location.area}
                        className={classes.wideSection}
                        classes={classes}
                    />
                </div>
            </CSSTransition>
        </div>
    );
};
