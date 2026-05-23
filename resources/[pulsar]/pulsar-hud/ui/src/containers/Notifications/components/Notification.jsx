import React, { useCallback, useEffect } from 'react';
import { makeStyles } from '@mui/styles';

import { Sanitize } from '../../../util/Parser';
import { useDispatch } from 'react-redux';

const useStyles = makeStyles((theme) => ({
    alert: {
        position: 'relative',
        width: 'fit-content',
        marginLeft: 'auto',
        padding: '.75rem 1rem',
        color: '#fff',
        maxWidth: '25rem',
        display: 'flex',
        flexDirection: 'column',
        gap: '.625rem',
        '--bg': '#001620',
        '--border': '#33454d',
        '--accentColor': '#00b2ff',
        '--accentWidth': '2px',
        '--accent': '.75rem',
        '--accentRadius': '1.5px',
        borderRadius: '.25rem',
        background: 'var(--bg)',
        border: '1px solid var(--border)',
        boxSizing: 'border-box',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        isolation: 'isolate',
        overflow: 'visible',
        boxShadow: 'none',
        '&:before': {
            position: 'absolute',
            inset: 'calc(var(--accentWidth) * -0.5)',
            borderRadius: 'var(--accentRadius)',
            content: '""',
            zIndex: 1,
            background: [
                'linear-gradient(var(--accentColor), var(--accentColor)) left top / var(--accent) var(--accentWidth) no-repeat',
                'linear-gradient(var(--accentColor), var(--accentColor)) left top / var(--accentWidth) var(--accent) no-repeat',
                'linear-gradient(var(--accentColor), var(--accentColor)) right top / var(--accent) var(--accentWidth) no-repeat',
                'linear-gradient(var(--accentColor), var(--accentColor)) right top / var(--accentWidth) var(--accent) no-repeat',
                'linear-gradient(var(--accentColor), var(--accentColor)) left bottom / var(--accent) var(--accentWidth) no-repeat',
                'linear-gradient(var(--accentColor), var(--accentColor)) left bottom / var(--accentWidth) var(--accent) no-repeat',
                'linear-gradient(var(--accentColor), var(--accentColor)) right bottom / var(--accent) var(--accentWidth) no-repeat',
                'linear-gradient(var(--accentColor), var(--accentColor)) right bottom / var(--accentWidth) var(--accent) no-repeat',
            ].join(', '),
            pointerEvents: 'none',
        },
        '&.error': {
            '--bg': '#7d000080',
            '--border': '#734e5a',
            '--accentColor': 'red',
        },
        '&.success': {
            '--bg': '#39620680',
            '--border': '#64744d',
            '--accentColor': '#87da21',
        },
    },
    title: {
        position: 'relative',
        zIndex: 2,
        margin: 0,
        color: 'var(--White-White-50, hsla(0, 0%, 100%, .5))',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '.75rem',
        fontWeight: 400,
        lineHeight: '100%',
    },
    body: {
        position: 'relative',
        zIndex: 2,
        margin: 0,
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '.875rem',
        fontWeight: 500,
        lineHeight: '100%',
        whiteSpace: 'pre-line',
    },
}));

export default ({ notification }) => {
    const classes = useStyles();
    const dispatch = useDispatch();

    const removeNotification = useCallback(() => {
        dispatch({
            type: 'REMOVE_ALERT',
            payload: {
                id: notification._id,
            },
        });
    }, [dispatch, notification._id]);

    useEffect(() => {
        if (notification.hide) {
            removeNotification();
        }
    }, [notification.hide, removeNotification]);

    useEffect(() => {
        const duration = Number(notification.duration);
        if (!Number.isFinite(duration) || duration <= 0) return undefined;

        const timeout = setTimeout(removeNotification, duration);
        return () => clearTimeout(timeout);
    }, [notification.duration, removeNotification]);

    const type = (notification.type || '').toString().toLowerCase();
    const title = notification.title ?? notification?.style?.title;
    const text = notification.text ?? notification.message ?? '';

    return (
        <div
            className={`${classes.alert} ${type}`}
            style={
                Boolean(notification?.style?.alert)
                    ? { ...notification?.style?.alert }
                    : null
            }
        >
            {Boolean(title) && (
                <h2 className={classes.title}>{Sanitize(title)}</h2>
            )}
            <div
                className={classes.body}
                style={
                    Boolean(notification?.style?.body)
                        ? { ...notification?.style?.body }
                        : null
                }
            >
                {Sanitize(text)}
            </div>
        </div>
    );
};
