{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, libpng
, libjpeg
, libtiff
, version ? "0.4.3"
}:

stdenv.mkDerivation {
  pname = "libwebp";
  inherit version;
  src = fetchFromGitHub {
    owner = "jacklicn";
    repo = "libwebp";
    rev = "v${version}";
    sha256 = "sha256-vkfEQOnL473ERP1yG9JhpMnTNVtMqb/Bi4AbxDs7CFE=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [
    libpng
    libjpeg
    libtiff
  ];
}
