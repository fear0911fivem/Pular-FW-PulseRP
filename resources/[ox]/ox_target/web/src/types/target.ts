export interface TargetOption {
  icon?: string;
  label?: string;
  text?: string;
  realName?: string;
  name?: string;
  event?: string;
  iconColor?: string;
  hide?: boolean;
}

export interface TargetCoords {
  x: number;
  y: number;
}

export interface TargetData {
  options?: Record<string, TargetOption[]>;
  zones?: TargetOption[][];
  targetIcon?: string;
  startCoords?: TargetCoords;
  relativeAngle?: number;
}
