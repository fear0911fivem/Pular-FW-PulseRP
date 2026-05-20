import React, { useEffect, useRef, useState } from 'react';
import { connect } from 'react-redux';
import { makeStyles } from '@mui/styles';

import progressBackground from '../../assets/progress.svg';

const ACTIVE = '#87da21';

const useStyles = makeStyles(() => ({
    container: {
        position: 'absolute',
        left: '50%',
        bottom: '2.5rem',
        transform: 'translateX(-50%) translateY(100%) rotateX(-20deg)',
        transformOrigin: 'bottom center',
        opacity: 0,
        width: '20rem',
        minWidth: '20rem',
        color: '#fff',
        display: 'flex',
        flexDirection: 'column',
        gap: '0.16rem',
        pointerEvents: 'none',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        zIndex: 50,
        transition: 'all 0.3s ease-out',
    },
    visible: {
        opacity: 1,
        transform: 'translateX(-50%) translateY(0) rotateX(0deg)',
    },
    row: {
        width: '100%',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        fontSize: '1.125rem',
        fontWeight: 600,
        lineHeight: 1,
        marginBottom: '-0.06rem',
        transform: 'translateY(0.06rem)',
    },
    label: {
        maxWidth: '15rem',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
    },
    percent: {
        color: ACTIVE,
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '0.75rem',
        fontWeight: 500,
        lineHeight: 1,
        textShadow:
            '0 0.25rem 0.25rem rgba(135, 218, 33, 0.25), 0 0.25rem 1rem rgba(135, 218, 33, 0.35)',
    },
    canceled: {
        color: 'red !important',
    },
    bar: {
        width: '100%',
        height: '0.55894rem',
        position: 'relative',
        isolation: 'isolate',
    },
    background: {
        position: 'absolute',
        width: '100%',
        height: '100%',
        top: 0,
        left: 0,
        zIndex: -1,
        borderRadius: '1.5rem',
        overflow: 'hidden',
    },
    backgroundImage: {
        position: 'absolute',
        top: 0,
        width: '100%',
        height: '100%',
        objectFit: 'cover',
    },
    barInner: {
        '--col': '135, 218, 33',
        width: 'var(--scale)',
        height: '100%',
        background: 'rgb(var(--col))',
        borderRadius:
            '1.5rem calc(var(--progress) * 1.5rem) calc(var(--progress) * 1.5rem) 1.5rem',
        boxShadow:
            '0 4px 16px 0 rgba(var(--col), 0.5), 0 4px 24px 0 rgba(var(--col), 0.75)',
    },
    barCanceled: {
        background: 'red',
        boxShadow:
            '0 4px 16px 0 rgba(255, 0, 0, 0.5), 0 4px 24px 0 rgba(255, 0, 0, 0.75)',
    },
}));

const mapStateToProps = (state) => ({
    cancelled: state.progress.cancelled,
    failed: state.progress.failed,
    finished: state.progress.finished,
    label: state.progress.label,
    duration: state.progress.duration,
    startTime: state.progress.startTime,
});

const ProgressBar = ({ progress, canceled }) => {
    const classes = useStyles();
    const safeProgress = Math.max(0, Math.min(1, Number(progress) || 0));

    return (
        <div className={classes.bar}>
            <div className={classes.background}>
                <img
                    className={classes.backgroundImage}
                    src={progressBackground}
                    alt=""
                    aria-hidden="true"
                />
            </div>
            <div
                className={`${classes.barInner} ${
                    canceled ? classes.barCanceled : ''
                }`}
                style={{
                    '--scale': `${safeProgress * 100}%`,
                    '--progress': safeProgress,
                }}
            />
        </div>
    );
};

export default connect(mapStateToProps)(
    ({
        cancelled,
        failed,
        finished,
        label,
        duration,
        startTime,
        dispatch,
    }) => {
        const classes = useStyles();
        const frame = useRef(null);
        const enterFrame = useRef(null);
        const hideTimer = useRef(null);
        const exitTimer = useRef(null);
        const start = useRef(0);
        const [progress, setProgress] = useState(0);
        const [visible, setVisible] = useState(false);
        const canceled = cancelled || failed;
        const total = Math.max(1, Number(duration) || 1);

        useEffect(() => {
            setProgress(0);
            setVisible(false);
            start.current = performance.now();

            if (frame.current) window.cancelAnimationFrame(frame.current);
            if (enterFrame.current)
                window.cancelAnimationFrame(enterFrame.current);
            if (hideTimer.current) window.clearTimeout(hideTimer.current);
            if (exitTimer.current) window.clearTimeout(exitTimer.current);

            enterFrame.current = window.requestAnimationFrame(() => {
                enterFrame.current = window.requestAnimationFrame(() => {
                    setVisible(true);
                });
            });

            const tick = (time) => {
                const next = Math.min(1, (time - start.current) / total);

                setProgress(next);

                if (next >= 1) {
                    dispatch({ type: 'FINISH_PROGRESS' });
                    return;
                }

                frame.current = window.requestAnimationFrame(tick);
            };

            frame.current = window.requestAnimationFrame(tick);

            return () => {
                if (frame.current) window.cancelAnimationFrame(frame.current);
                if (enterFrame.current)
                    window.cancelAnimationFrame(enterFrame.current);
                if (hideTimer.current) window.clearTimeout(hideTimer.current);
                if (exitTimer.current) window.clearTimeout(exitTimer.current);
            };
        }, [dispatch, startTime, total]);

        useEffect(() => {
            if (!canceled && !finished) return;

            if (frame.current) window.cancelAnimationFrame(frame.current);
            if (hideTimer.current) window.clearTimeout(hideTimer.current);
            if (exitTimer.current) window.clearTimeout(exitTimer.current);

            hideTimer.current = window.setTimeout(() => {
                setVisible(false);
                exitTimer.current = window.setTimeout(() => {
                    dispatch({ type: 'HIDE_PROGRESS' });
                }, 300);
            }, canceled ? 100 : 120);
        }, [canceled, dispatch, finished]);

        return (
            <div
                className={`${classes.container} ${
                    visible ? classes.visible : ''
                }`}
            >
                <div className={classes.row}>
                    <p className={classes.label}>{label}</p>
                    <span
                        className={`${classes.percent} ${
                            canceled ? classes.canceled : ''
                        }`}
                    >
                        {Math.round(progress * 100)}%
                    </span>
                </div>
                <ProgressBar progress={progress} canceled={canceled} />
            </div>
        );
    },
);
