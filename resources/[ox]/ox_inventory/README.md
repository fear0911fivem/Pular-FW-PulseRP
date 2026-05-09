<div align="center">

<img src="https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsarbanner.png" alt="Pulsar Framework" width="100%" />

<br/>

# ox_inventory

### Slot-based inventory system — Pulsar Framework edition

<br/>

![Lua](https://img.shields.io/badge/Lua_5.4-2C2D72?style=flat-square&logo=lua&logoColor=white)
![FiveM](https://img.shields.io/badge/FiveM-F40552?style=flat-square)
![React](https://img.shields.io/badge/React_18-61DAFB?style=flat-square&logo=react&logoColor=black)
![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white)
![Mantine](https://img.shields.io/badge/Mantine_7-339AF0?style=flat-square&logo=mantine&logoColor=white)

<br/>

[Overview](#overview) · [Bridge](#bridge) · [Configuration](#configuration) · [UI Development](#ui-development) · [Dependencies](#dependencies)

</div>

---

## Overview

A production fork of [ox_inventory](https://github.com/communityox/ox_inventory) shipping with a full **Pulsar Framework** bridge. Every resource in the stack — drugs, police, finance, targeting, crafting — interacts with inventory without modification. Item definitions, shop configs, and crafting tables are bundled directly into this resource.

> [!WARNING]
> Do not pull from upstream ox_inventory without reviewing bridge compatibility first. The bridge overrides core server and client behaviours.

---

## Pending

| Item | Notes |
|------|-------|
| Schematics — per-player unlock + DB storage | Recipes register fine; missing the item use handler, MySQL write, and per-player merge on bench open |
| Notifications via pulsar-notify | Item add/remove toasts currently use ox's built-in notify |

---

## Configuration

Add to `server.cfg`:

```
setr inventory:framework  "pulsar"
setr inventory:slots       50
setr inventory:weight      30000
setr inventory:target      0
```

| Convar | Default | Description |
|--------|---------|-------------|
| `inventory:framework` | `ox` | Must be `pulsar` |
| `inventory:slots` | `50` | Player inventory slots |
| `inventory:weight` | `30000` | Max carry weight (grams) |
| `inventory:target` | `0` | `0` = ox_lib points, `1` = ox_target zones |
| `inventory:itemnotify` | `1` | Show item add/remove HUD popups |
| `inventory:loglevel` | `0` | `0` = off, `1` = high-value, `2` = all |

---

## Data Files

| File | Purpose |
|------|---------|
| `data/pulsar-items/` | Item definitions — loaded and converted to ox format at boot |
| `data/pulsar-crafting/crafting_config.lua` | Crafting bench definitions (label, location, targeting, recipes) |
| `data/pulsar-crafting/schematic_config.lua` | Schematic recipes (per-player unlock via item use) |
| `data/shops.lua` | Shop definitions — location-based and ped-spawned |
| `data/licenses.lua` | License purchase point locations and prices |

---

## UI Development

The NUI is a React 18 + Mantine 7 + Redux app compiled with Vite.

```bash
cd web
bun install
bun run start    # dev server (http://localhost:3000) with hot reload
bun run build    # production build → web/build/
```

**Theme:** `web/src/theme.ts` — Pulsar purple palette (`#7c3aed` primary, `#0a0614` dark base).  
**SCSS variables:** `web/src/index.scss` — grid sizing, slot colours, typography.

---

## Dependencies

| Resource | Purpose |
|----------|---------|
| `ox_lib` | Points, callbacks, notify, keybinds, progress |
| `oxmysql` | Database (inventory persistence) |
| `pulsar-core` | Framework core — middleware, fetch, callbacks |
| `pulsar-characters` | Character data — cash, name, SID, jobs |
| `pulsar-pedinteraction` | Ped interaction events (shops, crafting) |
| `ox_target` | World targeting (optional, controlled by `inventory:target`) |

---

---

## Credits

This resource is a fork of [ox_inventory](https://github.com/communityox/ox_inventory), originally developed by [Linden](https://github.com/thelindat) and the [Overextended](https://github.com/overextended) team. All core inventory logic, database layer, weapon system, crafting grid, and NUI framework are their work.

The Pulsar Framework bridge (`modules/bridge/pulsar/`), item conversion pipeline, crafting config loader, cash-as-item sync, and UI retheme are additions made for this project and are not part of the upstream repository.

| | |
|---|---|
| **Original project** | [communityox/ox_inventory](https://github.com/communityox/ox_inventory) |
| **Original author** | [Linden (thelindat)](https://github.com/thelindat) |
| **Contributors** | [Overextended](https://github.com/overextended) |
| **Bridge & modifications** | Pulsar Framework team |

---

## License

This resource inherits the license of the upstream project.

ox_inventory is licensed under the **GNU Lesser General Public License v3.0 (LGPL-3.0)**.

> You may use, modify, and distribute this software under the terms of the LGPL-3.0. Any modifications to the library itself must be released under the same license. See the [full license text](https://www.gnu.org/licenses/lgpl-3.0.en.html) for details.

The Pulsar Framework bridge code located in `modules/bridge/pulsar/` is proprietary and not covered by the upstream LGPL-3.0 license.

---

<div align="center">

![Pulsar Framework](https://img.shields.io/badge/Pulsar-Framework-7c3aed?style=flat-square)
![Built for FiveM](https://img.shields.io/badge/Built_for-FiveM-F40552?style=flat-square)
[![License: LGPL v3](https://img.shields.io/badge/License-LGPL_v3-green?style=flat-square)](https://www.gnu.org/licenses/lgpl-3.0)

</div>
