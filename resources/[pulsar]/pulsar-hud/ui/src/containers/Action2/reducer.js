import { isBrowserPreview } from '../../util/Env';

const preview = isBrowserPreview();

export const initialState = {
    actions:
        preview
            ? [
                  {
                      id: 'test',
                      message: '{key}K{/key} Test Action',
                  },
              ]
            : Array(),
};

export default (state = initialState, action) => {
    switch (action.type) {
        case 'ADD_ACTION':
            return {
                ...state,
                actions: [...state.actions, action.payload],
            };
        case 'REMOVE_ACTION':
            return {
                ...state,
                actions: [
                    ...state.actions.filter((a) => a.id != action.payload.id),
                ],
            };
        case 'REMOVE_ALL_ACTIONS':
            return {
                ...state,
                actions: Array(),
            };
        default:
            return state;
    }
};
