{ lib
, stdenv
, xilinx-bootgen
, xrt
, dtc
, outDir ? "lib/firmware/xilinx"
}:

xclbin:
let
  real-name = lib.strings.removeSuffix ".xclbin"
    (builtins.baseNameOf xclbin);
  # shell-json = pkgs.writeText "shell.json" ''
  #   {
  #     "shell_type" : "XRT_FLAT",
  #     "num_slots": "1";
  #   }
  # '';
  shell-json = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/Xilinx/kria-apps-firmware/xlnx_rel_v2022.2/boards/kv260/smartcam/shell.json";
    sha256 = "sha256:13kc81p0xy2x843y370vijdp0ybbim9y65sp5798pj53xcsgz8hi";
  };
  dtsi = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/Xilinx/kria-apps-firmware/xlnx_rel_v2022.2/boards/kv260/smartcam/kv260-smartcam.dtsi";
    sha256 = "sha256:0bl1897xm6ylw1idfiqiwbi4hglgmf909fnswnb68pmx56hqr2w1";
  };
in stdenv.mkDerivation {
  name = "xclbin-firmware-${real-name}";
  src = xclbin;
  dontUnpack = true;

  buildInputs = [
    xrt
    xilinx-bootgen
    dtc
  ];

  buildPhase = ''
    cp $src binary.xclbin
    ${xrt}/bin/unwrapped/xclbinutil --dump-section BITSTREAM:RAW:system.bit --input binary.xclbin
    echo 'all:{system.bit}'>bootgen.bif
    bootgen -w -arch zynqmp -process_bitstream bin -image bootgen.bif

    cp ${dtsi} system.dtsi
    dtc -@ -O dtb -o system.dtbo system.dtsi

    OUT_DIR=$out/${outDir}/${real-name}
  '';

  installPhase = ''
    mkdir -p $OUT_DIR
    mv system.bit.bin $OUT_DIR/${real-name}.bit.bin
    mv binary.xclbin $OUT_DIR/${real-name}.xclbin
    cp ${shell-json} $OUT_DIR/shell.json
    mv system.dtbo $OUT_DIR/${real-name}.dtbo
  '';
}
