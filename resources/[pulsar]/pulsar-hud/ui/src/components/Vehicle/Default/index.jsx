import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { Fade, Grid, LinearProgress, useTheme } from '@mui/material';
import { makeStyles } from '@mui/styles';
import ReactHtmlParser from 'react-html-parser';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { styled } from '@mui/material/styles';
import { linearProgressClasses } from '@mui/material/LinearProgress';

import rpmImg from '../../../assets/rpm.webp';
import EngineWarningIcon from '../components/EngineWarningIcon';

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
    wrapper: {
        position: 'absolute',
        left: 0,
        right: 0,
        bottom: 20,
        margin: 'auto',
        width: 'fit-content',
        filter:
            `drop-shadow(0 0 2px ${theme.palette.secondary.dark}e0) ` +
            'drop-shadow(0 0 0.75rem rgba(0, 0, 0, 0.75))',
        fontSize: 30,
        color: theme.palette.text.main,
        textAlign: 'center',
    },

    cluster: {
        width: 'fit-content',
        margin: 'auto',
        position: 'absolute',
        bottom: 25,
        left: 0,
        right: 0,
        position: 'relative',
        width: 255,
    },
    dashIcons: {
        padding: 5,
        textAlign: 'center',
    },
    dashIcon: {
        textAlign: 'center',
        display: 'block',
        fontSize: 16,
        lineHeight: '45px',
        padding: 5,
        fontSize: 30,
        zIndex: 5,

        '&.seatbelt': {
            color: `${theme.palette.secondary.light}80`,
            display: 'block',
            position: 'absolute',
            height: 'fit-content',
            left: 5,
            top: 0,
            bottom: 0,
            margin: 'auto',

            '&.active': {
                animation: '$flash linear 3s infinite',
                color: theme.palette.warning.main,
                filter: 'drop-shadow(0 0 0.45rem rgba(240, 147, 72, 0.65))',
                textShadow: '0 0.25rem 1rem rgba(240, 147, 72, 0.55)',
            },
        },
        '&.checkEngine': {
            color: `${theme.palette.secondary.light}80`,
            display: 'block',
            position: 'absolute',
            height: 'fit-content',
            right: 5,
            top: 0,
            bottom: 0,
            margin: 'auto',

            '&.active': {
                animation: '$flash linear 1s infinite',
                color: theme.palette.error.main,
                filter: 'drop-shadow(0 0 0.45rem rgba(255, 0, 0, 0.7))',
                textShadow: '0 0.25rem 1rem rgba(255, 0, 0, 0.6)',
            },
        },
    },

    speedContainer: {
        padding: 5,
        display: 'flex',
        textAlign: 'center',
        background: `${theme.palette.secondary.dark}80`,
        position: 'relative',
        boxShadow:
            '0 0.25rem 0.75rem rgba(0, 0, 0, 0.45), inset 0 0 0.75rem rgba(255, 255, 255, 0.035)',
    },
    speedText: {
        fontSize: 38,
        textShadow:
            '0 0.25rem 0.25rem rgba(135, 218, 33, 0.18), 0 0.25rem 1rem rgba(135, 218, 33, 0.28)',
    },
    speedMeasure: {
        marginLeft: 5,
        fontSize: 16,
        textShadow: '0 0.25rem 0.8rem rgba(255, 255, 255, 0.22)',
    },
    rpmBg: {
        background: `${theme.palette.secondary.dark}80`,
        borderLeft: `2px solid ${theme.palette.secondary.dark}80`,
        borderRight: `2px solid ${theme.palette.secondary.dark}80`,
        borderBottom: `2px solid ${theme.palette.secondary.dark}80`,
    },
    rpmIndicator: {
        background: `url(${rpmImg})`,
        backgroundPosition: 'center',
        height: 8,
        boxShadow:
            '0 0.25rem 0.25rem rgba(135, 218, 33, 0.2), 0 0.25rem 1rem rgba(135, 218, 33, 0.3)',
    },
}));

