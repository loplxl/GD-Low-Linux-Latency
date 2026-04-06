# Overview
Typically, the culprit for increased input latency on linux can be due to these things:
1. Tearing disabled
2. Geometry Dash running on X11

# 1. <a href="https://github.com/loplxl/GD-Low-Linux-Latency/blob/main/README.md#1">(#)</a>
## How to enable tearing
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
Open system settings and navigate to window rules.
  <br>
  <img width="678" height="132" alt="image" src="https://github.com/user-attachments/assets/b1da3c42-de1f-42cc-9815-f6b4b0d2e6c6" />
  <br>
Copy these settings.
  <br>
  <img width="659" height="349" alt="image" src="https://github.com/user-attachments/assets/f9dff8ab-00ec-4118-a7e3-ab0ed0752845" />
  <br>
</p>

## Method 2
Another method to disable tearing globally is to set the KWIN_DRM_NO_AMS environment variable in /etc/environment<br>
`sudo nano /etc/environment`<br>
Enter: `KWIN_DRM_NO_AMS=1`<br>
Save with `Ctrl X, Ctrl Y, Enter`<br>
Restart your computer

# 2. <a href="https://github.com/loplxl/GD-Low-Linux-Latency/blob/main/README.md#2">(#)</a>
## How to disable X11 in favour of Wayland (only for wayland)
Assuming you run Wayland, there is an extra layer between Geometry Dash and your screen called XWayland, which is used as Proton runs games with X11 by default.<br>
To change this, we will use steam launch options, I have found that Proton-GE and Proton-cachyos both have the PROTON_ENABLE_WAYLAND variable available, Proton Experimental does not.<br>

First, check that Geometry Dash is running through XWayland, I will do this through the KWin debug console<br>
<img width="679" height="129" alt="image" src="https://github.com/user-attachments/assets/38a1613a-f335-4a5e-a0e3-cad243f62cb5" />
Open Geometry Dash, and check if Geometry Dash is in Wayland or X11 windows category.<br>
If it is in X11 category, follow these steps to make Geometry Dash use Wayland:<br>
`nano ~/game.sh`<br>
Enter:<br>
`#!/bin/bash`<br>
`PROTON_ENABLE_WAYLAND=1`<br>
`exec "$@"`<br>
Save with `Ctrl X, Ctrl Y, Enter`<br>

Go to Geometry Dash on Steam, right click it in your library and click on Properties<br>
Enter this into the LAUNCH OPTIONS box: `~/game.sh %command%`<br>
Launch Geometry Dash and check KWin debug console, make sure that Geometry Dash is under Wayland Windows<br><br><br><br>



Feel free to make a pull request to improve the quality of this document and suggest other methods.
