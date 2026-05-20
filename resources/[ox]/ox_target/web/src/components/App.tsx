import React, {
  CSSProperties,
  MouseEvent,
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { fetchNui } from "../utils/fetchNui";
import { TargetData, TargetOption } from "../types/target";
import { isEnvBrowser } from "../utils/misc";
import { debugData } from "../utils/debugData";

const ITEM_DELAY = 50;
const ANIMATION_TIME = 200;
const TARGET_FADE_TIME = 300;
const DIRECTIONS = ["left", "center", "right"] as const;
const DEFAULT_COORDS = { x: 0.5, y: 0.5 };

type Direction = (typeof DIRECTIONS)[number];
type RenderPhase = "preEnter" | "entering" | "visible" | "exiting";

interface TargetPoint {
  x: number;
  y: number;
  direction: Direction;
  down?: boolean;
}

interface FlatTargetOption {
  data: TargetOption;
  targetType: string;
  targetId: number;
  zoneId?: number;
}

interface TargetItem extends FlatTargetOption {
  key: string;
  point: TargetPoint;
  style: CSSProperties;
}

interface RenderTargetItem extends TargetItem {
  phase: RenderPhase;
}

const rem = (value: number) =>
  value *
  parseFloat(getComputedStyle(document.documentElement).fontSize || "16");

const clamp = (value: number) => Math.max(0, Math.min(1, value));

const getCssColor = (property: string, fallback: string) =>
  getComputedStyle(document.documentElement).getPropertyValue(property).trim() ||
  fallback;

const getOptionLabel = (option: TargetOption) =>
  option.label || option.text || option.realName || option.name || option.event || "";

const getIconString = (icon?: string) => {
  if (!icon) return "";
  return icon.includes("fa-") ? icon : `fa-solid fa-${icon}`;
};

const getItemKey = (item: FlatTargetOption) => {
  const dataKey =
    item.data.name ||
    item.data.event ||
    item.data.realName ||
    item.data.label ||
    item.data.text;

  return `${item.targetType}:${item.zoneId || 0}:${dataKey || "option"}:${item.targetId}`;
};

const flattenOptions = (targetData: TargetData): FlatTargetOption[] => {
  const items: FlatTargetOption[] = [];

  if (targetData.options) {
    Object.entries(targetData.options).forEach(([type, options]) => {
      options.forEach((option, index) => {
        if (!option.hide) {
          items.push({
            data: option,
            targetType: type,
            targetId: index + 1,
          });
        }
      });
    });
  }

  if (targetData.zones) {
    targetData.zones.forEach((options, zoneIndex) => {
      options.forEach((option, index) => {
        if (!option.hide) {
          items.push({
            data: option,
            targetType: "zones",
            targetId: index + 1,
            zoneId: zoneIndex + 1,
          });
        }
      });
    });
  }

  return items;
};

const getViewportSize = () => {
  const viewport = window.visualViewport;

  return {
    width: viewport?.width || window.innerWidth,
    height: viewport?.height || window.innerHeight,
  };
};

const App: React.FC = () => {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const animationFrame = useRef<number>();
  const fadeFrame = useRef<number>();
  const [targetData, setTargetData] = useState<TargetData>({});
  const [isVisible, setIsVisible] = useState(isEnvBrowser());
  const [shouldRender, setShouldRender] = useState(isEnvBrowser());
  const [isFadedIn, setIsFadedIn] = useState(isEnvBrowser());
  const [targetPoints, setTargetPoints] = useState<TargetPoint[]>([]);
  const [renderItems, setRenderItems] = useState<RenderTargetItem[]>([]);
  const [noHover, setNoHover] = useState(false);

  const options = useMemo(() => flattenOptions(targetData), [targetData]);
  const startCoords = targetData.startCoords || DEFAULT_COORDS;
  const relativeAngle = targetData.relativeAngle || 0;

  useEffect(() => {
    if (isEnvBrowser()) {
      debugData([
        {
          action: "setTarget",
          data: {
            targetIcon: "car",
            options: {
              global: [
                {
                  icon: "child",
                  label: "Put In Trunk",
                  hide: false,
                },
                {
                  icon: "child",
                  label: "Pull Out Of Trunk",
                  hide: false,
                },
                {
                  icon: "child",
                  label: "Get In Trunk",
                  hide: false,
                },
              ],
            },
            zones: [],
          },
        },
      ]);
    }
  }, []);

  const calculateLayout = useCallback(
    (
      pairProgress: number[] = [],
      straightProgress = 1,
      draw = false
    ): TargetPoint[] => {
      const canvas = canvasRef.current;
      const ctx = canvas?.getContext("2d") || null;
      const { width, height } = getViewportSize();
      const points: TargetPoint[] = [];

      if (canvas) {
        canvas.width = canvas.clientWidth || width;
        canvas.height = canvas.clientHeight || height;
      }

      if (ctx) {
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
      }

      const count = options.length;
      if (!count) {
        if (draw && ctx) {
          const idleColor = getCssColor("--targetIdle", "rgba(255, 255, 255, 0.45)");

          ctx.save();
          ctx.fillStyle = idleColor;
          ctx.translate(0.5, 0.5);
          ctx.beginPath();
          ctx.ellipse(
            startCoords.x * width,
            startCoords.y * height,
            rem(0.175),
            rem(0.175),
            0,
            0,
            Math.PI * 2
          );
          ctx.fill();
          ctx.closePath();
          ctx.restore();
        }

        return points;
      }

      const centerX = startCoords.x * width;
      const centerY = startCoords.y * height;
      const pairs = Math.floor(count / 2);
      const hasStraightItem = Boolean(count % 2);
      const verticalStep = rem(4);
      const branchStep = rem(2);
      const minTop = rem(3);
      const dotRadius = rem(0.175);
      const accent = getCssColor("--accent", "#87da21");

      if (ctx) {
        ctx.save();
        ctx.fillStyle = accent;
        ctx.strokeStyle = accent;
        ctx.lineWidth = 2;
        ctx.translate(0.5, 0.5);
      }

      for (let direction = -1; direction <= 1; direction += 2) {
        let currentY = centerY;
        points.length = 0;

        if (ctx) {
          ctx.save();
          ctx.globalAlpha = 1;
          ctx.beginPath();
          ctx.ellipse(centerX, centerY, dotRadius, dotRadius, 0, 0, Math.PI * 2);
          ctx.fill();
          ctx.closePath();
        }

        for (let row = 0; row < pairs; row += 1) {
          const leftProgress = pairProgress[row * 2] ?? 1;
          const rightProgress = pairProgress[row * 2 + 1] ?? 1;
          const lineProgress = Math.max(leftProgress, rightProgress);
          const fromY = currentY;
          currentY += verticalStep * direction;

          if (ctx && lineProgress > 0) {
            ctx.globalAlpha = lineProgress;
            ctx.beginPath();
            ctx.moveTo(centerX, fromY);
            ctx.lineTo(centerX, currentY);
            ctx.stroke();
            ctx.closePath();
          }

          [-1, 1].forEach((side, sideIndex) => {
            const progress =
              pairProgress[Math.floor(row * 2 + (side + 1) / 2)] ?? 1;
            const x = centerX + side * branchStep;
            const y = currentY + branchStep * direction * 0.4;

            if (ctx && progress > 0) {
              ctx.globalAlpha = progress;
              ctx.beginPath();
              ctx.moveTo(centerX, currentY);
              ctx.bezierCurveTo(
                centerX,
                currentY,
                centerX,
                currentY + verticalStep * direction * 0.2,
                x,
                y
              );
              ctx.stroke();
              ctx.closePath();
              ctx.beginPath();
              ctx.ellipse(x, y, dotRadius, dotRadius, 0, 0, Math.PI * 2);
              ctx.fill();
              ctx.closePath();
            }

            points.push({
              x,
              y,
              direction: DIRECTIONS[sideIndex * 2],
            });
          });
        }

        if (hasStraightItem) {
          const fromY = currentY;
          currentY += verticalStep * direction;

          if (ctx && straightProgress > 0) {
            ctx.globalAlpha = straightProgress;
            ctx.beginPath();
            ctx.moveTo(centerX, fromY);
            ctx.lineTo(centerX, currentY);
            ctx.stroke();
            ctx.closePath();
            ctx.beginPath();
            ctx.ellipse(centerX, currentY, dotRadius, dotRadius, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.closePath();
          }

          points.push({
            x: centerX,
            y: currentY,
            direction: "center",
            down: direction === 1,
          });
        }

        if (ctx) {
          ctx.restore();
        }

        if (currentY > minTop) {
          break;
        }

        if (ctx) {
          ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
        }
      }

      if (ctx) {
        ctx.restore();
      }

      return [...points];
    },
    [options.length, startCoords.x, startCoords.y]
  );

  const renderCanvas = useCallback(
    (pairProgress?: number[], straightProgress?: number) => {
      calculateLayout(pairProgress, straightProgress, true);
    },
    [calculateLayout]
  );

  const updateLayout = useCallback(() => {
    setTargetPoints(calculateLayout([], 1, false));
    renderCanvas();
  }, [calculateLayout, renderCanvas]);

  const startCanvasAnimation = useCallback(() => {
    window.cancelAnimationFrame(animationFrame.current || 0);

    if (!shouldRender) {
      const canvas = canvasRef.current;
      const ctx = canvas?.getContext("2d");
      if (ctx && canvas) {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
      }
      return;
    }

    const pairCount = options.length - (options.length % 2);
    const hasStraightItem = Boolean(options.length % 2);
    const start = performance.now();

    const frame = (time: number) => {
      const pairProgress = Array.from({ length: pairCount }, (_, index) =>
        clamp((time - start - index * ITEM_DELAY) / ANIMATION_TIME)
      );
      const straightProgress = hasStraightItem
        ? clamp((time - start - pairCount * ITEM_DELAY) / ANIMATION_TIME)
        : 1;

      renderCanvas(pairProgress, straightProgress);

      const done =
        pairProgress.every((progress) => progress >= 1) &&
        (!hasStraightItem || straightProgress >= 1);

      if (!done) {
        animationFrame.current = window.requestAnimationFrame(frame);
      }
    };

    setTargetPoints(calculateLayout([], 1, false));
    animationFrame.current = window.requestAnimationFrame(frame);
  }, [calculateLayout, options.length, renderCanvas, shouldRender]);

  useNuiEvent("leftTarget", () => {
    setTargetData({});
    setTargetPoints([]);
  });

  useNuiEvent<TargetData>("setTarget", (data) => {
    setTargetData(data);
  });

  useNuiEvent<boolean>("visible", (visible) => {
    window.cancelAnimationFrame(fadeFrame.current || 0);
    setIsVisible(visible);

    if (visible) {
      setShouldRender(true);
      setIsFadedIn(false);

      fadeFrame.current = window.requestAnimationFrame(() => {
        fadeFrame.current = window.requestAnimationFrame(() => {
          setIsFadedIn(true);
        });
      });
    } else {
      setIsFadedIn(false);
    }

    if (!visible) {
      setTargetData({});
      setTargetPoints([]);
    }
  });

  useEffect(() => {
    if (isVisible) {
      setShouldRender(true);
      return undefined;
    }

    const timeout = window.setTimeout(
      () => setShouldRender(false),
      TARGET_FADE_TIME
    );

    return () => window.clearTimeout(timeout);
  }, [isVisible]);

  useEffect(
    () => () => window.cancelAnimationFrame(fadeFrame.current || 0),
    []
  );

  useEffect(() => {
    startCanvasAnimation();
    return () => window.cancelAnimationFrame(animationFrame.current || 0);
  }, [startCanvasAnimation]);

  useEffect(() => {
    window.addEventListener("resize", updateLayout);
    return () => window.removeEventListener("resize", updateLayout);
  }, [updateLayout]);

  const items: TargetItem[] = useMemo(
    () =>
      options
        .map((option, index) => {
          const point = targetPoints[index];
          if (!point) return null;

          return {
            ...option,
            key: getItemKey(option),
            point,
            style: {
              "--l": `${point.x}px`,
              "--t": `${point.y}px`,
              "--delay": `${index * ITEM_DELAY}ms`,
            } as CSSProperties,
          };
        })
        .filter(Boolean) as TargetItem[],
    [options, targetPoints]
  );

  useEffect(() => {
    const nextByKey = new Map(items.map((item) => [item.key, item]));

    setRenderItems((previous) => {
      const merged: RenderTargetItem[] = [];

      previous.forEach((item) => {
        const next = nextByKey.get(item.key);

        if (next) {
          merged.push({
            ...next,
            phase: item.phase === "exiting" ? "entering" : "visible",
          });
          nextByKey.delete(item.key);
          return;
        }

        merged.push({
          ...item,
          phase: "exiting",
          style: {
            ...item.style,
            "--delay": "0ms",
          } as CSSProperties,
        });
      });

      nextByKey.forEach((item) => {
        merged.push({
          ...item,
          phase: "preEnter",
        });
      });

      return merged;
    });

    const enterFrame = window.requestAnimationFrame(() => {
      setRenderItems((previous) =>
        previous.map((item) =>
          item.phase === "preEnter" ? { ...item, phase: "entering" } : item
        )
      );
    });

    const visibleTimeout = window.setTimeout(() => {
      setRenderItems((previous) =>
        previous.map((item) =>
          item.phase === "entering" ? { ...item, phase: "visible" } : item
        )
      );
    }, ANIMATION_TIME + items.length * ITEM_DELAY);

    const exitTimeout = window.setTimeout(() => {
      setRenderItems((previous) =>
        previous.filter((item) => item.phase !== "exiting")
      );
    }, ANIMATION_TIME);

    return () => {
      window.cancelAnimationFrame(enterFrame);
      window.clearTimeout(visibleTimeout);
      window.clearTimeout(exitTimeout);
    };
  }, [items]);

  const handleOptionClick = async (
    event: MouseEvent<HTMLDivElement>,
    item: TargetItem
  ) => {
    event.preventDefault();
    setNoHover(true);

    try {
      await fetchNui("select", [item.targetType, item.targetId, item.zoneId], {
        success: true,
      });
    } catch (error) {
      console.error("Error in option clicked", error);
    }

    setTimeout(() => setNoHover(false), 100);
  };

  if (!shouldRender) {
    return null;
  }

  return (
    <div
      className={`prp-target-wrapper ${
        isFadedIn ? "visible" : "hidden"
      }`}
    >
      <div
        className="prp-target-inner"
        style={{ "--rotation": `${relativeAngle}rad` } as CSSProperties}
      >
        <canvas ref={canvasRef} className="prp-target-canvas" />
        <div className="prp-target-menu">
          {renderItems.map((item) => {
            const label = getOptionLabel(item.data);
            const icon = getIconString(item.data.icon);

            return (
              <div
                key={item.key}
                className={`prp-target-item ${item.point.direction} ${
                  item.point.down ? "down" : ""
                } ${item.phase} ${noHover ? "noHover" : ""}`}
                style={item.style}
                onClick={(event) => handleOptionClick(event, item)}
                onContextMenu={(event) => handleOptionClick(event, item)}
              >
                {icon && <i className={icon} />}
                <span>{label}</span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default App;
