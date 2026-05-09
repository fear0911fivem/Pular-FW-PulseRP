import React, { useState, useEffect } from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { fetchNui } from "../utils/fetchNui";
import { TargetOption, TargetData } from "../types/target";
import { isEnvBrowser } from "../utils/misc";
import { debugData } from "../utils/debugData";

const App: React.FC = () => {
  const [targetData, setTargetData] = useState<TargetData>({});
  const [eyeHover, setEyeHover] = useState(false);
  const [currentIcon, setCurrentIcon] = useState("fa-solid fa-circle");
  const [isIconChanging, setIsIconChanging] = useState(false);
  const [isVisible, setIsVisible] = useState(false);

  // debug data (set this to test while in web)
  useEffect(() => {
    if (isEnvBrowser()) {
      debugData([
        {
          action: "setTarget",
          data: {
            targetIcon: "car", // Change this for the actual target icon to change
            options: {
              global: [
                {
                  icon: "fa-solid fa-key",
                  label: "Give Keys",
                  hide: false,
                },
                {
                  icon: "fa-solid fa-lock",
                  label: "Toggle Locks",
                  hide: false,
                },
                {
                  icon: "fa-solid fa-joint",
                  label: "Start Corner Dealing",
                  hide: false,
                },
              ],
            },
          },
        },
      ]);
    }
  }, []);

  useNuiEvent("leftTarget", () => {
    setTargetData({});
    setEyeHover(false);
    setIsIconChanging(true);
    setTimeout(() => {
      setCurrentIcon("fa-solid fa-circle");
      setIsIconChanging(false);
    }, 150);
  });

  useNuiEvent<TargetData>("setTarget", (data) => {
    setTargetData(data);
    setEyeHover(true);

    const newIcon = data.targetIcon
      ? `fa-solid fa-${data.targetIcon}`
      : "fa-solid fa-circle";
    if (newIcon !== currentIcon) {
      setIsIconChanging(true);
      setTimeout(() => {
        setCurrentIcon(newIcon);
        setIsIconChanging(false);
      }, 150);
    }
  });

  useNuiEvent<boolean>("visible", (visible) => {
    setIsVisible(visible);

    if (!visible) {
      setTargetData({});
      setEyeHover(false);
      setIsIconChanging(true);
      setTimeout(() => {
        setCurrentIcon("fa-solid fa-circle");
        setIsIconChanging(false);
      }, 150);
    }
  });

  const handleOptionClick = async (
    targetType: string,
    targetId: number,
    zoneId?: number
  ) => {
    try {
      await fetchNui("select", [targetType, targetId, zoneId], {
        success: true,
      });
    } catch (error) {
      console.error("Error in option clicked", error);
    }
  };

  const createOptions = (
    type: string,
    data: TargetOption[],
    zoneId?: number
  ) => {
    return data
      .map((option, id) => {
        if (option.hide) return null;

        return (
          <li
            key={`${type}-${id}`}
            className="text-white mb-2 font-bold hover:text-blue-400 cursor-pointer flex items-center transition-all duration-200 hover:scale-[1.025]"
            style={{
              textShadow:
                "0 0 8px rgba(0, 0, 0, 0.8), 0 0 12px rgba(0, 0, 0, 0.6)",
            }}
            onClick={() => handleOptionClick(type, id + 1, zoneId)}
          >
            {option.icon && <i className={`fa-fw ${option.icon} mr-2`} />}
            {option.label}
          </li>
        );
      })
      .filter(Boolean);
  };

  const getIconSize = () => {
    if (targetData.targetIcon) {
      return "text-xl";
    }
    return "text-xs";
  };

  if (!isVisible) {
    return null;
  }

  return (
    <div className="w-full absolute bottom-1/2 text-center transform translate-y-1/2">
      <div className="flex justify-center items-center">
        <i
          className={`${currentIcon} ${getIconSize()} transition-all duration-300 ${
            eyeHover ? "text-blue-400" : "text-gray-200"
          } ${isIconChanging ? "opacity-0 scale-75" : "opacity-100 scale-100"}`}
        />
      </div>

      {targetData.options && (
        <ul className="list-none w-fit h-fit absolute left-0 right-0 top-8 mx-auto text-left transform translate-x-1/4 text-lg">
          {Object.entries(targetData.options).map(([type, options]) => {
            return createOptions(type, options as TargetOption[]);
          })}
          {targetData.zones &&
            targetData.zones.map(
              (zoneOptions: TargetOption[], zoneIndex: number) => {
                return createOptions("zones", zoneOptions, zoneIndex + 1);
              }
            )}
        </ul>
      )}
    </div>
  );
};

export default App;
