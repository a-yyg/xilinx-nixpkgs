{ stdenv
, gnumake
, libuuid
, xrt
}:
stdenv.mkDerivation {
  name = "hello-world";
  src = ./hello-world;

  nativeBuildInputs = [
    gnumake
  ];
  buildInputs = [
    xrt
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

