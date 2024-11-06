final: prev:
let
  version = "2023.2";
  xilinx-pkgs = builtins.fetchGit {
    url = "git@github.com:a-yyg/xilinx-pkgs.git";
    ref = version;
    rev = "30c093ae72530f9becb05ab5d53d8d465b01e1b9";
  };
  xilinxPkg = f: prev.callPackage f { inherit xilinx-pkgs version; };
in
{
  vitis-hls-headers = xilinxPkg ./vitis-hls-headers;
  vitis-bin = xilinxPkg ./vitis-bin;
  vitis-lib = xilinxPkg ./vitis-lib;
  vitis-fhsenv = prev.callPackage ./shell.nix {};
}
