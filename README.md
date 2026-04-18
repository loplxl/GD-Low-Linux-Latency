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
- [8. Scheduler](#8-scheduler)

<br>
<h1 align="center">1. Graphics Drivers</h1>
The single most important part of this guide.<br>
This is a pretty long topic so for this step you should check out this guide instead:<br>
https://github.com/lutris/docs/blob/master/InstallingDrivers.md<br><br>

I would highly recommend testing a desktop environment using X11 if you use an NVIDIA GPU over Wayland as it may deliver better performance and latency.<br>
If you do decide to use X11, you can skip the "Enabling Tearing" step and disable the compositor in the settings app instead.<br>

<h1 align="center">2. The Kernel</h1>
If you are on a gaming focused Linux distribution such as CachyOS, then you dont have to worry about this as they already use a custom kernel made for gaming specifically by default.<br>
However, if you are not on one, then this might potentially make a noticeable difference in system performance, stability, responsiveness and latency.<br>
Some gaming focused custom kernels include CachyOS, Xanmod, Liquorix and Zen.<br>

<h1 align="center">3. Proton</h1>
Similar to using a custom kernel, using a custom Proton build such as Proton-GE or CachyOS's Proton will provide you better performance all around and allow the usage of some environment variables such as PROTON_ENABLE_WAYLAND to avoid XWayland if you're on Wayland.<br>

<h1 align="center">4. Enabling Tearing on Wayland</h1>
You can search for instructions on how to do this for your desktop environment if it is not mentioned here. (maybe make a PR? :D)<br>

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
If you're using Nano, save with: `Ctrl+X, Ctrl+Y, Enter`<br>

Afterwards, in your start menu search up "Window Rules" and open it.<br>
Click "Add Property" and add "Allow Tearing" by clicking on the "+" next to it.<br>
Once added, make sure Allow Tearing is set to "Force".<br>
Set Window Class to "Exact match" and put "steam_app_322170" into the text box and then finally click on Apply.<br>

<h2 align="left">Hyprland:</h2>
In your /etc/environment file, put:<br>

```
Direct_Scanout=1
```

Make sure to run your game in fullscreen otherwise it will not work.<br>

If you're using Nano, save with: `Ctrl+X, Ctrl+Y, Enter`<br>
Afterwards go into your '~/.config/hypr/hyprland.conf' config file, find the allow_tearing variable and set it to true.<br>
After that, right outside of the bracket, put the following:<br>

```
windowrule = match:class steam_app_322170, immediate yes
```
It should now look something like this:<br>
```
general {
    allow_tearing = true
}

windowrule = match:class steam_app_322170, immediate yes
```
Make sure to run your game in fullscreen otherwise it will not work.<br>

<h1 align="center">5. Environment Variables</h1>
Use the following environment variables in your Geometry Dash launch options for the least latency:<br>
To set environment variables in Steam, right click Geometry Dash in your library, click on properties and paste the following into your launch options:<br>

```
PROTON_ENABLE_WAYLAND=1 PROTON_USE_NTSYNC=1 SDL_VIDEO_DRIVER=wayland SDL_VIDEODRIVER=wayland vblank_mode=0 WINEDLLOVERRIDES="xinput1_4=n,b" %command%
```
Explanation:
<table>
  <tr>
    <td align="center">PROTON_ENABLE_WAYLAND=1</td>
    <td align="center">Enables Wayland over X11 to avoid XWayland input lag overhead. You need a custom proton build to use this, such as GE or CachyOS's.</td>
  </tr>
  <tr>
    <td align="center">PROTON_USE_NTSYNC=1</td>
    <td align="center">NTSync is a kernel module to do some of the work that Wine does directly on the kernel, significantly reducing input latency in some cases.</td>
  </tr>
  <tr>
    <td align="center">SDL_VIDEO_DRIVER=wayland<br>SDL_VIDEODRIVER=wayland</td>
    <td align="center">Forces SDL (2 and 3) apps to use Wayland back-end instead of defaulting to X11/XWayland. Without it, SDL uses X11 even under Wayland unless compiled otherwise.</td>
  </tr>
  <tr>
    <td align="center">vblank_mode=0</td>
    <td align="center">Does not allow the usage of VSync by forcefully disabling it driver side.</td>
  </tr>
  <tr>
    <td align="center">WINEDLLOVERRIDES="xinput1_4=n,b"</td>
    <td align="center">Required for the mod loader <a href="https://geode-sdk.org">Geode</a> to function.</td>
  </tr>
</table>

<h1 align="center">6. Ananicy-Cpp</h1>
Ananicy-Cpp is a system daemon that can automatically adjust the nice (priority) levels of applications.<br>
If you're on a "gaming focused" distro such as CachyOS then it will already be installed for you.<br>

TBD<br>


<h1 align="center">7. Power Profile</h1>
TBD<br>

<h1 align="center">8. Scheduler</h1>
Currently, scx_cosmos with the "-m performance -c 0 -p 0 -w" parameters (aka. low latency) tend to be the best for low latency on most systems.<br>
If you do not want to use external schedulers, BORE is also a great option.<br>
<br>
<h2 align="center">Feel free to make a pull request to improve the quality of this guide and to suggest other methods!</h2>
