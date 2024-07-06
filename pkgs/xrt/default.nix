{ pkgs, ... }:
let
  xrtPkg = pkgs.callPackage ./xrt.nix;
in
rec {
  xrt = xrt-2-16;

  xrt-2-16 = xrtPkg rec {
    suffix = "2.16.204";
    version = "202320.${suffix}";
    xrtBin = pkgs.fetchurl {
      url = "https://www.xilinx.com/bin/public/openDownload?filename=xrt_${version}_22.04-amd64-xrt.deb";
      sha256 = "sha256-FEhzx2KlIYpunXmTSBjtyAtblbuz5tkvnt2qp21gUho=";
    };
    prePatch = ''
      ls
      substituteInPlace src/runtime_src/xdp/profile/plugin/CMakeLists.txt \
          --replace-fail "add_subdirectory(pl_deadlock)" "" \
          --replace-fail "add_subdirectory(device_offload/hw_emu)" ""
    '';
  };

  xrt-2-13 = xrtPkg {
    version = "202210.2.13.479";
    sha256 = "sha256-6EDCP26njxKKpLpJKL3pnEJb4lUbW+MAD2fahjV7wcw=";
    prePatch = ''
      for f in $(grep -lRE '(std::array)'); do
          sed -i.old '1s;^;#include <array>\n;' "$f"
      done
    '';
  };
}
