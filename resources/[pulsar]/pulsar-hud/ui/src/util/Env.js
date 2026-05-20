const getSearchParams = () =>
    typeof window !== 'undefined'
        ? new URLSearchParams(window.location.search)
        : new URLSearchParams();

export const getResourceName = () => {
    if (
        typeof window !== 'undefined' &&
        typeof window.GetParentResourceName === 'function'
    ) {
        return window.GetParentResourceName();
    }

    return getSearchParams().get('resource') || 'pulsar-hud';
};

export const isGameNui = () =>
    typeof window !== 'undefined' &&
    (Boolean(window.invokeNative) ||
        typeof window.GetParentResourceName === 'function' ||
        getSearchParams().get('nui') === '1');

export const isBrowserPreview = () =>
    process.env.NODE_ENV !== 'production' && !isGameNui();
