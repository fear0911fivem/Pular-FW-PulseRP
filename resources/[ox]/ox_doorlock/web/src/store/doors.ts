import create from 'zustand';
import type { StoreState } from './';

export interface DoorColumn extends Omit<StoreState, 'groups'> {
  id: number;
  name: string;
  zone: string;
  groups: { [k: string]: number };
  workplace?: string | null;
  permissions?: string | null;
  onduty?: boolean | null;
}

export const useDoors = create<{ doors: DoorColumn[]; setDoors: (value: DoorColumn[]) => void }>((set) => ({
  doors: [],
  setDoors: (doors: DoorColumn[]) => set({ doors }),
}));
