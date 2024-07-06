{ pkgs }:
let
  overlay = import ../pkgs/overlay.nix;
  pkgs' = pkgs.extend overlay;
  hello-world = pkgs'.callPackage ./hello-world.nix {};
in
hello-world
