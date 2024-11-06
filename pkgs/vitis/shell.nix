{ buildFHSEnv
, vitis-bin
, vitis-lib
, vitis-hls-headers,
, xrt
}:
buildFHSEnv {
  name = "vitis";
  targetPkgs = pkgs: [
    vitis-bin
    vitis-lib
    vitis-hls-headers
    xrt
  ];
}
