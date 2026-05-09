export type SaleItem = {
  item: string;
  label: string;
  stock: number;
  baseMin: number;
  baseMax: number;
  randomQty: boolean;
};

export type OpenPayload = {
  items: SaleItem[];
  cancelLabel: string;
};
