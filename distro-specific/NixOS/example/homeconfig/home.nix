{ config, lib, pkgs, inputs, ... }:

{
    # ...

    programs.niri = {
        config = (builtins.readFile ./niri.kdl);
    }

    # ...
}