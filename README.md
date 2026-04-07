<h1 align="center">Overview</h1>
Typically, the culprit for increased input latency on Linux may be:
<br>1. Tearing is enabled (Forced VSync)
<br>2. Geometry Dash running through XWayland
<br>3. Not using provided optional tweaks (e.g. AMD Anti-Lag)

<h1 align="center">Topics</h1>

- [1. How to Enable Tearing](#1-how-to-enable-tearing)
- [2. Making GD Run Natively in Wayland](#2-making-gd-run-natively-in-wayland)
- [3. Platform-specific Tweaks](#3-platform-specific-tweaks)
- [4. Global Script for Environment Variables](#4-global-gamesh)
- [5. Common Issues](#common-issues)
  
<h1 align="center">1. How to Enable Tearing</h1>
You can search for instructions on how to do this for your desktop environment, some desktop environments may not support tearing.<br>
I will demonstrate how to do this for KDE Plasma.

<table>
  <tr>
    <td align="center">Open system settings and navigate to display settings</td>
    <td align="center"><img width="671" height="130" alt="image" src="https://github.com/user-attachments/assets/6037a398-a939-4fd1-bcc5-3a812cda0014" /></td>
  </tr>
  <tr>
    <td align="center">Ensure that tearing is enabled</td>
    <td align="center"><img width="924" height="669" alt="image" src="https://github.com/user-attachments/assets/8b938084-dc30-43a8-8140-a16936ea02e2" /></td>
  </tr>
</table>
<br>

<h2 align="center">1.1 Method 1 (ALL GPUs)</h2>
<table>
  <tr>
    <td align="center">Open system settings and navigate to window rules</td>
    <td align="center"><img width="678" height="132" alt="image" src="https://github.com/user-attachments/assets/b1da3c42-de1f-42cc-9815-f6b4b0d2e6c6" /></td>
  </tr>
  <tr>
    <td align="center">Copy these settings</td>
    <td align="center"><img width="659" height="349" alt="image" src="https://github.com/user-attachments/assets/f9dff8ab-00ec-4118-a7e3-ab0ed0752845" /></td>
  </tr>
</table>

Set present mode to immediately deliver any frame instead of waiting for a vertical refresh each frame.<br>

```
vblank_mode=0 %command%
```
<br><br>
<h2 align="center">1.1 Method 2 (ONLY AMD / INTEL)</h2>

MESA_VK_WSI_PRESENT_MODE=immediate env variable

<h1 align="center">2. Making GD Run Natively in Wayland (for Wayland users)</h1>
Assuming you run Wayland, there is an extra layer between Geometry Dash and your screen called XWayland, which is used as Proton runs games with X11 by default.<br>
To change this, we will use steam launch options, I have found that Proton-GE and Proton-CachyOS both have the PROTON_ENABLE_WAYLAND variable available, however Proton Experimental does not.<br>
<table>
  <tr>
    <td align="center">First, check that Geometry Dash is running through XWayland, You can do through the KWin debug console on KDE.</td>
    <td align="center"><img width="679" height="129" alt="image" src="https://github.com/user-attachments/assets/38a1613a-f335-4a5e-a0e3-cad243f62cb5" /></td>
  </tr>
  <tr>
    <td align="center">Run Geometry Dash and check if it is in the Wayland or X11 window category.</td>
    <td align="center"><img width="503" height="325" alt="image" src="https://github.com/user-attachments/assets/b0992f8b-3e22-4d6b-84b7-14463e3f2f15" /></td>
  </tr>
</table><br>
If it is in X11 category, follow these steps to make Geometry Dash run natively on Wayland:<br>

```
PROTON_ENABLE_WAYLAND=1 %command%
```

Go to Geometry Dash on Steam, right click it in your library and click on Properties<br>
Enter this into the LAUNCH OPTIONS box: `~/game.sh %command%`<br>
Launch Geometry Dash and check KWin debug console, make sure that Geometry Dash is under Wayland Windows<br><br>

<h1 align="center">3. Globally Disable Tearing in KWin (KDE Plasma)</h1>

```
sudo nano /etc/environment
```
<br><br>
Add variable:
```bash
KWIN_DRM_NO_AMS=1
```
Save with: `Ctrl X, Ctrl Y, Enter`<br>

<h1 align="center">4. Kernel Thread Schedulers</h1>

TBD

<h1 align="center">5. GPU Specific Tweaks</h1>

TBD

<h1 align="center">6. Global Script for Environment Variables</h1>
This game.sh file is designed to cover all cases for lowest latency:<br>

```bash
#!/bin/bash
export PROTON_USE_NTSYNC=1
export SDL_VIDEODRIVER=wayland
export PROTON_ENABLE_WAYLAND=1
export vblank_mode=0
export ENABLE_LAYER_MESA_ANTI_LAG=1
export PROTON_NO_STEAMINPUT=1
export WINEDLLOVERRIDES="xinput1_4=n,b"
exec "$@"
```

Explanation: (partially tbd)
<table>
  <tr>
    <td align="center">PROTON_ENABLE_WAYLAND=1</td>
    <td align="center">Enables Wayland over X11 to avoid XWayland input lag overhead</td>
  </tr>
  <tr>
    <td align="center">vblank_mode=0</td>
    <td align="center">Uses present mode, which instantly displays a frame instead of waiting for a vertical refresh (vblank)</td>
  </tr>
  <tr>
    <td align="center">ENABLE_LAYER_MESA_ANTI_LAG=1</td>
    <td align="center">Reduces input lag on AMD GPUs with AMD Anti-Lag</td>
  </tr>
  <tr>
    <td align="center">PROTON_NO_STEAMINPUT=1</td>
    <td align="center">Fixes controller compatibility issues</td>
  </tr>
  <tr>
    <td align="center">WINEDLLOVERRIDES="xinput1_4=n,b"</td>
    <td align="center">Required for <a href="https://geode-sdk.org">Geode</a> to function</td>
  </tr>
</table>

<h1 align="center">Common issues</h1>
"The game doesn't open from steam anymore after adding launch options"<br>
This is due to the game.sh not being executable, use this command to fix the issue:<br>

`chmod +x ~/game.sh`


<h2 align="center">Feel free to make a pull request to improve the quality of this document and suggest other methods</h2>
