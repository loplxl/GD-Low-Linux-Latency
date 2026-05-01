# NixOS

This document contains instructions and example implementations for NixOS. Some of the material here mayapply to Linux systems managed with [System Manager](https://github.com/numtide/system-manager), though that's not a guarantee.

You're expected to know how NixOS and the Nix language work, at least the basics.

Get a text editor ready! `nano` is installed by default on NixOS. Some basic instructions to use it are outlined in the README.

Some NixOS users have customized the location or amount of configuration files. Please adapt these instructions accordingly.

> [!NOTE]
> **An example configuration (containing ONLY the stuff relevant for this guide) has been provided next to this file. Check the file tree for the `example` folder.**

> [!CAUTION]
> ***The example is NOT a drop-in config. It's meant as a reference to see what all the relevant options together look like, and would probably not even be a valid NixOS/Home Manager configuration. If you want to use it, read this guide carefully, and ADD it to your existing config. Remember that you're expected to know how Nix works.***

### Contributing

If you know of any undocumented ways enable screen tearing/tearing flip in DEs, WMs, Wayland compositors, etc., or install Proton versions, declaratively in one's Nix configurations, or if you notice something wrong, missing, unnecessary, or that can be improved, feel free to fork this repository, add/modify the relevant instructions, and open a pull request to this repository.

## Preliminary work

### Flakes

If your config is already flake-based, you can skip this section.

Before doing everything, we'll have to change our config up a bit to make it more useful.

You'll need to edit your system configuration files. By default, these are located in `/etc/nixos/`, with files `configuration.nix` and `hardware-configuration.nix`.

> [!CAUTION]
> ***DO NOT EDIT `hardware-configuration.nix`***.

We'll convert your configuration into a flake.

> [!NOTE]
> Nix is meant to be a reproducible language; given the same configuration content, a similar environment should be generated. Flakes improve on this by pinning specific versions of packages. But, more importantly, flakes can use other flakes as inputs. We'll need this for later.

First, edit `configuration.nix` and add the following:

```nix
# ...

{
    # ...

    # we need these to turn the config into a flake-based one
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # ...
}
```

After that, rebuild your NixOS config:

```bash
sudo nixos-rebuild switch
```

You should now be able to run the following command. Still in your configuration directory, run this command:

```bash
sudo nix flake init
```

We'll now edit this new file. Change it so it's like this:

```nix
{
    description = "My NixOS configuration"; # or whatever you want

    inputs = {
        # Using unstable is recommended here for the latest updates
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, ... }@inputs: rec {
        nixosConfigurations = {
            # leave yourcomputer as it was
            yourcomputer = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    ./configuration.nix
                ];
            };
        };
    };
}
```

Finally, run these commands:

```bash
# this will update all packages needed by your config to their latest version in your channel (in our case, unstable)
nix flake update

# rebuild system
sudo nixos-rebuild switch
```

We're done for now! We'll come back to this `flake.nix` file later.

From now on, to update, you should do another `sudo nix flake update` before rebuilding.

### Home Manager

If you're already using a flake-based Home Manager install, you can skip this section. Bear in mind that the guide will use a standalone flake-based Home Manager install, not as a NixOS module or anything else. Adapt this to your setup.

After switching to flakes, we're ready to install [Home Manager](https://github.com/nix-community/home-manager). It's a little tool that helps separate your system config and programs from your user config and programs. It allows you to declare user configuration files, which we'll need!

There's several ways to install it, check [this link](https://nix-community.github.io/home-manager) for more details. For this to work, we'll need a flake-based installation. Installing it standalone is recommended, and this guide will assume a standalone installation.

> [!WARNING]
> **It's NOT the first "Standalone installation" in the table of contents! Scroll down to find a "Standalone setup" under a "Nix Flakes" section.**

> [!NOTE]
> **Use the same channel you used for switching to flakes above. In the context of what we showed in this guide, that'd be the unstable channel.**

As mentioned in the Home Manager link above, and assuming you did a standalone flake-based installation, after initial setup, the home configuration files should be in `~/.config/home-manager/`. There should be a `flake.nix` file and a `home.nix` file.

## Drivers

As with any distro, AMD drivers are already installed. Reverse-engineered, free and open source drivers for NVIDIA cards are included, but the official drivers are better for gaming.

You'll also need NTSYNC.

> [!NOTE]
> Proton, the thing Steam uses to run Windows games such as GD, uses Wine, which translates Windows programs' system calls into Linux. Some of these translations are made faster with the NTSYNC Linux driver, improving performance and latency.

Add this in your configuration:

```nix
# ...

{
    # ...

    nixpkgs.config.allowUnfree = true; # needed for NVIDIA

    hardware = {
        graphics.enable = true;

        nvidia = {
            modesetting.enable = true;

            # maybe you want this, check the NixOS wiki for more information (that's wiki.nixos.org not nixos.wiki)
            powerManagement = { enable = false; finegrained = false; };

            open = false;
            nvidiaSettings = true;
        };
    };

    boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" "ntsync" ];

    services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

    # ...
}
```

## X11

NixOS users are on X11 by default. It's recommended to keep it enabled. No further action is required to use X11.

X11 is well supported, but old and unmaintained, rarely receiving updates.

## Wayland

Wayland is a newer, modern and more secure communication protocol that's actively maintained. It's currently being adopted by many major Linux distributions, over X11, and support for it is increasing.

If you want to use Wayland, add this to your configuration:

```nix
# ...

{
    # ...

    environment.systemPackages = with pkgs; [
        xwayland-satellite # for some X11 programs this is useful, recommend leaving it in
    ];

    services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
    };

    programs.xwayland.enable = true;

    # ...
}
```

## Proton

As mentioned earlier, Proton is the thing that Steam uses to run Windows games. But the Proton included in Steam is missing a few things that we need. We gotta use another version of Proton.

We're gonna use ProtonUp-Qt, an app that makes installing custom Proton versions easier.

You don't need to install it, you can "test run" it, which still installs Proton even after you stop the app:

```bash
nix-shell -p protonup-qt --command protonup-qt
```

Or, alternatively, to install it, you can add this in your `configuration.nix`:

```nix
# ...

{
    # ...

    environment.systemPackages = with pkgs; [ protonup-qt ];

    # ...
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

and run it with:

```bash
protonup-qt
```

In the window, click "Add Version", and in the popup, select "Proton-CachyOS" (recommended) or "GE-Proton" under the "Compatibility Tool" dropdown menu. Then click "Install" and wait for it to finish.

When it's done, open Steam, go to GD in your library, open up its properties, and go to the "Compatibility" section, check "Force the use of a specific Steam Play compatibility tool", and select the one you installed.

## Desktop Environments, V-Sync and Screen Tearing

Vertical synchronization (V-Sync) causes latency. Disabling it causes screen tearing, but reduces latency.

Not all desktop environments, window managers, and Wayland compositors are documented here. Please check the documentation or settings app of whatever you're using to see how you can disable V-Sync.

### KDE Plasma

Follow the non-code instructions for KDE Plasma in the README, skipping the part where you edit `/etc/environment`, but before adding the window rule, add the following to your `configuration.nix`:

```nix
# ...

{
    # ...
    
    environment.etc."environment".text = ''
        KWIN_DRM_NO_AMS=1
    '';

    # ...
}
```

and rebuild:

```bash
sudo nixos-rebuild switch
```

Now go and add the window rule.

### Hyprland

> [!NOTE]
> This section is unfinished.

Edit your `configuration.nix`:

```nix
# ...
{
    # ...

    environment.etc."environment".text = ''
        Direct_Scanout=1
    '';

    # ...
}
```

and rebuild:

```bash
sudo nixos-rebuild switch
```

### Niri

This is part of the reason why we needed to make the config flake-based.

Niri doesn't officially support screen tearing. This is because Smithay, a Niri dependency, doesn't either. However, GitHub user urayde has a fork of Niri that supports screen tearing by using their Smithay fork.

urayde sadly doesn't provide binaries, but that's not as much of a problem here in NixOS. Just specify that you want to use urayde's fork, and NixOS will build it and install it as if it was the official package, working just as intended.

Edit your `flake.nix`:

```nix
{
    # ...

    inputs = {
        # ...

        # urayde's niri
        niri-package = {
            url = "github:urayde/niri"; 
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # this makes working with niri on nixos a bit easier
        # thanks sodiboo my goat
        niri = {
            url = "github:sodiboo/niri-flake";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.niri-unstable.follows = "niri-package";
        };

        # ...
    };

    outputs = { self, nixpkgs, ... }@inputs: rec {
        # blah blah the same as you had before BUT under the modules list thing you gotta add `inputs.niri.nixosModules.niri`
    };
}
```

Then, in your `configuration.nix`, make these changes:

```nix
{ config, lib, pkgs, inputs, ... }: # this is the very beginning of the file
# notice we added `inputs` here, that's important

{
    # ...

    nixpkgs.overlays = [ inputs.niri.overlays.niri ]; # this will let us use the fork

    programs.niri = {
        enable = true;
        package = pkgs.niri-unstable; # this says like "hey use this fork for the package"
    };

    # ...
}
```

> [!CAUTION]
> ***Don't rebuild yet. This may remove your existing Niri configuration. We'll take care of that next!***

Now, go to your Home manager config folder, and edit `flake.nix` to look something like this:

```nix
{
    # ...

    inputs = {
        # ...

        niri = {
            url = "github:sodiboo/niri-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { nixpkgs, home-manager, ... }@inputs:
    let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
    in {
        # leave the "yourusername" as your username, should be there by default eg "j", "janedoe"
        homeConfigurations."yourusername" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs; };
            modules = [
                inputs.nixi.homeModules.config
                ./home.nix
                # ...
            ];
        };
    };
}
```

After that, if you have an existing Niri configuration, copy-paste it into the home-manager config folder, as `niri.kdl`:

```bash
cp ~/.config/niri/config.kdl ./niri.kdl
```

Edit `niri.kdl` and add one of the following options, somewhere in the file:

```kdl
// ...

// option one: window rule
// this will enable tearing only when the GD window is focused
// try to put this next to existing window rules to keep it tidy
window-rule {
    match app-id="steam_app_322170" is-focused=true

    allow-tearing true
}

// option two: debug options
// this will force tearing everywhere
// warning! this a debug option is not meant for normal use
// use at your own risk
debug {
    force-tearing
}

// ...
```

Finally, edit `home.nix`:

```nix
{ config, lib, pkgs, inputs, ... }:

{
    # ...

    programs.niri = {
        config = (builtins.readFile ./niri.kdl);
    }

    # ...
}
```

We're done! Now the usual rebuild:

```bash
sudo nixos-rebuild switch
```

and a Home Manager rebuild:

```bash
# still on the home manager config directory
nix flake update

home-manager switch
```

and we're done!

> [!CAUTION]
> Upon rebuilding the Home Manager configuration, `niri.kdl` will replace `~/.config/niri/config.kdl`. ***You can still change the latter file, but it will get overridden every time you rebuild your Home Manager config. Prefer editing `niri.kdl` and rebuilding instead.***

## Kernel

The default Linux kernel is slow and cringe. Let's use CachyOS kernel instead!

The CachyOS kernel is widely regarded as the best kernel family for gaming, with many Linux gamers using CachyOS because of its optimizations, and many others going out of their way to get the kernel.

GitHub user xddxdd has provided a flake with several CachyOS kernel variants available as packages for use with NixOS.

Go to your system configuration directory and edit `flake.nix`:

```nix
{
    # ...

    inputs = {
        # ...
        
        # cachyos kernel
        nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    outputs = { self, nixpkgs, nix-cachyos-kernel, ... }@inputs: rec {
        # we're not adding any modules this time, but notice the nix-cachyos-kernel above this line
    };
}
```

Now edit `configuration.nix`:

```nix

{ config, lib, pkgs, inputs, ... }:

let
    nix-cachyos-kernel = inputs.nix-cachyos-kernel;
in
{
    # ...

    nixpkgs.overlays = [
        nix-cachyos-kernel.overlays.default
    ];

    boot = {
        # this installs the BORE scheduler variant of cachyos kernel
        # BORE scheduler is known as the best scheduler for performance
        # and better than stock scheduler for latency
        # doesn't really matter that much since we'll use another scheduler later
        # but it's good to have
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;
    }

    # ...
}
```

And rebuild:

```bash
sudo nixos-rebuild switch
```

### Scheduler

While BORE scheduler is certainly better than stock scheduler, it's not the one with the best latency. That crown belongs to `scx_cosmos`. At least as far as this guide is aware. `scx_cosmos` sadly takes away a *small* bit of performance, but it's nothing noticeable, and definitely still better than stock scheduler.

SCX is a service that allows one to just run another scheduler, overriding the one from the kernel. And the rest of the kernel optimizations are still there!

Edit configuration.nix once again:

```nix
# ...

{
    # ...

    services.scx = {
        enable = true;
        scheduler = "scx_cosmos";
        extraArgs = [
            "-m performance"
            "-c 0"
            "-p 0"
            "-w"
        ];
    };

    # ...
}
```

and rebuild:

```bash
sudo nixos-rebuild switch
```

## Ananicy

Ananicy is a little program that manages IO and CPU priorities. We'll use CachyOS's Ananicy rules.

Edit `configuration.nix`:

```nix
# ...

{
    # ...

    services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp; # ananicy is originally a python program, the c++ rewrite uses less resources
        rulesProvider = pkgs.ananicy-rules-cachyos;
    };
}
```

And rebuild:

```bash
sudo nixos-rebuild switch
```

## Launch Options

This isn't NixOS-specific; please refer to the README's Environment Variables section.