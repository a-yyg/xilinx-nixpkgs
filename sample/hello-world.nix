{ stdenv
, gnumake
, libuuid
, xrtPackages
}:
stdenv.mkDerivation {
  name = "hello-world";
  src = ./hello-world;

  nativeBuildInputs = [
    gnumake
  ];

  NIX_CFLAGS_COMPILE = "-I${xrtPackages.xrt-2-13}/include/xrt";

  buildInputs = [
    xrtPackages.xrt-2-13
    libuuid
  ];

  buildPhase = ''
    runHook preBuild

    make host

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv app $out/bin/app
  '';
}

