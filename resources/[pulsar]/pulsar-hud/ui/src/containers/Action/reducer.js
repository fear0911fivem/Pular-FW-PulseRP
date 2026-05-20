import { isBrowserPreview } from '../../util/Env';

const preview = isBrowserPreview();

export const initialState = {
    showing: preview,
    message: preview ? '{key}K{/key} Test Action' : null,
};

export default (state = initialState, action) => {
    switch (action.type) {
        case 'SHOW_ACTION':
            return {
                ...state,
                message: action.payload.message,
                buttons: action.payload.buttons,
                showing: true,
            };
        case 'HIDE_ACTION':
            return {
                ...state,
                showing: false,
            };
        default:
            return state;
    }
};
