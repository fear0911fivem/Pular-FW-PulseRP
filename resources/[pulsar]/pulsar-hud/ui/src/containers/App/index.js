import '@babel/polyfill';
import React, { useEffect, useState } from 'react';
import { connect, useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import CssBaseline from '@mui/material/CssBaseline';
import {
    ThemeProvider,
    createTheme,
    StyledEngineProvider,
} from '@mui/material';
import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { far } from '@fortawesome/free-regular-svg-icons';
import { fab } from '@fortawesome/free-brands-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import 'react-circular-progressbar/dist/styles.css';

import Action from '../Action2';
import Hud from '../Hud';
import Notifications from '../Notifications';
import List from '../../components/List';
import Input from '../../components/Input';
import Confirm from '../../components/Confirm';
import InfoOverlay from '../../components/InfoOverlay';
import Overlay from '../../components/Overlay';
import { Progress, ThirdEye, GemTable } from '../../components';

import Interaction from '../../components/Interaction';

import LCD from '../../assets/fonts/lcd.ttf';
import BaiJamjureeRegular from '../../assets/fonts/BaiJamjuree-Regular.ttf';
import BaiJamjureeMedium from '../../assets/fonts/BaiJamjuree-Medium.ttf';
import Dead from './Dead';
import Blindfold from './Blindfold';
import Ingredients from '../../components/Meth';
import DeathTexts from './DeathTexts';
import Arcade from '../Arcade';
import Flashbang from './Flashbang';
import { isBrowserPreview } from '../../util/Env';

library.add(fab, fas, far);

const PREVIEW_VEHICLE_MODES = {
    car: {
        label: 'Car',
        icon: ['fas', 'car'],
        speed: 83,
        rpm: 0.68,
        fuel: 42,
        nos: 75,
        aircraftData: null,
    },
    helicopter: {
        label: 'Heli',
        icon: ['fas', 'helicopter'],
        speed: 0,
        rpm: 0.36,
        fuel: 67,
        nos: 0,
        aircraftData: {
            pitch: 6,
            roll: -12,
            gear: 1,
            agl: 146,
            altitude: 1564,
            airSpeed: 118,
        },
    },
};

const PREVIEW_LIST_MENU = {
    main: {
        label: 'Emotes',
        items: [
            {
                label: 'Emote Binds',
                description: 'Edit your emote binds',
                event: 'Animations:Client:OpenEmoteBinds',
            },
            {
                label: 'Prop Emotes',
                description: 'Open prop emotes submenu',
                submenu: 'emotes-prop',
            },
            {
                label: 'Dance Emotes',
                description: 'Open dance emotes submenu',
                submenu: 'emotes-dance',
            },
            {
                label: 'Quick Actions',
                description: 'Example row with action buttons',
                data: {
                    source: 'browser-preview',
                },
                actions: [
                    {
                        icon: 'check',
                        event: 'Dev:ListMenuAccept',
                    },
                    {
                        icon: 'xmark',
                        event: 'Dev:ListMenuReject',
                    },
                ],
            },
        ],
    },
    'emotes-prop': {
        label: 'Prop Emotes',
        items: [
            {
                label: 'Clipboard',
                description: '/e clipboard',
                event: 'Animations:Client:EmoteMenuEmote',
                data: 'clipboard',
            },
            {
                label: 'Coffee',
                description: '/e coffee',
                event: 'Animations:Client:EmoteMenuEmote',
                data: 'coffee',
            },
            {
                label: 'Phone',
                description: '/e phone',
                event: 'Animations:Client:EmoteMenuEmote',
                data: 'phone',
            },
        ],
    },
    'emotes-dance': {
        label: 'Dance Emotes',
        items: [
            {
                label: 'Dance',
                description: '/e dance',
                event: 'Animations:Client:EmoteMenuEmote',
                data: 'dance',
            },
            {
                label: 'Dance 2',
                description: '/e dance2',
                event: 'Animations:Client:EmoteMenuEmote',
                data: 'dance2',
            },
            {
                label: 'Dance 3',
                description: '/e dance3',
                event: 'Animations:Client:EmoteMenuEmote',
                data: 'dance3',
            },
        ],
    },
};

const previewSwitcherStyles = {
    wrap: {
        position: 'fixed',
        top: 14,
        left: 14,
        zIndex: 99999,
        display: 'flex',
        alignItems: 'center',
        gap: 4,
        padding: 4,
        border: '1px solid rgba(255, 255, 255, 0.18)',
        borderRadius: 6,
        background: 'rgba(10, 14, 18, 0.84)',
        boxShadow: '0 12px 30px rgba(0, 0, 0, 0.35)',
        pointerEvents: 'auto',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
    },
    button: {
        height: 30,
        minWidth: 68,
        border: 0,
        borderRadius: 4,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 7,
        color: 'rgba(255, 255, 255, 0.65)',
        background: 'transparent',
        fontSize: 12,
        fontWeight: 600,
        cursor: 'pointer',
        transition: 'background 160ms ease, color 160ms ease',
    },
    divider: {
        width: 1,
        height: 22,
        margin: '0 2px',
        background: 'rgba(255, 255, 255, 0.18)',
    },
    activeButton: {
        color: '#ffffff',
        background: 'rgba(135, 218, 33, 0.28)',
        boxShadow: 'inset 0 0 0 1px rgba(135, 218, 33, 0.5)',
    },
};

const DevVehiclePreviewSwitch = () => {
    const dispatch = useDispatch();
    const listShowing = useSelector((state) => state.list.showing);
    const [mode, setMode] = useState('car');

    const toggleListMenu = () => {
        dispatch({
            type: listShowing ? 'CLOSE_LIST_MENU' : 'SET_LIST_MENU',
            payload: {
                menus: PREVIEW_LIST_MENU,
            },
        });
    };

    useEffect(() => {
        const preview = PREVIEW_VEHICLE_MODES[mode];

        dispatch({ type: 'SHOW_VEHICLE', payload: {} });
        dispatch({ type: 'UPDATE_IGNITION', payload: { ignition: true } });
        dispatch({ type: 'UPDATE_SPEED', payload: { speed: preview.speed } });
        dispatch({ type: 'UPDATE_RPM', payload: { rpm: preview.rpm } });
        dispatch({ type: 'UPDATE_FUEL', payload: { fuel: preview.fuel } });
        dispatch({ type: 'UPDATE_NOS', payload: { nos: preview.nos } });
        dispatch({
            type: 'UPDATE_SEATBELT',
            payload: { seatbelt: mode === 'car' },
        });
        dispatch({
            type: 'UPDATE_CRUISE',
            payload: { cruise: mode === 'car' },
        });
        dispatch({
            type: 'UPDATE_ENGINELIGHT',
            payload: { checkEngine: mode === 'car' },
        });
        dispatch({
            type: 'UPDATE_AIRCRAFT',
            payload: { aircraftData: preview.aircraftData },
        });
    }, [dispatch, mode]);

    return (
        <div style={previewSwitcherStyles.wrap}>
            {Object.entries(PREVIEW_VEHICLE_MODES).map(([key, item]) => {
                const active = key === mode;

                return (
                    <button
                        key={key}
                        type="button"
                        onClick={() => setMode(key)}
                        style={{
                            ...previewSwitcherStyles.button,
                            ...(active
                                ? previewSwitcherStyles.activeButton
                                : {}),
                        }}
                    >
                        <FontAwesomeIcon icon={item.icon} />
                        {item.label}
                    </button>
                );
            })}
            <div style={previewSwitcherStyles.divider} />
            <button
                type="button"
                onClick={toggleListMenu}
                style={{
                    ...previewSwitcherStyles.button,
                    minWidth: 96,
                    ...(listShowing ? previewSwitcherStyles.activeButton : {}),
                }}
            >
                <FontAwesomeIcon icon={['fas', 'list']} />
                ListMenu
            </button>
        </div>
    );
};

const LCDFont = {
    fontFamily: 'LCD',
    fontStyle: 'normal',
    fontDisplay: 'swap',
    fontWeight: 400,
    src: `
      url(${LCD}) format('truetype')
    `,
};

const BaiJamjureeRegularFont = {
    fontFamily: 'Bai Jamjuree',
    fontStyle: 'normal',
    fontDisplay: 'swap',
    fontWeight: 400,
    src: `url(${BaiJamjureeRegular}) format('truetype')`,
};

const BaiJamjureeMediumFont = {
    fontFamily: 'Bai Jamjuree',
    fontStyle: 'normal',
    fontDisplay: 'swap',
    fontWeight: 500,
    src: `url(${BaiJamjureeMedium}) format('truetype')`,
};

const App = ({ hidden }) => {
    const progShowing = useSelector((state) => state.progress.showing);
    const isLis = useSelector((state) => state.list.showing);
    const isInp = useSelector((state) => state.input.showing);
    const isConf = useSelector((state) => state.confirm.showing);
    const isMeth = useSelector((state) => state.meth.showing);

    const muiTheme = createTheme({
        typography: {
            fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        },
        palette: {
            primary: {
                main: '#E5A502',
                light: '#E8A933',
                dark: '#FA5800',
                contrastText: '#ffffff',
            },
            secondary: {
                main: '#141414',
                light: '#1c1c1c',
                dark: '#0f0f0f',
                contrastText: '#ffffff',
            },
            error: {
                main: '#6e1616',
                light: '#a13434',
                dark: '#430b0b',
            },
            success: {
                main: '#52984a',
                light: '#60eb50',
                dark: '#244a20',
            },
            warning: {
                main: '#f09348',
                light: '#f2b583',
                dark: '#b05d1a',
            },
            info: {
                main: '#4056b3',
                light: '#247ba5',
                dark: '#175878',
            },
            text: {
                main: '#ffffff',
                alt: '#A7A7A7',
                info: '#919191',
                light: '#ffffff',
                dark: '#000000',
            },
            alt: {
                green: '#008442',
                greenDark: '#064224',
            },
            border: {
                main: '#e0e0e008',
                light: '#ffffff',
                dark: '#26292d',
                input: 'rgba(255, 255, 255, 0.23)',
                divider: 'rgba(255, 255, 255, 0.12)',
            },
            mode: 'dark',
        },
        components: {
            MuiCssBaseline: {
                styleOverrides: {
                    body: {
                        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
                        '.fade-enter': {
                            opacity: 0,
                        },
                        '.fade-exit': {
                            opacity: 1,
                        },
                        '.fade-enter-active': {
                            opacity: 1,
                        },
                        '.fade-exit-active': {
                            opacity: 0,
                        },
                        '.fade-enter-active, .fade-exit-active': {
                            transition: 'opacity 500ms',
                        },
                        '@font-face': [
                            LCDFont,
                            BaiJamjureeRegularFont,
                            BaiJamjureeMediumFont,
                        ],
                    },
                    html: {
                        background: isBrowserPreview()
                            ? '#1e1e1e'
                            : 'transparent',
                        'input::-webkit-outer-spin-button, input::-webkit-inner-spin-button':
                            {
                                WebkitAppearance: 'none',
                                margin: 0,
                            },
                    },
                    '*': {
                        fontFamily: 'inherit',
                        '&::-webkit-scrollbar': {
                            width: 6,
                        },
                        '&::-webkit-scrollbar-thumb': {
                            background: 'rgba(0, 0, 0, 0.5)',
                            transition: 'background ease-in 0.15s',
                        },
                        '&::-webkit-scrollbar-thumb:hover': {
                            background: '#ffffff17',
                        },
                        '&::-webkit-scrollbar-track': {
                            background: 'transparent',
                        },
                    },
                    '@keyframes critical': {
                        '0%, 49%': {
                            backgroundColor: '#0f0f0f',
                        },
                        '50%, 100%': {
                            backgroundColor: '#1b1c2c',
                        },
                    },
                    '@keyframes critical-border': {
                        '0%, 49%': {
                            borderColor: '#ffffffc7',
                        },
                        '50%, 100%': {
                            borderColor: `#de3333`,
                        },
                    },
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
                },
            },
            MuiPaper: {
                styleOverrides: {
                    root: {
                        background: '#0f0f0f',
                    },
                },
            },
        },
    });

    return (
        <StyledEngineProvider injectFirst>
            <ThemeProvider theme={muiTheme}>
                <CssBaseline />
                <Dead />
                <Blindfold />
                <Flashbang />
                <DeathTexts />
                <InfoOverlay />
                <Overlay />
                <Hud />
                <Notifications />
                <Action />
                {isBrowserPreview() && <DevVehiclePreviewSwitch />}
                {isMeth && <Ingredients />}
                {isLis && <List />}
                {isInp && <Input />}
                {isConf && <Confirm />}
                {progShowing && <Progress />}
                <ThirdEye />
                <Interaction />
                <GemTable />
            </ThemeProvider>
        </StyledEngineProvider>
    );
};

App.propTypes = {
    hidden: PropTypes.bool.isRequired,
};

const mapStateToProps = (state) => ({ hidden: state.app.hidden });

export default connect(mapStateToProps)(App);
