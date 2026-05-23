import React from 'react';
import { makeStyles } from '@mui/styles';
import { useDispatch } from 'react-redux';

import Nui from '../../../util/Nui';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { Sanitize } from '../../../util/Parser';

const useStyles = makeStyles(() => ({
    wrapper: {
        display: 'flex',
        gap: '1rem',
        padding: '.75rem',
        borderRadius: '.25rem',
        border: '1.5px solid rgba(255, 255, 255, 0.15)',
        background: 'rgba(26, 31, 20, 0.75)',
        transition: 'border 200ms ease, background 200ms ease',
        color: '#fff',
        alignItems: 'center',
        width: '100%',
        userSelect: 'none',
        boxSizing: 'border-box',
        '&.button': {
            cursor: 'pointer',
        },
        '&.button:hover': {
            border: '1.5px solid #87da21',
            background: 'rgba(58, 86, 24, 0.8)',
        },
        '&.disabled': {
            pointerEvents: 'none',
            filter: 'opacity(.5) grayscale(.5)',
        },
        '&.disabled $heading, &.disabled $description, &.disabled $action svg':
            {
                color: 'rgba(255, 255, 255, 0.5)',
            },
    },
    col: {
        display: 'flex',
        flexDirection: 'column',
        gap: '.25rem',
        flex: 1,
        minWidth: 0,
    },
    heading: {
        color: '#fff',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '1rem',
        lineHeight: 1.25,
        fontWeight: 400,
        margin: 0,
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
    },
    description: {
        color: '#fff',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '.875rem',
        fontWeight: 400,
        lineHeight: 1.25,
        margin: 0,
        whiteSpace: 'pre-wrap',
        '& p': {
            margin: 0,
        },
    },
    actions: {
        marginLeft: 'auto',
        display: 'flex',
        alignItems: 'center',
        gap: '.5rem',
        paddingRight: '1rem',
        flexShrink: 0,
    },
    action: {
        appearance: 'none',
        outline: 0,
        border: 0,
        background: 'transparent',
        color: '#fff',
        padding: 0,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        cursor: 'pointer',
        transition: 'color 200ms ease',
        '&:hover': {
            color: '#fff',
        },
        '&.noClick': {
            cursor: 'unset',
            pointerEvents: 'none',
        },
        '& svg': {
            color: '#fff',
            width: '1rem',
            height: '1rem',
        },
    },
}));

export default ({ index, item }) => {
    const classes = useStyles();
    const dispatch = useDispatch();

    const onClick = () => {
        if (item.submenu) {
            Nui.send('ListMenu:SubMenu', {
                submenu: item.submenu,
            });
            dispatch({
                type: 'CHANGE_MENU',
                payload: {
                    menu: item.submenu,
                },
            });
        } else if (item.event) {
            Nui.send('ListMenu:Clicked', {
                event: item.event,
                data: item.data,
                type: item.type,
            });
        }
    };

    const onAction = (event) => {
        Nui.send('ListMenu:Clicked', {
            event: event,
            data: item.data,
            type: item.type,
        });
    };

    const isButton =
        !Boolean(item.actions) && (Boolean(item.event) || Boolean(item.submenu));

    return (
        <div
            className={`${classes.wrapper}${isButton ? ' button' : ''}${
                item.disabled ? ' disabled' : ''
            }`}
            onClick={isButton ? onClick : undefined}
        >
            <div className={classes.col}>
                <p className={classes.heading}>{item.label}</p>
                <p className={classes.description}>
                    {Sanitize(item.description)}
                </p>
            </div>
            {Boolean(item.submenu) || Boolean(item.actions) ? (
                <div className={classes.actions}>
                    {Boolean(item.submenu) && (
                        <button
                            type="button"
                            className={`${classes.action} noClick`}
                            tabIndex={-1}
                        >
                            <FontAwesomeIcon
                                icon={['fas', 'chevron-right']}
                            />
                        </button>
                    )}
                    {(item.actions ?? []).map((action, k) => {
                        return (
                            <button
                                type="button"
                                key={`${index}-action-${k}`}
                                onClick={() => onAction(action.event)}
                                className={classes.action}
                            >
                                <FontAwesomeIcon icon={['fas', action.icon]} />
                            </button>
                        );
                    })}
                </div>
            ) : null}
        </div>
    );
};
