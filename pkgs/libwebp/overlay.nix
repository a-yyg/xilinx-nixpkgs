final: prev: rec {
  libwebp-jacklicn = prev.callPackage ./default.nix {};
  libwebp-webmproject = libwebp-jacklicn.overrideAttrs (oldAttrs: rec {
    version = "1.4.0";
    src = prev.fetchFromGitHub {
      owner = "webmproject";
      repo = "libwebp";
      rev = "v${version}";
      sha256 = "sha256-OR/VzKNn3mnwjf+G+RkEGAaaKrhVlAu1e2oTRwdsPj8=";
    };
  });
}
