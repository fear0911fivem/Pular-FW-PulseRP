# Police K9 Script

**Police K9 Script** is a project originally forked from [hashisx's repository](https://github.com/hashisx/hashx_k9), and later from [FjamZoo's repository](https://github.com/FjamZoo/qb-k9)

**Thanks to [AutLaaw's Repository](https://github.com/AutLaaw/mythic-k9)**, Pulsar framework support has been added. Sandbox and Mythic support have been removed.

## Installation

1. **Download ox_lib**  
   Make sure you have ox_lib installed [ox_lib](https://github.com/overextended/ox_lib).

2. **Download the K9 Ped Asset**  
   The K9 Ped used in this script is a custom model. You can download the model from the [Cfx.re forum](https://forum.cfx.re/t/how-to-german-shepherd-malinois-k9-dog-1-0-1/1065040).
   or just drag the K9_ped that is placed in "PED PUT ME SOMEWHERE" wherever you prefer

3. **Add to Server Files**  
   Place the `Pulsar-k9` folder into your server's resource directory.

4. **Configure Resources**  
   Start the script by adding the following line to your `resources.cfg` file:
   ```plaintext
   ensure pulsar-k9
   ```

## Overview

This script allows you to retrieve a police dog, and then use it to follow or attack targets. The dog will only attack when you are pointing a weapon. In addition, it lets you make the dog sit, stand, lay down, search players, vehicles, and areas. You can also put the dog in a vehicle.

## How to Use

1. **Retrieve a Dog:**  
   Retrieve a dog from the location specified in the configuration file.

2. **Keybind Setup:**

   - Bind your preferred key in the configuration file, or set it in-game through your settings.
   - Use your defined keybind to open the K9 commands menu, which lets you choose to attack a player, follow a player, make the dog sit, stand, lay down, search players, vehicles, and areas. You can also put the dog in a vehicle.

3. **Attacking:**  
   Make sure you are pointing a weapon at a player when you press the attack keybind.

## Bugs

If you experience any issues or bugs open an issue on github.