export default () => {
    const classes = useStyles();
    const theme = useTheme();

    const config = useSelector((state) => state.hud.config);

    const showing = useSelector((state) => state.vehicle.showing);
    const aircraftData = useSelector((state) => state.vehicle.aircraftData);
    const ignition = useSelector((state) => state.vehicle.ignition);
    const speed = useSelector((state) => state.vehicle.speed);
    const speedMeasure = useSelector((state) => state.vehicle.speedMeasure);
    const seatbelt = useSelector((state) => state.vehicle.seatbelt);
    const checkEngine = useSelector((state) => state.vehicle.checkEngine);
    const seatbeltHide = useSelector((state) => state.vehicle.seatbeltHide);
    const cruise = useSelector((state) => state.vehicle.cruise);

    const fuelHide = useSelector((state) => state.vehicle.fuelHide);
    const fuel = useSelector((state) => state.vehicle.fuel);

    const rpm = useSelector((state) => state.vehicle.rpm);

    const nos = useSelector((state) => state.vehicle.nos);

    const isShiftedUp = () => {
        return (
            config.layout == 'default' ||
            config.layout == 'center' ||
            (config.layout == 'minimap' && config.buffsAnchor2) ||
            (config.layout == 'condensed' &&
                config.condenseAlignment == 'center')
        );
    };

    const [speedStr, setSpeedStr] = useState(speed.toString());

    useEffect(() => {
        if (speed === 0) {
            setSpeedStr(`<span class="filler">000</span>`);
        } else if (speed < 10) {
            setSpeedStr(`<span class="filler">00</span>${speed.toString()}`);
        } else if (speed < 100) {
            setSpeedStr(`<span class="filler">0</span>${speed.toString()}`);
        } else {
            setSpeedStr(speed.toString());
        }
    }, [speed]);

    const RPMProggressBar = styled(LinearProgress)(({ theme }) => ({
        height: 10,
        width: '100%',
        [`&.${linearProgressClasses.colorPrimary}`]: {
            background: `${theme.palette.secondary.dark}80`,
            borderLeft: `2px solid ${theme.palette.secondary.dark}80`,
            borderRight: `2px solid ${theme.palette.secondary.dark}80`,
            borderBottom: `2px solid ${theme.palette.secondary.dark}80`,
        },
        [`& .${linearProgressClasses.bar}`]: {
            background: `url(${rpmImg})`,
            backgroundPosition: 'center',
            boxShadow:
                '0 0.25rem 0.25rem rgba(135, 218, 33, 0.2), 0 0.25rem 1rem rgba(135, 218, 33, 0.3)',
        },
    }));

    const FuelProggressBar = styled(LinearProgress)(({ theme, value }) => ({
        height: nos > 0 ? 8 : 10,
        width: '100%',
        [`&.${linearProgressClasses.colorPrimary}`]: {
            background: `${theme.palette.secondary.dark}80`,
            borderLeft: `2px solid ${theme.palette.secondary.dark}80`,
            borderRight: `2px solid ${theme.palette.secondary.dark}80`,
            borderTop:
                nos > 0
                    ? 'none'
                    : `2px solid ${theme.palette.secondary.dark}80`,
        },
        [`& .${linearProgressClasses.bar}`]: {
            transition: 'color ease-in 0.15s',
            animation: value <= 10 ? '$flash linear 0.5s infinite' : 'none',
            background:
                value >= 50
                    ? theme.palette.success.main
                    : value >= 10
                    ? theme.palette.warning.main
                    : value >= 0
                    ? theme.palette.error.main
                    : theme.palette.primary.main,
            boxShadow:
                value >= 50
                    ? '0 0.25rem 0.25rem rgba(135, 218, 33, 0.25), 0 0.25rem 1rem rgba(135, 218, 33, 0.4)'
                    : value >= 10
                    ? '0 0.25rem 0.25rem rgba(240, 147, 72, 0.25), 0 0.25rem 1rem rgba(240, 147, 72, 0.42)'
                    : '0 0.25rem 0.25rem rgba(255, 0, 0, 0.35), 0 0.25rem 1rem rgba(255, 0, 0, 0.55)',
        },
    }));

    const NosProggressBar = styled(LinearProgress)(({ theme, value }) => ({
        height: 12,
        width: '100%',
        [`&.${linearProgressClasses.colorPrimary}`]: {
            background: `${theme.palette.secondary.dark}80`,
            borderBottom: `2px solid ${theme.palette.secondary.dark}80`,
            borderLeft: `2px solid ${theme.palette.secondary.dark}80`,
            borderRight: `2px solid ${theme.palette.secondary.dark}80`,
            borderTop: `2px solid ${theme.palette.secondary.dark}80`,
        },
        [`& .${linearProgressClasses.bar}`]: {
            animation: value <= 10 ? '$flash linear 1s infinite' : 'none',
            background: '#0078ec',
            boxShadow:
                '0 0.25rem 0.25rem rgba(0, 120, 236, 0.25), 0 0.25rem 1rem rgba(0, 120, 236, 0.45)',
        },
    }));

    return (
        <Fade in={showing && !aircraftData}>
            <div
                className={classes.wrapper}
                style={{ bottom: isShiftedUp() ? 45 : 0 }}
            >
                <Grid container className={classes.cluster}>
                    <Grid item xs={12} className={classes.dashIcons}>
                        <span className={classes.dashIcon}>
                            <FontAwesomeIcon
                                className={classes.cruiseIcon}
                                icon={['fas', 'gauge']}
                                style={{
                                    color: Boolean(cruise)
                                        ? theme.palette.info.main
                                        : 'transparent',
                                }}
                            />
                        </span>
                    </Grid>
                    {ignition && nos > 0 && (
                        <Grid item xs={12}>
                            <NosProggressBar
                                variant="determinate"
                                value={nos}
                            />
                        </Grid>
                    )}
                    {ignition && !Boolean(fuelHide) && (
                        <Grid item xs={12}>
                            <FuelProggressBar
                                variant="determinate"
                                value={fuel}
                            />
                        </Grid>
                    )}
                    <Grid item xs={12} className={classes.speedContainer}>
                        {!seatbeltHide && (
                            <span
                                className={`${classes.dashIcon} seatbelt ${
                                    !seatbelt ? 'active' : ''
                                }`}
                            >
                                <FontAwesomeIcon
                                    icon={['fas', 'triangle-exclamation']}
                                />
                            </span>
                        )}
                        {ignition ? (
                            <div style={{ margin: 'auto' }}>
                                <span className={classes.speedText}>
                                    {ReactHtmlParser(speedStr)}
                                </span>
                                <span className={classes.speedMeasure}>
                                    {speedMeasure}
                                </span>
                            </div>
                        ) : (
                            <div style={{ margin: 'auto' }}>
                                <span className={classes.speedText}>Off</span>
                            </div>
                        )}
                        <span
                            className={`${classes.dashIcon} checkEngine ${
                                Boolean(checkEngine) ? 'active' : ''
                            }`}
                        >
                            <EngineWarningIcon />
                        </span>
                    </Grid>
                    {config.showRPM && (
                        <Grid item xs={12} className={classes.rpmBg}>
                            <div
                                className={classes.rpmIndicator}
                                style={{
                                    width: `${ignition ? rpm * 100 : 0}%`,
                                }}
                            ></div>
                        </Grid>
                    )}
                </Grid>
            </div>
        </Fade>
    );
};
