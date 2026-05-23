import { isBrowserPreview } from '../../util/Env';

const preview = isBrowserPreview();

export const initialState = {
    showing: preview,
    ignition: preview,
    nos: preview ? 75 : 0,
    speed: 0,
    rpm: 0.4,
    speedMeasure: 'MPH',
    seatbelt: !preview,
    seatbeltHide: false,
    cruise: preview,
    checkEngine: preview,
    fuel: 8,
    fuelHide: false,
    aircraftData: null,
    markerDist: preview ? '1.4' : 0,
};

export default (state = initialState, action) => {
    switch (action.type) {
        case 'SHOW_VEHICLE':
            return {
                ...state,
                showing: true,
            };
        case 'HIDE_VEHICLE':
            return {
                ...state,
                showing: false,
                aircraftData: null,
                markerDist: 0,
            };
        case 'UPDATE_IGNITION':
            return {
                ...state,
                ignition: action.payload.ignition,
            };
        case 'UPDATE_RPM':
            return {
                ...state,
                rpm: action.payload.rpm,
            };
        case 'UPDATE_SPEED':
            return {
                ...state,
                speed: action.payload.speed,
            };
        case 'UPDATE_SPEED_MEASURE':
            return {
                ...state,
                speedMeasure: action.payload.measurement,
            };
        case 'UPDATE_SEATBELT':
            return {
                ...state,
                seatbelt: action.payload.seatbelt,
            };
        case 'SHOW_SEATBELT':
            return {
                ...state,
                seatbeltHide: false,
            };
        case 'HIDE_SEATBELT':
            return {
                ...state,
                seatbeltHide: true,
            };
        case 'UPDATE_CRUISE':
            return {
                ...state,
                cruise: action.payload.cruise,
            };
        case 'UPDATE_ENGINELIGHT':
            return {
                ...state,
                checkEngine: action.payload.checkEngine,
            };
        case 'SHOW_HUD':
        case 'UPDATE_FUEL':
            return {
                ...state,
                fuel: Boolean(action.payload.fuel)
                    ? action.payload.fuel
                    : state.fuel,
                fuelHide:
                    typeof action.payload.fuelHide == 'boolean'
                        ? action.payload.fuelHide
                        : state.fuelHide,
            };
        case 'SHOW_FUEL':
            return {
                ...state,
                fuelHide: false,
            };
        case 'HIDE_FUEL':
            return {
                ...state,
                fuelHide: true,
            };
        case 'UPDATE_NOS':
            return {
                ...state,
                nos: action.payload.nos,
            };
        case 'UPDATE_AIRCRAFT':
            return {
                ...state,
                aircraftData: action.payload.aircraftData || null,
            };
        case 'UPDATE_MARKER_DISTANCE':
            return {
                ...state,
                markerDist: action.payload.markerDist || 0,
            };
        default:
            return state;
    }
};
