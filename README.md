# Discord Linux AppArmor Fix (Ubuntu 22.04 / AppArmor 3.0)

Читать на [Русском](README_RU.md) языке

Discord recently changed its Linux update model. Instead of a full app, the `.deb` package now contains a small `updater_bootstrap` app and several bash scripts, and the Discord application itself is downloaded to the home folder.  
Along with this they added the AppArmor profile, which breaks everything.


### The Problem
The new AppArmor profile includes `abi <abi/4.0>`, which is only available in newer distributions (like *Ubuntu 24.04).  
On **Ubuntu 22.04** and others using **AppArmor 3.x**, this causes a syntax error that **breaks the entire AppArmor service**, leaving your system unprotected.

### The Symptoms
- `apparmor.service: Control process exited, code=exited, status=1/FAILURE`
- Error: `Could not open 'abi/4.0': No such file or directory`
- Discord might fail to launch or the system security service stays down.

### The Fix
Replace the broken profiles in `/etc/apparmor.d/` with the fixed versions from this repo. They use `abi <abi/3.0>` and remove the unsupported `userns` keyword while keeping the app functional via the `unconfined` flag.

**Files included:**
- `discord-ptb` - for the Canary version.
- `discord-canary` - for the Development version.
- `discord-development` - for PTB version

### How to use
1. Copy the fixed file to `/etc/apparmor.d/` (with replacement).
2. Reload AppArmor: `sudo systemctl reload apparmor`

### Technical Trivia
Under the hood, the new `updater_bootstrap` is a binary written in **Rust**.  
Metadata reveals it was likely built within a **Nix store** environment. While this ensures a consistent build for Discord, it seems they didn't test the resulting AppArmor configurations against older (but still widely used) LTS distributions, leading to the current compatibility mess.
