# {
#   description = "KV260-related builds";
#
#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
#   };
#
#   outputs = { self, nixpkgs }:
#   let
#     pkgs-x86 = import nixpkgs {
#       system = "x86_64-linux";
#       overlays = import ./pkgs/overlay.nix;
#       config = {
#         allowUnfree = true;
#       };
#     };
#     pkgs-aarch64 = import nixpkgs {
#       system = "aarch64-linux";
#       overlays = import ./pkgs/overlay.nix;
#       config = {
#         allowUnfree = true;
#       };
#     };
#
#     mkXclbinFirmwareKV260 = pkgs-x86.callPackage ./libs/xclbin {};
#     webpEncFirmware = mkXclbinFirmwareKV260 ./webpEnc.xclbin;
#   in
#   {
#     packages.x86_64-linux = {
#       inherit webpEncFirmware;
#       inherit (pkgs-x86.xrtPackages) xrt;
#       inherit (pkgs-x86) libwebp-jacklicn;
#     };
#
#     packages.aarch64-linux = {
#       webpEncHost = pkgs-aarch64.webpEncHost.override {
#         platformNew = "edge";
#       };
#       inherit (pkgs-aarch64) libwebp-jacklicn;
#     }; 
#   };
# }
{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

        snowfall-lib = {
            url = "github:snowfallorg/lib";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs:
      inputs.snowfall-lib.mkFlake {
        inherit inputs;
        src = ./.;

        root = ./nix;
    };
}
