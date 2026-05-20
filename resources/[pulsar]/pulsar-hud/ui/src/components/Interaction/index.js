import React, {
    useCallback,
    useEffect,
    useLayoutEffect,
    useMemo,
    useRef,
    useState,
} from 'react';
import { Fade } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { useSelector } from 'react-redux';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import Nui from '../../util/Nui';
import useKeypress from 'react-use-keypress';
import { debounce } from 'lodash';

const ITEM_DELAY = 50;

const useStyles = makeStyles(() => ({
    wrapper: {
        position: 'absolute',
        inset: 0,
        pointerEvents: 'none',
        fontSize: 'min(.7vw, 1.24444444vh)',
        '--accent': '#87da21',
        '--accentRgb': '135, 218, 33',
        '--white-100': '#fff',
    },
    innerWrapper: {
        width: '100%',
        height: '100%',
        position: 'relative',
        pointerEvents: 'none !important',
    },
    radialMenuWrapper: {
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        position: 'absolute',
        top: '50%',
        left: '70%',
        transform: 'translate(-50%, -50%)',
        width: '60em',
        height: '60em',
        background: 'transparent',
        pointerEvents: 'none !important',
    },
    item: {
        position: 'absolute',
        width: '5em',
        height: '5em',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        borderRadius: '.75em',
        border: '2px solid var(--White-White-15, hsla(0, 0%, 100%, .15))',
        background: 'rgba(26, 31, 20, .75)',
        transform: 'translate(-50%, -50%)',
        cursor: 'pointer',
        isolation: 'isolate',
        '--col': '135, 218, 33',
        pointerEvents: 'auto',
        animation: '$listIn .25s ease both',
        transition: 'top .25s ease, left .25s ease, opacity .25s ease',
        '& svg': {
            position: 'relative',
            zIndex: 2,
            width: '2em',
            height: '2em',
            color: '#fff',
        },
        '& img': {
            position: 'relative',
            zIndex: 2,
            width: '2em',
            height: '2em',
            objectFit: 'contain',
        },
        '&:before, &:after': {
            position: 'absolute',
            opacity: 0,
            transition: 'opacity .2s ease',
            pointerEvents: 'none',
            boxSizing: 'border-box',
        },
        '&:hover:before, &:hover:after, &.active:before, &.active:after': {
            opacity: 1,
        },
        '&:before': {
            content: '""',
            inset: 0,
            borderRadius: 'inherit',
            zIndex: 0,
            background:
                'radial-gradient(circle at var(--x) var(--y), rgba(var(--col), .065) 0, rgba(var(--col), .03) 28%, transparent 58%)',
        },
        '&:after': {
            content: '""',
            inset: '-1.5px',
            borderRadius: 'calc(.75em + 1.5px)',
            padding: '1.5px',
            zIndex: 1,
            background:
                'radial-gradient(circle at var(--x) var(--y), rgba(var(--col), .28) 0, rgba(var(--col), .11) 42%, transparent 82%)',
            WebkitMask:
                'linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)',
            WebkitMaskComposite: 'xor',
            maskComposite: 'exclude',
        },
    },
    center: {
        position: 'absolute',
        left: 'var(--x)',
        top: 'var(--y)',
        transform: 'translate(-50%, -50%)',
        pointerEvents: 'auto',
    },
    centerText: {
        color: '#fff',
        fontFamily: '"Bai Jamjuree", Arial, sans-serif',
        fontSize: '1.35em',
        fontWeight: 500,
        textTransform: 'uppercase',
        whiteSpace: 'pre-wrap',
        textAlign: 'center',
        lineHeight: 1.15,
        textShadow: 'none',
        animation: '$slideUpIn .05s ease-in-out both',
    },
    centerTextLeaving: {
        animation: '$slideUpOut .05s ease-in-out both',
    },
    bgCanvas: {
        position: 'absolute',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        zIndex: -1,
        pointerEvents: 'none',
    },
    '@keyframes listIn': {
        from: {
            opacity: 0,
            left: '50%',
            top: '50%',
        },
        to: {
            opacity: 1,
        },
    },
    '@keyframes slideUpIn': {
        from: {
            opacity: 0,
            transform: 'translateY(2em)',
        },
        to: {
            opacity: 1,
            transform: 'translateY(0)',
        },
    },
    '@keyframes slideUpOut': {
        from: {
            opacity: 1,
            transform: 'translateY(0)',
        },
        to: {
            opacity: 0,
            transform: 'translateY(-2em)',
        },
    },
}));

const getIcon = (icon) => {
    if (!icon) return 'question';
    if (Array.isArray(icon)) return icon;
    if (icon.includes('fa-')) return icon;
    return icon;
};

const getMenuScale = (element) => {
    if (!element || typeof window === 'undefined') return 16;

    const fontSize = parseFloat(window.getComputedStyle(element).fontSize);
    return Number.isFinite(fontSize) && fontSize > 0 ? fontSize : 16;
};

