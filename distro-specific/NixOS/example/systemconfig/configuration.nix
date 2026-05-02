{ config, lib, pkgs, inputs, ...}:

let
    nix-cachyos-kernel = inputs.nix-cachyos-kernel;
    proton-flake = inputs.proton-flake;
in
{
    # ...



    # just as a reminder there's some unfinished sections, namely the hyprland one



    nixpkgs = {
        config.allowUnfree = true; # needed for NVIDIA
        overlays = [
            inputs.niri.overlays.niri # this will let us use the fork for tearing support
            nix-cachyos-kernel.overlays.default
        ];
    };

    # we need these to turn the config into a flake-based one
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    


    # nvidia stuff
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

    boot = {
        initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" "ntsync" ]; # nvidia stuff + ntsync to make proton/wine faster



        # this installs the BORE scheduler variant of cachyos kernel
        # BORE scheduler is known as the best scheduler for performance
        # and better than stock scheduler for latency
        # doesn't really matter that much since we'll use another scheduler later
        # but it's good to have
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;
    };


    environment = {
        # KWIN_DRM_NO_AMS=1 for KDE Plasma
        # Direct_Scanout=1 for Hyprland
        etc."environment".text = ''
            KWIN_DRM_NO_AMS=1
            Direct_Scanout=1
        '';
        systemPackages = with pkgs; [
            protonup-qt # for proton thing to do it imperatively
            xwayland-satellite # for some X11 programs this is useful, recommend leaving it in
        ];
    };

    services = {
        xserver.videoDrivers = [ "nvidia" "amdgpu" ];
        displayManager.sddm = {
            enable = true;
            wayland.enable = true;
        };

        # kde plasma 6
        desktopManager.plasma6 = {
            enable = true;
            withQt5Integration = true;
        };

        # scx cosmos, slightly less performance but best latency
        scx = {
            enable = true;
            scheduler = "scx_cosmos";
            extraArgs = [
                "-m performance"
                "-c 0"
                "-p 0"
                "-w"
            ];
        };

        # ananicy, automatically manages IO and CPU priorities
        ananicy = {
            enable = true;
            package = pkgs.ananicy-cpp; # ananicy is originally a python program, the c++ rewrite uses less resources
            rulesProvider = pkgs.ananicy-rules-cachyos; # cachyos provides rules for ananicy, they've been packaged for nixos
        };
    };

    programs = {
        xwayland.enable = true;
        
        # niri
        niri = {
            enable = true;
            package = pkgs.niri-unstable; # this says like "hey use this fork for the package"};
        };
        
        # hyprland
        hyprland = {
            enable = true;
            withUWSM = true;
            xwayland.enable = true;
        };

        # steam (guide assumes you have this already but this is for the proton thing)
        steam = {
            enable = true;
            extraCompatTools = [
                # this installs the proton versions declaratively
                proton-flake.${pkgs.stdenv.hostPlatform.system}.cachyos-proton
                proton-flake.${pkgs.stdenv.hostPlatform.system}.ge-proton
            ];
        };
    };

    # ...
}
