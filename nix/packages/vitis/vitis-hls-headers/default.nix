{ lib
, stdenv
, version ? "2023.2"
}:
let
  xilinx-pkgs = builtins.fetchGit {
    url = "git@github.com:a-yyg/xilinx-pkgs.git";
    ref = version;
    rev = "750cf09302aa704b897a2216e68bf8ecf5d2aae7";
  };
in
stdenv.mkDerivation {
  name = "vitis-hls-headers";
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
