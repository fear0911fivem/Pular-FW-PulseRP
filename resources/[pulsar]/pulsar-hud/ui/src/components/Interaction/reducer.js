import { isBrowserPreview } from '../../util/Env';

const preview = isBrowserPreview();

export const initialState = {
    show: preview,
    menuItems: preview ? [
        {
            id: 1,
            label: 'Vehicle',
            icon: 'car',
            shouldShow: true,
            action: 'preview_vehicle',
            labelFunc: null,
        },
        {
            id: 2,
            label: 'Inventory',
            icon: 'box-open',
            shouldShow: true,
            action: 'preview_inventory',
            labelFunc: null,
        },
        {
            id: 3,
            label: 'Phone',
            icon: 'mobile-screen-button',
            shouldShow: true,
            action: 'preview_phone',
            labelFunc: null,
        },
        {
            id: 4,
            label: 'Animations',
            icon: 'person-walking',
            shouldShow: true,
            action: 'preview_animations',
            labelFunc: null,
        },
        {
            id: 5,
            label: 'Cash',
            icon: 'dollar-sign',
            shouldShow: true,
            action: 'preview_cash',
            labelFunc: null,
        },
        {
            id: 6,
            label: 'Emotes',
            icon: 'face-smile',
            shouldShow: true,
            action: 'preview_emotes',
            labelFunc: null,
        },
        {
            id: 7,
            label: 'Documents',
            icon: 'file-lines',
            shouldShow: true,
            action: 'preview_documents',
            labelFunc: null,
        },
        {
            id: 8,
            label: 'Settings',
            icon: 'gear',
            shouldShow: true,
            action: 'preview_settings',
            labelFunc: null,
        },
    ] : Array(),
    layer: 0,
};

export default (state = initialState, action) => {
    switch (action.type) {
        case 'SHOW_INTERACTION_MENU':
            return {
                ...state,
                show: action.payload.toggle,
            };
        case 'SET_INTERACTION_LAYER':
            return {
                ...state,
                layer: action.payload.layer,
            };
        case 'SET_INTERACTION_MENU_ITEMS':
            return {
                ...state,
                menuItems: action.payload.items.sort((a, b) => a.id - b.id),
            };
        default:
            return state;
    }
};
