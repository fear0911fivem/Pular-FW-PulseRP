import React, { useMemo, useRef } from 'react';
import { useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { CSSTransition, TransitionGroup } from 'react-transition-group';

import Notification from './components/Notification';

const useStyles = makeStyles((theme) => ({
    outer: {
        position: 'absolute',
        inset: 0,
        pointerEvents: 'none',
        zIndex: 10000,
    },
    wrapper: {
        display: 'flex',
        flexDirection: 'column',
        gap: 0,
        width: '20rem',
        minHeight: '5rem',
        position: 'absolute',
        top: '3.5rem',
        right: '1.75rem',
        pointerEvents: 'none !important',
        '& > *': {
            pointerEvents: 'auto',
        },
    },
    notificationItem: {
        width: '100%',
        display: 'flex',
        justifyContent: 'flex-end',
        pointerEvents: 'auto',
        maxHeight: '12rem',
        marginBottom: '1.5rem',
        overflow: 'visible',
    },
    notificationEnter: {
        opacity: 0,
        transform: 'translateX(100%)',
        maxHeight: 0,
        marginBottom: 0,
        overflow: 'hidden',
    },
    notificationEnterActive: {
        opacity: 1,
        transform: 'translateX(0)',
        maxHeight: '12rem',
        marginBottom: '1.5rem',
        transition:
            'opacity .5s ease, transform .5s ease, max-height .45s ease, margin-bottom .45s ease',
    },
    notificationExit: {
        opacity: 1,
        transform: 'translateX(0)',
        maxHeight: '12rem',
        marginBottom: '1.5rem',
        overflow: 'hidden',
    },
    notificationExitActive: {
        opacity: 0,
        transform: 'translateX(0)',
        maxHeight: 0,
        marginBottom: 0,
        overflow: 'hidden',
        transition:
            'opacity .35s ease, transform .35s ease, max-height .45s ease, margin-bottom .45s ease',
    },
}));

const NotificationTransition = ({
    notification,
    transitionClasses,
    ...transitionProps
}) => {
    const classes = useStyles();
    const nodeRef = useRef(null);

    return (
        <CSSTransition
            {...transitionProps}
            nodeRef={nodeRef}
            timeout={500}
            classNames={transitionClasses}
            appear
        >
            <div ref={nodeRef} className={classes.notificationItem}>
                <Notification notification={notification} />
            </div>
        </CSSTransition>
    );
};

export default () => {
    const classes = useStyles();

    const notifications = useSelector(
        (state) => state.notification.notifications,
    );

    const transitionClasses = useMemo(
        () => ({
            appear: classes.notificationEnter,
            appearActive: classes.notificationEnterActive,
            enter: classes.notificationEnter,
            enterActive: classes.notificationEnterActive,
            exit: classes.notificationExit,
            exitActive: classes.notificationExitActive,
        }),
        [classes],
    );

    return (
        <div className={classes.outer}>
            <TransitionGroup className={classes.wrapper}>
                {notifications.map((n) => (
                    <NotificationTransition
                        key={n._id}
                        notification={n}
                        transitionClasses={transitionClasses}
                    />
                ))}
            </TransitionGroup>
        </div>
    );
};
