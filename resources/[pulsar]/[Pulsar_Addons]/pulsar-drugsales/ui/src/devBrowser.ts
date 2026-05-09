import { devOpenPayload } from "./devMock";

/**
 * Run only in Vite dev (`npm run dev`). Stubs FiveM NUI so the sale UI works in Chrome/Edge.
 */
export function setupDevBrowser(): void {
  if (!import.meta.env.DEV) {
    return;
  }

  window.GetParentResourceName = () => "pulsar-drugsales";

  const origFetch = window.fetch.bind(window);
  window.fetch = (input: RequestInfo | URL, init?: RequestInit) => {
    const url =
      typeof input === "string"
        ? input
        : input instanceof Request
          ? input.url
          : String(input);
    if (/^https:\/\/[^/]+\/(drugsales_closed|drugsales_select)$/.test(url)) {
      console.info("[pulsar-drugsales dev NUI]", url, init?.body ?? "");
      return Promise.resolve(
        new Response(JSON.stringify("ok"), {
          status: 200,
          headers: { "Content-Type": "application/json; charset=UTF-8" },
        })
      );
    }
    return origFetch(input, init);
  };
}

let devOpenDispatched = false;

/** Fire the same message Lua sends when opening the menu. */
export function triggerDevOpen(): void {
  if (!import.meta.env.DEV || devOpenDispatched) {
    return;
  }
  devOpenDispatched = true;
  window.dispatchEvent(
    new MessageEvent("message", {
      data: {
        action: "drugsales:open",
        data: devOpenPayload,
      },
    })
  );
}
