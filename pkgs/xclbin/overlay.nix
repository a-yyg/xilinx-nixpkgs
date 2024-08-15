final: prev:
let
  tp = x: builtins.trace x x;
  pipe = prev.lib.trivial.pipe;
  kernels = pipe ./kernels [
    prev.lib.filesystem.listFilesRecursive
    (builtins.filter (f: prev.lib.strings.hasSuffix ".xclbin" f))
  ];
  real-name = xclbin:
    "xclbin-" +
    prev.lib.strings.removeSuffix ".xclbin"
    (builtins.baseNameOf xclbin);
  mkXclbinFirmwareKV260 = prev.callPackage ./xclbin.nix { outDir = ""; };
  kernels-firmware = builtins.map
    (k:
      let firm = mkXclbinFirmwareKV260 k;
      in {name = real-name k; value = firm;}) kernels;
  kernels-firmAttrs = builtins.listToAttrs kernels-firmware;
in kernels-firmAttrs
