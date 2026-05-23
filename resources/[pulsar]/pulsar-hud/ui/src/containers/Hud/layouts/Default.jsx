import React from 'react';
import { useSelector } from 'react-redux';
import { Fade } from '@mui/material';
import { makeStyles } from '@mui/styles';

import { Location, Waypoint } from '../../../components';
import {
    Aircraft,
    Minimalistic,
    Default as VehicleDefault,
    Simple as VehicleSimple,
} from '../../../components/Vehicle';
import { Default as Status } from '../../../components/Status';

const useStyles = makeStyles((theme) => ({
    wrapper: {
        position: 'relative',
        height: '100%',
        width: '100%',
    },
    statusAnchor: {
        position: 'absolute',
        bottom: '1.55rem',
        left: '1.8rem',
        height: 'fit-content',
        width: 'fit-content',
        pointerEvents: 'none',
    },
}));

export default () => {
    const classes = useStyles();
    const showing = useSelector((state) => state.hud.showing);

    const config = useSelector((state) => state.hud.config);

    const getVehicleLayout = () => {
        switch (config.vehicle) {
            case 'simple':
                return <VehicleSimple />;
            case 'minimal':
                return <Minimalistic />;
            default:
                return <VehicleDefault />;
        }
    };

    return (
        <Fade in={showing}>
            <div className={classes.wrapper}>
                <div className={classes.statusAnchor}>
                    <Status />
                </div>
                <Location />
                <Waypoint />
                <Aircraft />
                {getVehicleLayout()}
            </div>
        </Fade>
    );
};
