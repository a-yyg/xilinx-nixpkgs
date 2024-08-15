{
  description = "KV260-related builds";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs-x86 = import nixpkgs {
      system = "x86_64-linux";
      overlays = import ./pkgs/overlay.nix;
      config = {
        allowUnfree = true;
      };
    };
    pkgs-aarch64 = import nixpkgs {
      system = "aarch64-linux";
      overlays = import ./pkgs/overlay.nix;
      config = {
        allowUnfree = true;
      };
    };

    # mkXclbinFirmwareKV260 = pkgs-x86.callPackage ./libs/xclbin {};
    # webpEncFirmware = mkXclbinFirmwareKV260 ./webpEnc.xclbin;
    allPkgs = pkgs: pkgs.lib.attrsets.filterAttrs
      (n: v: pkgs-x86.lib.attrsets.isDerivation v)
      (pkgs.callPackage ./pkgs/default.nix {});
  in
  rec {
    # packages.x86_64-linux = {
    #   inherit webpEncFirmware;
    #   inherit (pkgs-x86.xrtPackages) xrt;
    #   inherit (pkgs-x86) libwebp-jacklicn;
    # };
    packages.x86_64-linux = allPkgs pkgs-x86;

    packages.aarch64-linux = (allPkgs pkgs-aarch64) // {
      webpEncHost = pkgs-aarch64.webpEncHost.override {
        platformNew = "edge";
      };
    };

    # overlays.default = import ./pkgs/overlay.nix;

    devShells.x86_64-linux.default = pkgs-x86.mkShell {
      name = "cpp-dev";
      buildInputs = with pkgs-x86; [
        gnumake
        cmake
        gcc
        clang
        llvm
        xrt
      ];
    };
  };
}
