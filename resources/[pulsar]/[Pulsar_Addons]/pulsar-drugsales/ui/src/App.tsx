import { useCallback, useEffect, useState } from "react";
import { triggerDevOpen } from "./devBrowser";
import type { OpenPayload } from "./types";
import { postNui } from "./nui";
import "./sale-panel.css";

export default function App() {
  const [opened, setOpened] = useState(false);
  const [payload, setPayload] = useState<OpenPayload | null>(null);
  useEffect(() => {
    const onMsg = (ev: MessageEvent) => {
      const msg = ev.data;
      if (!msg || typeof msg !== "object") return;
      if (msg.action === "drugsales:open" && msg.data) {
        setPayload(msg.data as OpenPayload);
        setOpened(true);
      }
      if (msg.action === "drugsales:close") {
        setOpened(false);
        setPayload(null);
      }
    };
    window.addEventListener("message", onMsg);
    triggerDevOpen();
    return () => window.removeEventListener("message", onMsg);
  }, []);

  const handleClose = useCallback(() => {
    postNui("drugsales_closed", {});
    setOpened(false);
    setPayload(null);
  }, []);

  const handleSelect = useCallback((item: string) => {
    postNui("drugsales_select", { item });
    setOpened(false);
    setPayload(null);
  }, []);

  if (!opened || !payload) {
    return null;
  }

  return (
    <div className="sale-shell" role="presentation">
      <button
        type="button"
        className="sale-backdrop"
        aria-label="Close"
        onClick={handleClose}
      />
      <div className="sale-panel" role="dialog" aria-modal="true">
        <div className="sale-accent-bar" aria-hidden />
        <div className="sale-inner">
          <div className="sale-header">
            <button
              type="button"
              className="sale-close-x"
              aria-label="Close"
              onClick={handleClose}
            >
              ×
            </button>
          </div>
          <div className="sale-items">
            {payload.items.map((row) => (
              <button
                key={row.item}
                type="button"
                className="sale-item"
                onClick={() => handleSelect(row.item)}
              >
                <div className="sale-item-row">
                  <div className="sale-item-meta">
                    <span className="sale-stock">Stock {row.stock}</span>
                    <span className="sale-price">
                      ~${row.baseMin}–{row.baseMax} / unit
                    </span>
                  </div>
                  <span className="sale-item-name">{row.label}</span>
                </div>
              </button>
            ))}
          </div>

          <button type="button" className="sale-cancel" onClick={handleClose}>
            {payload.cancelLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
