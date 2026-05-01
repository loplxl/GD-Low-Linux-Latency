{
    description = "My NixOS configuration"; # or whatever you want

    inputs = {
        # Using unstable is recommended here for the latest updates
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
    
        # cachyos kernel
        nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

        # ...
    };

    outputs = { self, nixpkgs, nix-cachyos-kernel, ... }@inputs: rec {
        nixosConfigurations = {
            # leave yourcomputer as it was
            yourcomputer = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    inputs.niri.nixosModules.niri
                    ./configuration.nix
                    # ...
                ];
            };
        };
    };
}