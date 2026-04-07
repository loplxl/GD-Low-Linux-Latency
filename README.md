<h1 align="center">Overview</h1>
Typically, the culprit for increased input latency on Linux may be:<br>
1. Poorly set up graphics drivers<br>
2. Compositor forcing V-Sync<br>
3. Geometry Dash running through XWayland<br>

<h1 align="center">Sections</h1>

- [1. Graphics Drivers](#1-graphics-drivers)
- [2. The Kernel](#2-the-kernel)
- [3. Proton](#3-proton)
- [4. Enabling Tearing on Wayland](#4-enabling-tearing-on-wayland)
- [5. Environment Variables](#5-environment-variables)
- [6. Ananicy-Cpp](#6-ananicy-cpp)
- [7. Power Profile](#7-power-profile)

<br>
<h1 align="center">1. Graphics Drivers</h1>
The single most important part of this guide.<br>
This is a pretty long topic so for this step you should check out this guide instead:<br>
https://github.com/lutris/docs/blob/master/InstallingDrivers.md<br><br>

I would highly recommend testing a desktop environment with X11 if you use an NVIDIA GPU over Wayland as it may deliver better performance and latency.<br>
If you do decide to use X11, you can skip the "Enabling Tearing" step and disable the compositor in the settings app instead.<br>

<h1 align="center">2. The Kernel</h1>
If you are on a gaming focused Linux distribution such as CachyOS, then you dont have to worry about this as they already use a custom kernel made for gaming specifically by default.<br>
However, if you are not on one, then this might potentially make a noticeable difference in system performance, stability, responsiveness and latency.<br>
Some gaming focused custom kernels include CachyOS, Xanmod, Liquorix and Zen.<br>

<h1 align="center">3. Proton</h1>
Similar to using a custom kernel, using a custom Proton build such as Proton-GE or CachyOS's Proton will provide you better performance all around and allow the usage of some environment variables such as PROTON_ENABLE_WAYLAND to avoid XWayland if you're on Wayland.<br>

<h1 align="center">4. Enabling Tearing on Wayland</h1>
You can search for instructions on how to do this for your desktop environment if it is not mentioned here. (maybe make a PR? :D )<br>

Documented:<br>
- [KDE Plasma](#kde-plasma)
- [Hyprland](#hyprland)

Run the following command in your terminal (You can replace "nano" with your preferred CLI text editor):<br>

```
sudo nano /etc/environment
```
After that, follow the steps based on your desktop environment:<br>

<h2 align="left">KDE Plasma:</h2>
Enable the "Allow tearing on full-screen applications" option in Display Configuration and put this in your /etc/environment file:<br>

```
KWIN_DRM_NO_AMS=1
```
Save with: `Ctrl+X, Ctrl+Y, Enter`<br>

<h2 align="left">Hyprland:</h2>
In your /etc/environment file, put:<br>

```
Direct_Scanout=1
```
Save with: `Ctrl+X, Ctrl+Y, Enter`<br>

<h1 align="center">5. Environment Variables</h1>
Use the following environment variables in your Geometry Dash launch options for the least latency:<br>
To set environment variables in Steam, right click Geometry Dash in your library, click on properties and paste the following into your launch options:

```
SDL_VIDEO_DRIVER=wayland PROTON_ENABLE_WAYLAND=1 vblank_mode=0 WINEDLLOVERRIDES="xinput1_4=n,b" %command%
```
Explanation:
<table>
  <tr>
    <td align="center">SDL_VIDEO_DRIVER=wayland</td>
    <td align="center">Forces SDL2 apps to use Wayland back-end instead of defaulting to X11/XWayland. Without it, SDL2 usually uses X11 even under Wayland unless compiled otherwise</td>
  </tr>
  <tr>
    <td align="center">PROTON_ENABLE_WAYLAND=1</td>
    <td align="center">Enables Wayland over X11 to avoid XWayland input lag overhead</td>
  </tr>
  <tr>
    <td align="center">vblank_mode=0</td>
    <td align="center">Uses present mode, which instantly displays a frame instead of waiting for a vertical refresh (vblank)</td>
  </tr>
  <tr>
    <td align="center">WINEDLLOVERRIDES="xinput1_4=n,b"</td>
    <td align="center">Required for <a href="https://geode-sdk.org">Geode</a> to function</td>
  </tr>
</table>

<h1 align="center">6. Ananicy-Cpp</h1>
TBD<br>

<h1 align="center">7. Power Profile</h1>
TBD<br>

<h2 align="center">Feel free to make a pull request to improve the quality of this guide and to suggest other methods!</h2>
