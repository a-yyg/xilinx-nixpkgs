{ stdenv
, lib
, fetchFromGitHub
, cmake
, libdrm
, pkg-config
, opencl-headers
, ocl-icd
, git
, boost
, ncurses
, openssl
, protobuf
, util-linux
, doxygen
, valgrind
, python3Packages
, curl
, opencl-clhpp
, libyaml
, udev
, dpkg
, rapidjson
, libxcrypt
, libffi
, lsb-release
, deterministic-uname
, makeWrapper
, suffix ? null
, year ? null
, sha256 ? lib.fakeSha256
, version ? "${year}.${suffix}"
, edge ? true
, ...
}@extraAttrs:
let
  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "XRT";
    rev = version;
    fetchSubmodules = true;
    inherit sha256;
  };
in
stdenv.mkDerivation {
  pname = "xrt";
  inherit version src;

  enableParallelBuilding = true;

  # we take the matter in our own hand
  dontFixCmake = true;

  buildInputs = [
    libdrm
    opencl-clhpp
    opencl-headers
    ocl-icd
    boost
    ncurses
    openssl
    util-linux
    doxygen
    curl
    valgrind
    python3Packages.sphinx
    python3Packages.pybind11
    libyaml
    udev
    rapidjson
    protobuf
    libxcrypt
    # makeWrapper
  ] ++ lib.optional edge libffi;

  nativeBuildInputs = [
    cmake
    pkg-config
    git
    dpkg
    lsb-release
    deterministic-uname
  ];

  NIX_CFLAGS_COMPILE = [ "-Wno-error" ];
  XRT_NATIVE_BUILD = if edge then "no" else "yes";

  preConfigure = lib.optionalString (extraAttrs ? xrtBin)
  (let
    xrtBin = extraAttrs.xrtBin;
  in
  ''
    if [ ! -f ${xrtBin} ]; then
      echo "xrtBin not found"
      false
    fi

    dpkg-deb -x ${xrtBin} root
    export XRT_FIRMWARE_DIR=$(pwd)/root/lib/firmware/xilinx
    if [ ! -d $XRT_FIRMWARE_DIR ]; then
      echo "NO xrt firmware found in binary release"
      false
    fi
  '')
  + ''
    # Fake git info: https://github.com/Xilinx/XRT/blob/f0f31af48d4545bc9fe77a64ded241db0f564deb/src/CMake/version.cmake#L33C29-L33C50

    export GIT_AUTHOR_NAME="John Doe"
    export GIT_AUTHOR_EMAIL=john@example.com
    export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
    export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
    git init .
    git add .
    git commit -m 'fake commit'
    git checkout -b origin/master

    cd src

    find . -type f -print0 | \
      xargs -0 sed -i -e "s!/opt/xilinx!$out/opt/xilinx!;s!/lib/firmware!$out/lib/firmware!"

    substituteInPlace CMakeLists.txt \
      --replace "/usr" "$out/opt/xilinx"

    substituteInPlace CMake/embedded_system.cmake \
      --replace "/usr" "$out"

    find . -type f \( -iname "*.cmake" -o -iname CMakeLists.txt -o -iname "postinst.in" \) -print0 | \
      xargs -0 --verbose sed -i -e "s!/usr/local/bin!$out/bin!;s!/usr/src/!$out/src/!;s!/etc/OpenCL!$out/etc/OpenCL!;s!/usr/share/pkgconfig!$out/lib/pkgconfig!"
  '';

  prePatch = ''
    for f in $(grep -lRE '(uint8_t|uint32_t|uint64_t)'); do
        sed -i.old '1s;^;#include <stdint.h>\n;' "$f"
    done

    for f in $(grep -lRE '/usr'); do
        sed -i -e "s!/usr!$out!g" "$f"
    done
  ''
    + lib.optionalString (extraAttrs ? prePatch) extraAttrs.prePatch;

  postInstall = ''''
    + lib.optionalString (!edge) ''
      ln -s $out/opt/xilinx/xrt/include $out/include
      ln -s $out/opt/xilinx/xrt $out/include/xrt
      ln -s $out/opt/xilinx/xrt/lib/* $out/lib
      ln -s /opt/xilinx/firmware $out/opt/xilinx/firmware
      ln -s $out/lib/firmware/xilinx $out/opt/xilinx/xrt/share/fw
    '';

  # postFixup = ''
  #   wrapProgram $out/bin/xclmgmt
  # '';

  shellHook = ''
    XILINX_XRT=$out
  '';

  meta = with lib; {
    description = "xilinx runtime library";
    homepage = "https://www.xilinx.com/products/boards-and-kits/alveo/u50.html#gettingStarted";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
