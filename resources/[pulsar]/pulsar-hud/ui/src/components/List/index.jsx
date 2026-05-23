import React, { useEffect, useRef, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import useKeypress from 'react-use-keypress';

import Nui from '../../util/Nui';
import ListItem from './components/ListItem';

const ANIMATION_TIME = 150;

const useStyles = makeStyles(() => ({
    wrapper: {
        position: 'absolute',
        right: '2rem',
        top: '50%',
        transformOrigin: 'right center',
        transform: 'rotateY(-8deg) translateY(-50%)',
        width: '24rem',
        overflow: 'visible',
        zIndex: 1000,
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        animation: '$slideRightFast 150ms ease-out',
    },
    closing: {
        pointerEvents: 'none',
        animation: '$slideRightFastOut 150ms ease-in forwards',
    },
    header: {
        width: '100%',
        minWidth: '16rem',
        maxWidth: '24rem',
        display: 'flex',
        gap: '.5rem',
        overflow: 'hidden',
        paddingRight: '.75rem',
    },
    headerScrollbar: {
        paddingRight: '1rem',
    },
    field: {
        borderRadius: '.25rem',
        border: '1.5px solid rgba(255, 255, 255, 0.15)',
        background: 'rgba(26, 31, 20, 0.75)',
        flexShrink: 0,
    },
    content: {
        padding: '.5rem .75rem',
        fontSize: '1.25rem',
        color: '#fff',
        flex: 1,
        textAlign: 'center',
        textTransform: 'uppercase',
        whiteSpace: 'nowrap',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        lineHeight: 1.4,
    },
    sqButton: {
        appearance: 'none',
        outline: 0,
        width: '3rem',
        height: '3rem',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        cursor: 'pointer',
        color: '#fff',
        transition: 'border 200ms ease, background 200ms ease',
        '&:hover': {
            border: '1.5px solid #87da21',
            background: 'rgba(58, 86, 24, 0.8)',
        },
        '& svg': {
            width: '1.5rem',
            height: '1.5rem',
            strokeWidth: 2,
            color: '#fff',
        },
    },
    list: {
        paddingTop: '.5rem',
        paddingBottom: '.5rem',
        WebkitMask:
            'linear-gradient(180deg, transparent 0, #fff .5rem, #fff calc(100% - .5rem), transparent)',
        width: '100%',
        display: 'flex',
        flexDirection: 'column',
        gap: '.5rem',
        maxHeight: '25rem',
        overflowY: 'auto',
        overflowX: 'hidden',
        paddingRight: '.75rem',
        margin: 0,
        listStyle: 'none',
        '&::-webkit-scrollbar': { width: '.25rem' },
        '&::-webkit-scrollbar-thumb': {
            background: '#87da21',
            borderRadius: '.5rem',
            transition: 'background ease-in 0.15s',
        },
        '&::-webkit-scrollbar-thumb:hover': { background: '#9eff00' },
        '&::-webkit-scrollbar-track': {
            background: '#101010',
            borderRadius: '.25rem',
        },
    },
    '@keyframes slideRightFast': {
        from: {
            transform: 'translateX(100%) rotateY(20deg) translateY(-50%)',
            opacity: 0,
        },
        to: {
            transform: 'rotateY(-8deg) translateY(-50%)',
            opacity: 1,
        },
    },
    '@keyframes slideRightFastOut': {
        from: {
            transform: 'rotateY(-8deg) translateY(-50%)',
            opacity: 1,
        },
        to: {
            transform: 'translateX(100%) rotateY(20deg) translateY(-50%)',
            opacity: 0,
        },
    },
}));

export default () => {
    const classes = useStyles();
    const dispatch = useDispatch();
    const itemsRef = useRef(null);
    const closeTimer = useRef(null);
    const [isScrollbar, setIsScrollbar] = useState(false);
    const [rendered, setRendered] = useState(false);
    const [closing, setClosing] = useState(false);
    const [snapshot, setSnapshot] = useState({
        active: null,
        stack: Array(),
        menu: null,
    });
    const showing = useSelector((state) => state.list.showing);
    const active = useSelector((state) => state.list.active);
    const stack = useSelector((state) => state.list.stack);
    const menus = useSelector((state) => state.list.menus);

    const menu = menus[active];
    const displayMenu = showing && Boolean(menu) ? menu : snapshot.menu;
    const displayActive = showing && Boolean(menu) ? active : snapshot.active;
    const displayStack = showing && Boolean(menu) ? stack : snapshot.stack;

    const onBack = () => {
        Nui.send('ListMenu:Back');
        dispatch({
            type: 'LIST_GO_BACK',
        });
    };

    const onClose = () => {
        Nui.send('ListMenu:Close');
        dispatch({
            type: 'CLOSE_LIST_MENU',
        });
    };

    const onHeaderAction = (event, data) => {
        Nui.send('ListMenu:Clicked', {
            event,
            data,
        });
    };

    useKeypress(['Escape'], () => {
        if (showing) onClose();
    });

    useEffect(() => {
        const list = itemsRef.current;

        if (!list) {
            setIsScrollbar(false);
            return;
        }

        setIsScrollbar(list.scrollHeight > list.clientHeight);
    }, [displayActive, displayMenu, rendered]);

    useEffect(() => {
        if (showing && Boolean(menu)) {
            if (closeTimer.current) window.clearTimeout(closeTimer.current);

            setSnapshot({
                active,
                stack,
                menu,
            });
            setRendered(true);
            setClosing(false);

            return undefined;
        }

        if (rendered) {
            setClosing(true);
            closeTimer.current = window.setTimeout(() => {
                setRendered(false);
                setClosing(false);
            }, ANIMATION_TIME);
        }

        return undefined;
    }, [active, menu, rendered, showing, stack]);

    useEffect(() => {
        return () => {
            if (closeTimer.current) window.clearTimeout(closeTimer.current);
        };
    }, []);

    if (!rendered || !Boolean(displayMenu)) return null;
    return (
        <div
            className={`${classes.wrapper}${
                closing ? ` ${classes.closing}` : ''
            }`}
        >
            <div
                className={`${classes.header}${
                    isScrollbar ? ` ${classes.headerScrollbar}` : ''
                }`}
            >
                {Boolean(displayStack) && displayStack.length > 0 && (
                    <button
                        type="button"
                        className={`${classes.field} ${classes.sqButton}`}
                        onClick={onBack}
                    >
                        <FontAwesomeIcon icon={['fas', 'chevron-left']} />
                    </button>
                )}
                <div className={`${classes.field} ${classes.content}`}>
                    {displayMenu?.label ?? 'List'}
                </div>
                {displayMenu?.headerAction?.event && (
                    <button
                        type="button"
                        className={`${classes.field} ${classes.sqButton}`}
                        onClick={() =>
                            onHeaderAction(
                                displayMenu.headerAction.event,
                                displayMenu.headerAction.data,
                            )
                        }
                    >
                        <FontAwesomeIcon
                            icon={[
                                'fas',
                                displayMenu.headerAction.icon || 'circle-dot',
                            ]}
                        />
                    </button>
                )}
                <button
                    type="button"
                    className={`${classes.field} ${classes.sqButton}`}
                    onClick={onClose}
                >
                <FontAwesomeIcon icon={['fas', 'xmark']} />
                </button>
            </div>
            <div className={classes.list} ref={itemsRef}>
                {(displayMenu?.items ?? []).map((item, k) => {
                    return (
                        <ListItem
                            key={`${displayActive}-${k}`}
                            index={k}
                            item={item}
                        />
                    );
                })}
            </div>
        </div>
    );
};
