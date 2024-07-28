{ lib, stdenv, fetchFromGitHub, pkg-config, python3, cairo, libjpeg, ntk, libjack2
, libsndfile, ladspaH, liblo, libsigcxx, lrdf, wafHook
}:

stdenv.mkDerivation {
  pname = "non";
  version = "unstable-2021-01-28";
  src = fetchFromGitHub {
    owner = "stazed";
    repo = "non-mixer-xt";
    rev = "425ad8285d9c5d0f66c94ed03bdf9b184de5904e";
    hash = "sha256-2QHYYm8CKJf7k2kBVZzQlXCd1FfhD56Oe7YH90Va/lo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config wafHook ];
  buildInputs = [ python3 cairo libjpeg ntk libjack2 libsndfile
                  ladspaH liblo libsigcxx lrdf
                  lilv suil lv2 ladspa-sdk zix clap
  ];

  # NOTE: non provides its own waf script that is incompatible with new
  # python versions. If the script is not present, wafHook will install
  # a compatible version from nixpkgs.
  prePatch = ''
    rm waf
  '';

  env.CXXFLAGS = "-std=c++14 -DEnableNTK=ON";

  meta = {
    description = "Lightweight and lightning fast modular Digital Audio Workstation";
    homepage = "http://non.tuxfamily.org";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.nico202 ];
  };
}
