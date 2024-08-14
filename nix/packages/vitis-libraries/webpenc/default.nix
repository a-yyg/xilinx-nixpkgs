{ lib
, stdenv
, fetchzip
, gnumake
, libuuid
, lsb-release
, which
, libpng
, opencl-headers
, vitis-hls-headers
, xrtPackages
, makeWrapper
, version ? "2023.2_update1"
, arch ? if stdenv.hostPlatform.isAarch64 then "aarch64" else "x86"
, target ? "hw"
, platform ? "xilinx_u200_xdma_201830_2"
, platformNew ? "xilinx_u200_xdma_201830_2"
}:
let
  vitis-libraries-src = fetchzip {
    url = "https://github.com/Xilinx/Vitis_Libraries/archive/refs/tags/v${version}.zip";
    sha256 = "sha256-DJhyrVWVqBrwPanlgEN9Ixn++iYgd9FS0XwAokXflYY=";
  };
  vitis-codec = "${vitis-libraries-src}/codec";
  vitis-utils = "${vitis-libraries-src}/utils";
  # build-dir = "build_dir.${target}.${platform}";
  build-dir = "build_dir.${target}."; # Becomes like this when we don't include utils.mk
  local = ./webpEnc;
in
stdenv.mkDerivation {
  pname = "webpEnc-host";
  inherit version;
  src = local;

  # unpackPhase = ''
  #   cp -r $src/ .
  # '';

  # postUnpack = ''
  #   # rm -rf webpEnc
  #   # cp -r ${local} webpEnc
  #   ls -la webpEnc
  #   pwd
  # '';

  nativeBuildInputs = [
    gnumake
  ];

  NIX_CFLAGS_COMPILE = lib.strings.concatStringsSep " " [
    "-I${xrtPackages.xrt-2-13}/include/xrt"
    "-I${vitis-hls-headers}/include"
    "-I${vitis-utils}/L1/include"
  ];

  buildInputs = [
    xrtPackages.xrt-2-13
    libuuid
    lsb-release
    opencl-headers
    vitis-hls-headers
    libpng
    which
    makeWrapper
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "host: check_sysroot" "host: " \
      --replace-fail "include ./utils.mk" "" \
      --replace-fail "\$(XFLIB_DIR)/L2/demos/webpEnc/" ""

    # sed -i 's|.*platforminfo.*||' utils.mk
    # sed -i 's|.*v++.*||' utils.mk
  '';

  enableParallelBuilding = true;

  buildPhase = 
  ''
    runHook preBuild

    make host HOST_ARCH=${arch} TARGET=${target} PLATFORM=${platform} PLATFORM_NEW=${platformNew} \
              XF_PROJ_ROOT=${vitis-codec} -j$NIX_BUILD_CORES

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv ${build-dir}/cwebp $out/bin
  '';

  postFixup = ''
    wrapProgram $out/bin/cwebp \
      --set XILINX_XRT ${xrtPackages.xrt-2-13}
  '';

  meta = with stdenv.lib; {
    description = "WebP encoder";
    mainProgram = "cwebp";
  };
}

