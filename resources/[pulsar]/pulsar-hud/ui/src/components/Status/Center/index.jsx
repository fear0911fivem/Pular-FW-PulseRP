import React from 'react';
import { useSelector } from 'react-redux';
import { makeStyles, withTheme } from '@mui/styles';
import { CSSTransition, TransitionGroup } from 'react-transition-group';

import NumberStatus from '../components/Number';
import BarStatus from '../components/Bar';

const ACTIVE_COLOR = '#87da21';
const ARMOR_COLOR = '#00b2ff';
const LOW_HEALTH_COLOR = '#ff0000';

const useStyles = makeStyles((theme) => ({
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
    status: {
        fontSize: 30,
        width: 'fit-content',
        textAlign: 'center',
        height: '100vh',
        width: '100vw',
    },
    iconWrapper: {
        position: 'relative',
        height: 50,
        width: 50,
        '&:not(:last-of-type)': {
            marginRight: 20,
        },
        '&.low': {
            animation: '$flash linear 1s infinite',
        },
    },
    iconProg: {
        position: 'absolute',
        height: 5,
        left: 0,
        right: 0,
        bottom: 0,
        margin: 'auto',
        zIndex: 5,
    },
    barBg: {
        position: 'absolute',
        height: 7,
        left: 0,
        right: 0,
        bottom: 0,
        margin: 'auto',
        zIndex: 5,
        boxShadow: '0 0 5px #000',
        background: theme.palette.secondary.dark,
        border: `1px solid ${theme.palette.border.divider}`,
    },
    bars: {
        display: 'flex',
        gap: 4,
        flexFlow: 'row',
        position: 'absolute',
        bottom: 2,
        left: 0,
        right: 0,
        margin: 'auto',
        width: 'fit-content',
    },
    bar: {
        maxWidth: '100%',
        height: '100%',
        transition: 'width ease-in 0.15s',
    },
    iconAvatar: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        margin: 'auto',
        // backgroundImage: `linear-gradient(to top, ${theme.palette.secondary.dark}7a, transparent)`,
        '& svg, & span': {
            position: 'absolute',
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            margin: 'auto',
            fontSize: 22,
            textShadow: '0 0 5px #000',
            color: theme.palette.text.main,
        },
    },
}));

export default withTheme(() => {
    const classes = useStyles();

    const config = useSelector((state) => state.hud.config);
    const position = useSelector((state) => state.hud.position);
    const statuses = useSelector((state) => state.status.statuses);
    const isDead = useSelector((state) => state.status.isDead);
    const health = useSelector((state) => state.status.health);
    const maxHealth = useSelector((state) => state.status.maxHealth);
    const armor = useSelector((state) => state.status.armor);
    const healthPercent = Math.min(
        100,
        Math.max(0, (Number(health) / Math.max(1, Number(maxHealth))) * 100),
    );
    const healthColor =
        healthPercent <= 10 && !isDead ? LOW_HEALTH_COLOR : ACTIVE_COLOR;

    const els = [
        {
            icon: 'shield',
            color: isDead ? '#fff' : ARMOR_COLOR,
            value: armor,
            options: {
                hideZero: true,
                order: 1,
            },
        },
        {
            icon: isDead ? 'skull' : 'heart',
            color: isDead ? '#fff' : healthColor,
            value: isDead ? 100 : health,
            flash: true,
            options: {
                hideZero: false,
                visibleWhileDead: true,
                order: 2,
                customMax: isDead ? 100 : maxHealth,
                forceIcon: isDead,
                critical: healthPercent <= 10 && !isDead,
            },
        },
        ...statuses,
    ];

    const getStatusElem = (s) => {
        if (Boolean(s?.options?.force)) {
            switch (s?.options?.force) {
                case 'numbers':
                    return <NumberStatus status={s} />;
                default:
                    return <BarStatus status={s} />;
            }
        } else {
            switch (config.statusType) {
                case 'numbers':
                    return <NumberStatus status={s} />;
                default:
                    return <BarStatus status={s} />;
            }
        }
    };

    return (
        <>
            <TransitionGroup className={classes.status}>
                <div className={classes.bars}>
                    {els
                        .filter((status) => status.name !== 'radio-freq')
                        .sort((a, b) => a?.options?.order - b?.options?.order)
                        .map((s, i) => {
                            return (
                                <CSSTransition
                                    key={`status-${i}`}
                                    timeout={500}
                                    classNames="fade"
                                >
                                    {getStatusElem(s)}
                                </CSSTransition>
                            );
                        })}
                </div>
            </TransitionGroup>
        </>
    );
});
