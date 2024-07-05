{ pkgs }:
let
  overlay = final: prev: {
    inherit xrt;
  };
  callPackage' = (pkgs.extend overlay).callPackage;
  xrt = pkgs.callPackage ../pkgs/xrt {};
  hello-world = callPackage' ./hello-world.nix {};
in
hello-world
