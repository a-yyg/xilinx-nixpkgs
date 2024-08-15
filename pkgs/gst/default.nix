{ pkgs, lib, gst_all_1, fetchurl, ... }:
{
  gst-omx = pkgs.callPackage ./gst-omx.nix {};
  # gst-plugins-bad = pkgs.callPackage ./gst-plugins-bad.nix {};
  gst-plugins-bad = gst_all_1.gst-plugins-bad.overrideAttrs (oldAttrs: {
    version = "1.18.5";
    src = fetchurl {
      url = "https://github.com/Xilinx/gst-plugins-bad/archive/refs/tags/xlnx-rebase-v1.18.5_2022.2.zip";
      hash = lib.fakeSha256;
    };
  });
}
