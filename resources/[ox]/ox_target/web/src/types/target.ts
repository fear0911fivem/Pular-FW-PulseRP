export interface TargetOption {
  icon: string;
  label: string;
  iconColor?: string;
  hide?: boolean;
}

export interface TargetData {
  options?: Record<string, TargetOption[]>;
  zones?: TargetOption[][];
  targetIcon?: string;
}
