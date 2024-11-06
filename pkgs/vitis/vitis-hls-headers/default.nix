{ lib
, stdenv
, xilinx-pkgs
, version
}:
stdenv.mkDerivation {
  pname = "vitis-hls-headers";
  inherit version;

  src = "${xilinx-pkgs}/Vitis_HLS/${version}/include";
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/include
    cp -r $src/* $out/include
  '';

  meta = {
    description = "Vitis ${version} HLS headers";
    license = lib.licenses.unfree;
  };
}
