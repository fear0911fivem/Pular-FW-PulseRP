import { createTheme, MantineColorsTuple } from '@mantine/core';

export const tokens = {
    // Backgrounds — deep space dark purple
    bgMain:        'rgba(10,6,20,0.95)',
    bgLight:       'rgba(20,12,40,0.92)',
    bgDark:        'rgba(5,3,12,0.95)',
    // Purple borders
    borderTeal:       'rgba(124,58,237,0.3)',
    borderTealHover:  'rgba(124,58,237,0.6)',
    borderSubtle:     'rgba(255,255,255,0.06)',
    // Purple fills
    tealFaint:     'rgba(124,58,237,0.2)',
    selectedBg:    'rgba(124,58,237,0.15)',
    // Text
    textPrimary:   '#ffffff',
    textSecondary: 'rgba(255,255,255,0.7)',
    textMuted:     'rgba(255,255,255,0.35)',
    // Error / locked
    errorFaint:    'rgba(255,100,100,0.2)',
    errorText:     'rgba(255,100,100,0.9)',
  } as const;

const purple: MantineColorsTuple = [
    '#f0ebff',
    '#e0d6fe',
    '#c2aefd',
    '#a385fc',
    '#845cfb',
    '#7c3aed', // [5] primary
    '#6d28d9',
    '#5b21b6',
    '#4c1d95',
    '#3b0764',
];

export const theme = createTheme({
    primaryColor: 'purple',
    colors: { purple },

    fontFamily: "'Rajdhani', sans-serif",
    headings: {
        fontFamily: "'Orbitron', sans-serif",
    },

    defaultRadius: 2,
    black: '#0a0614',
    white: '#ffffff',
    components: {
        Paper: {
            defaultProps: {
                bg: 'rgba(10,6,20,0.95)',
            },
        },
        ScrollArea: {
            styles: {
                scrollbar: {
                    '&[data-orientation="vertical"]': { width: 4 },
                },
                thumb: {
                    backgroundColor: 'rgba(124,58,237,0.3)',
                    '&:hover': { backgroundColor: '#7c3aed' },
                },
            },
        },
    },
});
