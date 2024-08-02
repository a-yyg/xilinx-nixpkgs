# { lib, ... }:

# lib.fixedPoints.composeManyExtensions [
[
(import ./xrt/overlay.nix)
(import ./vitis/overlay.nix)
(import ./vitis-libraries/overlay.nix)
(import ./libwebp/overlay.nix)
]
