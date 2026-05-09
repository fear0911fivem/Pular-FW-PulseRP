import type { OpenPayload } from "./types";

/** Sample payload for `npm run dev` in a normal browser (not FiveM). */
export const devOpenPayload: OpenPayload = {
  cancelLabel: "Walk away",
  items: [
    {
      item: "weed_joint",
      label: "Weed joint",
      stock: 18,
      baseMin: 45,
      baseMax: 95,
      randomQty: true,
    },
    {
      item: "meth_bag",
      label: "Meth (example)",
      stock: 3,
      baseMin: 120,
      baseMax: 220,
      randomQty: false,
    },
  ],
};
