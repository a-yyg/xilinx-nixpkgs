{ lib
, stdenv
, autoPatchelfHook
, libxcrypt-legacy
, xorg
, xz
, zlib
, xilinx-pkgs
, version
}:
stdenv.mkDerivation {
  pname = "vitis-lib";
  inherit version;

  src = "${xilinx-pkgs}/Vitis/2023.2";

  buildInputs = [
    autoPatchelfHook
    stdenv.cc
    libxcrypt-legacy
    xorg.libX11
    xz
    zlib
  ];

  unpackPhase = ''
    cp -r $src/lib/lnx64.o/* .
    cp -r $src/llvm-clang/lnx64/llvm/lib/* .
  '';

  # buildPhase = ''
  #   for f in unwrapped/*; do
  #     if [ -f $f ]; then
  #       patchelf --set-interpreter $stdenv/lib/ld-linux-x86-64.so.2 $f
  #     fi
  #   done
  # '';

  installPhase = ''
    mkdir -p $out/lib
    cp -r * $out/lib
  '';

  meta = {
    description = "Vitis ${version} libraries";
    license = lib.licenses.unfree;
  };
}
