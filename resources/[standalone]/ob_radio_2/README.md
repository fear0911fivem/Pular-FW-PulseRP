# ob_radio_2

A custom synced vehicle radio system for FiveM with a GTA V-style wheel UI, spatial audio, and per-player sync.

## Features

- **GTA V-style radio wheel** — hold `Q` to open, scroll to select, release to tune in
- **Server-synced playback** — all players on the same station hear the same song at the same position
- **Passenger auto-sync** — when the driver changes station, passengers automatically follow
- **Spatial audio** — radio audio fades, muffles, and cuts based on distance from the vehicle
- **Environment-aware audio** — detects interiors, tunnels, underwater, and adjusts filter/volume
- **Wind noise simulation** — open windows and speed affect audio clarity
- **Native radio fully disabled** — GTA's built-in radio is hidden and blocked
- **Custom station logos** — drop `.png` files into `web/img/` and reference them in config
- **Now Playing bar** — minimal text display, only shown while driving, toggleable per-player
- **Emergency vehicle lockout** — automatically disables the radio in police/ambulance/fire vehicles
- **Multiple songs per station** with server-driven rotation

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib)

## Installation

1. Drop `ob_radio_2` into your `resources/` folder
2. Add `ensure ob_radio_2` to your `server.cfg`
3. Put your audio files in `songs/` (`.ogg` Vorbis format)
4. Put your station logo images in `web/img/`
5. Edit `config.lua` to define your stations
6. Restart the server

## Configuration

### Stations

```lua
Config.Stations = {
    {
        id = 'MY_STATION',
        label = 'Station Name',
        logo = 'logo.png',
        songs = {
            { file = 'song.ogg', title = 'Song Title', artist = 'Artist', duration = 200 },
        },
    },
}
```

### Settings

```lua
Config.DefaultVolume = 0.7
Config.MaxAudioDistance = 30.0
Config.MuffleStartDistance = 5.0
Config.SlowMotionWhileOpen = false
Config.DisableNativeRadio = true
Config.DisableInEmergencyClass = true
Config.DisabledVehicleModels = {}
```

## Controls

| Action | Default |
|---|---|
| Open wheel (hold) | `Q` |
| Select station | Scroll wheel |
| Confirm selection | Release `Q` |
| Volume up/down | Arrow keys (while wheel open) |

All bindings are rebindable in FiveM's Key Bindings menu.

## Commands

| Command | Description |
|---|---|
| `/toggleradioinfo` | Toggle the Now Playing bar |
| `/skipsong <index>` | Skip current song on a station (admin only) |

## Exports

```lua
exports.ob_radio_2:getCurrentStation() -- returns station table or nil
exports.ob_radio_2:isRadioPlaying()    -- returns boolean
```

## Credits

Obtaizen
