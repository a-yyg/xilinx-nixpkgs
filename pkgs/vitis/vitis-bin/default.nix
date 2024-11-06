{ lib
, stdenv
, autoPatchelfHook
# , boost
, vitis-lib
, libyaml
, xercesc
, xilinx-pkgs
, version
}:
stdenv.mkDerivation {
  pname = "vitis-bin";
  inherit version;

  src = "${xilinx-pkgs}/Vitis/2023.2/bin";
  buildInputs = [
    autoPatchelfHook
    stdenv.cc
    # boost
    libyaml
    xercesc
    vitis-lib
  ];

  buildPhase = ''
    # for f in unwrapped/*; do
    #   if [ -f $f ]; then
    #     patchelf --set-interpreter $stdenv/lib/ld-linux-x86-64.so.2 $f
    #   fi
    # done
    for f in $(grep -lRE '/bin/bash'); do
      sed -i.old '1s;^;#!/usr/bin/env bash\n;' "$f"
    done
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin
  '';

  meta = {
    description = "Vitis ${version} binaries";
    license = lib.licenses.unfree;
  };
}
