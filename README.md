# Overview
Typically, the culprit for increased input latency on linux can be due to these things:
1. Tearing disabled
2. Geometry Dash running on X11

# 1. How to enable tearing
You can search for instructions on how to do this for your desktop environment, many desktop environments may not even support tearing.<br>
I will demonstrate how to do this for KDE Plasma on CachyOS.
<p>
Open system settings and navigate to display settings.
  <br>
  <img width="671" height="130" alt="image" src="https://github.com/user-attachments/assets/6037a398-a939-4fd1-bcc5-3a812cda0014" />
  <br>
Ensure that tearing is enabled.
  <br>
  <img width="924" height="669" alt="image" src="https://github.com/user-attachments/assets/8b938084-dc30-43a8-8140-a16936ea02e2" />
  <br>
</p>

## 1.1 Method 1 (ALL GPUs)
<p>
Open system settings and navigate to window rules.
  <br>
  <img width="678" height="132" alt="image" src="https://github.com/user-attachments/assets/b1da3c42-de1f-42cc-9815-f6b4b0d2e6c6" />
  <br>
Copy these settings.
  <br>
  <img width="659" height="349" alt="image" src="https://github.com/user-attachments/assets/f9dff8ab-00ec-4118-a7e3-ab0ed0752845" />
  <br>
</p>

## 1.1 Method 2 (ONLY AMD / INTEL)

Set present mode to immediately deliver any frame instead of waiting.<br>
`nano ~/game.sh`<br><br>
Add present mode variable:<br>
(or visit #4)<br>
`#!/bin/bash`<br>
`export MESA_VK_WSI_PRESENT_MODE=immediate`<br>
`exec "$@"`<br>
Save with `Ctrl X, Ctrl Y, Enter`<br>

# 2. How to disable X11 in favour of Wayland (only for wayland)
Assuming you run Wayland, there is an extra layer between Geometry Dash and your screen called XWayland, which is used as Proton runs games with X11 by default.<br>
To change this, we will use steam launch options, I have found that Proton-GE and Proton-cachyos both have the PROTON_ENABLE_WAYLAND variable available, Proton Experimental does not.<br>

First, check that Geometry Dash is running through XWayland, I will do this through the KWin debug console<br>
<img width="679" height="129" alt="image" src="https://github.com/user-attachments/assets/38a1613a-f335-4a5e-a0e3-cad243f62cb5" />
Open Geometry Dash, and check if Geometry Dash is in Wayland or X11 windows category.<br>
If it is in X11 category, follow these steps to make Geometry Dash use Wayland:<br>
`nano ~/game.sh`<br><br>
Add wayland variable:<br>
(or visit #4)<br>
`#!/bin/bash`<br>
`export PROTON_ENABLE_WAYLAND=1`<br>
`exec "$@"`<br>
Save with: `Ctrl X, Ctrl Y, Enter`<br>

Go to Geometry Dash on Steam, right click it in your library and click on Properties<br>
Enter this into the LAUNCH OPTIONS box: `~/game.sh %command%`<br>
Launch Geometry Dash and check KWin debug console, make sure that Geometry Dash is under Wayland Windows<br><br><br><br>

# 3. Platform-specific tweaks

## AMD GPU
Add this line in your game.sh:<br>
(or visit #4)<br>
`export ENABLE_LAYER_MESA_ANTI_LAG=1`<br>

# 4. Global game.sh
This game.sh is designed to cover all cases for lowest latency:<br>
`#!/bin/bash`<br>
`export PROTON_ENABLE_WAYLAND=1`<br>
`export MESA_VK_WSI_PRESENT_MODE=immediate`<br>
`export ENABLE_LAYER_MESA_ANTI_LAG=1`<br>
`export PROTON_NO_STEAMINPUT=1`<br>
`export LD_PRELOAD=""`<br>
`exec "$@"`<br>

Explanation:
<table>
  <tr>
    <td>PROTON_ENABLE_WAYLAND=1</td>
    <td>Enables Wayland over X11 to avoid XWayland input lag overhead</td>
  </tr>
  <tr>
    <td>MESA_VK_WSI_PRESENT_MODE=immediate</td>
    <td>Uses present mode, which instantly displays a frame instead of waiting for the next frames for example with vsync.</td>
  </tr>
  <tr>
    <td>ENABLE_LAYER_MESA_ANTI_LAG=1</td>
    <td>Reduces input lag on AMD GPUs with AMD Anti-Lag</td>
  </tr>
  <tr>
    <td>PROTON_NO_STEAMINPUT=1</td>
    <td>Fixes controller compatibility issues</td>
  </tr>
  <tr>
    <td>LD_PRELOAD=""</td>
    <td>Removes steam overlay to fix stuttering caused by steam's game recorder feature</td>
  </tr>
</table>

# Common issues
"The game doesn't open from steam anymore after adding launch options"<br>
This is due to the game.sh not being executable, use this command to fix the issue:<br>
`chmod +x ~/game.sh`


## Feel free to make a pull request to improve the quality of this document and suggest other methods.
