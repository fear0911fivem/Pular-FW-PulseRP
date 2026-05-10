# pulsar-storagecrates

Persistent placeable storage crate system for Pulsar FW.

Allows players to place storage crates anywhere in the world, secure them with passwords, and manage persistent personal storage.

Built for Pulsar FW with ox_inventory integration.

---

# Preview

https://www.youtube.com/watch?v=biHyLMVGZOw&feature=youtu.be

---

# Features

- Placeable storage crates
- Multiple crate sizes and prop variations
- Persistent world storage
- Password protected crates
- Set / change / remove password support
- Lockpick system for break-ins
- Pickup and redeploy crates
- ox_inventory integration
- Open world placement system
- Database saved crate locations

---

# Installation

## 1. Add Resource

Drag `pulsar-storagecrates` into your server resources folder.

Add the resource to your `resources.cfg`

```cfg
ensure pulsar-storagecrates
```

---

## 2. Database

Run `storage_crates.sql` in your MySQL database.

---

## 3. Add Items

Add the following items to your ox_inventory items file.

```lua
{
    name = "storage_box_small",
    label = "Small Storage Box",
    description = "Small storage crate",
    price = 3,
    isUsable = true,
    isRemoved = false,
    isStackable = false,
    rarity = 1,
    closeUi = true,
    metalic = false,
    weight = 2,
},

{
    name = "storage_box_medium",
    label = "Medium Storage Box",
    description = "Medium storage crate",
    price = 3,
    isUsable = true,
    isRemoved = false,
    isStackable = false,
    rarity = 1,
    closeUi = true,
    metalic = false,
    weight = 2,
},

{
    name = "storage_box_large",
    label = "Large Storage Box",
    description = "Large storage crate",
    price = 3,
    isUsable = true,
    isRemoved = false,
    isStackable = false,
    rarity = 1,
    closeUi = true,
    metalic = false,
    weight = 2,
},
```
Add all images from the `invimages` folder into `ox_inventory/web/images`

---

# Usage

- Use a storage crate item to place the crate in the world
- Interact with the crate to open storage options
- Set a password to secure the crate
- Change or remove passwords at any time
- Other players can attempt to lockpick locked crates
- Pickup your crate to move or store it elsewhere

---

# Dependencies

- Pulsar FW
- ox_inventory
- ox_lib

---

# Notes

- Crates save persistently in the database
- Password protected crates can still be lockpicked
- All placed crates restore automatically after server restart

---
# Issues
If any issues persist please contact me through Pulsar FW discord or open an issue on git
---

# Framework

Built specifically for Pulsar FW.
