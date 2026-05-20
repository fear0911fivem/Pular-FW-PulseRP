import { isBrowserPreview } from '../../util/Env';

const preview = isBrowserPreview();

export const initialState = {
    visible: preview,
    ammoType: 'long',
    magazine: preview ? 12 : 0,
    total: preview ? 120 : 0,
    grayOut: false,
};

const numberOrFallback = (value, fallback) => {
    const parsed = Number(value);

    return Number.isFinite(parsed) ? parsed : fallback;
};

export default (state = initialState, action) => {
    switch (action.type) {
        case 'UPDATE_AMMO':
            return {
                ...state,
                visible:
                    typeof action.payload.visible === 'boolean'
                        ? action.payload.visible
                        : state.visible,
                ammoType: action.payload.ammoType || state.ammoType,
                magazine: numberOrFallback(
                    action.payload.magazine,
                    state.magazine,
                ),
                total: numberOrFallback(action.payload.total, state.total),
                grayOut:
                    typeof action.payload.grayOut === 'boolean'
                        ? action.payload.grayOut
                        : state.grayOut,
            };
        case 'UI_RESET':
            return initialState;
        default:
            return state;
    }
};