const getPositionedItems = (items, layout) => {
    const sorted = [...items].sort((a, b) =>
        a.id < b.id ? -1 : a.id > b.id ? 1 : 0,
    );

    const count = sorted.length;
    if (count === 0) return [];

    const unit = layout.unit || 16;
    const centerX = layout.centerX || unit * 30;
    const centerY = layout.centerY || unit * 30;
    const radius = unit * (5 + 1.65 * Math.pow(count, 0.75));

    return sorted.map((item, index) => {
        const angle = (index * Math.PI * 2) / count - Math.PI / 2;
        const x = centerX + Math.cos(angle) * radius;
        const y = centerY + Math.sin(angle) * radius;
        const glowX = 50 - Math.cos(angle) * 47;
        const glowY = 50 - Math.sin(angle) * 47;

        return {
            ...item,
            angle,
            style: {
                left: `${x}px`,
                top: `${y}px`,
                '--angle': `${angle}rad`,
                '--x': `${glowX}%`,
                '--y': `${glowY}%`,
                animationDelay: `${index * ITEM_DELAY}ms`,
            },
        };
    });
};

const Interaction = () => {
    const classes = useStyles();
    const rootRef = useRef(null);
    const textTimeout = useRef(null);
    const showing = useSelector((state) => state.interaction.show);
    const menuItems = useSelector((state) => state.interaction.menuItems);
    const layer = useSelector((state) => state.interaction.layer);
    const [layout, setLayout] = useState({
        centerX: 0,
        centerY: 0,
        unit: 16,
    });
    const [currentHover, setCurrentHover] = useState(-1);
    const [centerText, setCenterText] = useState(null);

    const recalculatePositions = useCallback(() => {
        const element = rootRef.current;
        if (!element) return;

        const rect = element.getBoundingClientRect();
        setLayout({
            centerX: rect.width / 2,
            centerY: rect.height / 2,
            unit: getMenuScale(element),
        });
    }, []);

    const items = useMemo(
        () => getPositionedItems(menuItems, layout),
        [menuItems, layout],
    );
    const hoveredItem = currentHover >= 0 ? items[currentHover] : null;
    const centerStyle = useMemo(
        () => ({
            '--x': `${layout.centerX || (layout.unit || 16) * 30}px`,
            '--y': `${layout.centerY || (layout.unit || 16) * 30}px`,
        }),
        [layout],
    );

    const trigger = useMemo(
        () =>
            debounce((item) => {
                Nui.send('Interaction:Trigger', item);
            }, 0),
        [],
    );

    const back = useCallback(async () => {
        if (layer === 0) return await Nui.send('Interaction:Hide');
        await Nui.send('Interaction:Back');
    }, [layer]);

    useLayoutEffect(() => {
        if (!showing) return;
        recalculatePositions();
    }, [showing, menuItems.length, recalculatePositions]);

    useEffect(() => {
        if (!showing) return undefined;

        window.addEventListener('resize', recalculatePositions);
        return () => {
            window.removeEventListener('resize', recalculatePositions);
        };
    }, [showing, recalculatePositions]);

    useEffect(() => {
        setCurrentHover(-1);
    }, [menuItems]);

    useEffect(() => {
        clearTimeout(textTimeout.current);

        if (hoveredItem?.label) {
            setCenterText({
                id: hoveredItem.id,
                label: hoveredItem.label,
                leaving: false,
            });
            return undefined;
        }

        setCenterText((previous) => {
            if (!previous) return null;

            textTimeout.current = setTimeout(() => {
                setCenterText(null);
            }, 50);

            return {
                ...previous,
                leaving: true,
            };
        });

        return () => clearTimeout(textTimeout.current);
    }, [hoveredItem?.id, hoveredItem?.label]);

    useEffect(() => {
        return () => {
            clearTimeout(textTimeout.current);
            trigger.cancel();
        };
    }, [trigger]);

    useKeypress(['F1', 'Escape'], () => {
        if (!showing) return;
        back();
    });

    return (
        <Fade in={showing} timeout={200} unmountOnExit>
            <div className={classes.wrapper}>
                <div className={classes.innerWrapper}>
                    <div className={classes.radialMenuWrapper} ref={rootRef}>
                        {items.map((item, index) => (
                            <div
                                key={item.id}
                                className={`${classes.item} ${
                                    item.active ? 'active' : ''
                                }`}
                                style={item.style}
                                onMouseEnter={() => setCurrentHover(index)}
                                onMouseLeave={() => setCurrentHover(-1)}
                                onClick={() => trigger(item)}
                            >
                                <FontAwesomeIcon icon={getIcon(item.icon)} />
                            </div>
                        ))}

                        <div className={classes.center} style={centerStyle}>
                            {centerText && (
                                <div
                                    key={centerText.id}
                                    className={`${classes.centerText} ${
                                        centerText.leaving
                                            ? classes.centerTextLeaving
                                            : ''
                                    }`}
                                >
                                    {centerText.label}
                                </div>
                            )}
                        </div>

                        <canvas className={classes.bgCanvas} />
                    </div>
                </div>
            </div>
        </Fade>
    );
};

export default Interaction;
