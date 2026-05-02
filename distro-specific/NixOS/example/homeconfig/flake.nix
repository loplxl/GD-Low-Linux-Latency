{
    description = "My Home Manager Configuration"; # or something else it don't matter

    inputs = {
        # Using unstable is recommended here for the latest updates
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        niri = {
            url = "github:sodiboo/niri-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # ...
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