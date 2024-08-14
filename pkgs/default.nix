{ lib, pkgs }:
let
  overlay = lib.fixedPoints.composeManyExtensions (import ./overlay.nix);
  newPkgsOverlay = final: prev:
  {
    newPackages = (overlay final prev);
  };
in (pkgs.extend newPkgsOverlay).newPackages
