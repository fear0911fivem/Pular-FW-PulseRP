import React, { useEffect, useMemo, useRef, useState } from 'react';
import { useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles(() => ({
    wrapper: {
        position: 'absolute',
        bottom: '2.5rem',
        left: '50%',
        minWidth: '20rem',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        pointerEvents: 'none',
        opacity: 0,
        transform: 'translateX(-50%) translateY(100%) rotateX(-20deg)',
        transformOrigin: 'bottom center',
        transition: 'all 0.3s ease-out',
        zIndex: 60,
    },
    visible: {
        opacity: 1,
        transform: 'translateX(-50%) translateY(0) rotateX(0deg)',
    },
    action: {
        color: '#fff',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '1.125rem',
        fontWeight: 500,
        textTransform: 'uppercase',
        lineHeight: 1,
        whiteSpace: 'nowrap',
    },
    key: {
        height: '2rem',
        minWidth: '2rem',
        display: 'inline-block',
        textAlign: 'center',
        padding: '0 0.5rem',
        borderRadius: '0.25rem',
        border: '1px solid hsla(0, 0%, 100%, 0.5)',
        background: 'hsla(0, 0%, 100%, 0.15)',
        lineHeight: '170%',
        verticalAlign: 'middle',
        margin: '0 0.25rem',
    },
    text: {
        display: 'inline-block',
        transform: 'translateY(0.13rem)',
    },
}));

const parseMessage = (message) => {
    const sections = String(message || '').split(/({key}.*?{\/key})/);

    return sections
        .map((section) => {
            const keyMatch = section.match(/{key}(.*?){\/key}/);

            if (keyMatch) {
                return {
                    isKey: true,
                    text: keyMatch[1],
                };
            }

            return {
                isKey: false,
                text: section,
            };
        })
        .filter((section) => section.text);
};

export default () => {
    const classes = useStyles();
    const actions = useSelector((state) => state.action2.actions);
    const nextAction = actions.length > 0 ? actions[actions.length - 1] : null;
    const enterFrame = useRef(null);
    const exitTimer = useRef(null);
    const [action, setAction] = useState(nextAction);
    const [visible, setVisible] = useState(false);

    useEffect(() => {
        if (enterFrame.current) window.cancelAnimationFrame(enterFrame.current);
        if (exitTimer.current) window.clearTimeout(exitTimer.current);

        if (nextAction) {
            setAction(nextAction);
            setVisible(false);

            enterFrame.current = window.requestAnimationFrame(() => {
                enterFrame.current = window.requestAnimationFrame(() => {
                    setVisible(true);
                });
            });

            return;
        }

        setVisible(false);
        exitTimer.current = window.setTimeout(() => {
            setAction(null);
        }, 300);
    }, [nextAction]);

    useEffect(
        () => () => {
            if (enterFrame.current)
                window.cancelAnimationFrame(enterFrame.current);
            if (exitTimer.current) window.clearTimeout(exitTimer.current);
        },
        [],
    );

    const sections = useMemo(
        () => parseMessage(action?.message),
        [action?.message],
    );

    if (!action) return null;

    return (
        <div
            className={`${classes.wrapper} ${
                visible ? classes.visible : ''
            }`}
        >
            <div className={classes.action}>
                {sections.map((section, index) =>
                    section.isKey ? (
                        <span className={classes.key} key={`key-${index}`}>
                            {section.text}
                        </span>
                    ) : (
                        <span className={classes.text} key={`text-${index}`}>
                            {section.text}
                        </span>
                    ),
                )}
            </div>
        </div>
    );
};
