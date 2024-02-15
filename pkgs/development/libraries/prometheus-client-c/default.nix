{ lib, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, libmicrohttpd
}:
let
  build =
    { pname
    , subdir
    , buildInputs ? [ ]
    , description
    }:
    stdenv.mkDerivation rec {
      inherit pname;
      version = "0.1.3";

      src = fetchFromGitHub {
        owner = "digitalocean";
        repo = "prometheus-client-c";
        rev = "v${version}";
        hash = "sha256-ThdtiDFstvWbz5VML+jPwFl/kfN3gcniY9TtbcGzW28=";
      };

      nativeBuildInputs = [ cmake ];
      inherit buildInputs;

      # Workaround build failure on -fno-common toolchains like upstream
      # gcc-10. Otherwise build fails as:
      #   ld: CMakeFiles/prom.dir/src/prom_process_stat.c.o:(.bss+0x0): multiple definition of
      #     `prom_process_start_time_seconds'; CMakeFiles/prom.dir/src/prom_collector.c.o:(.bss+0x0): first defined here
      # Should be fixed in 1.2.0 and later: https://github.com/digitalocean/prometheus-client-c/pull/25
      #env.NIX_CFLAGS_COMPILE = "-fcommon";

      preConfigure = ''
        cd ${subdir}
      '';

      meta = {
        homepage = "https://github.com/digitalocean/prometheus-client-c/";
        inherit description;
        platforms = lib.platforms.unix;
        license = lib.licenses.asl20;
        maintainers = [ lib.maintainers.cfsmp3 ];
      };
    };
in
rec {
  libprom = build {
    pname = "libprom";
    subdir = "prom";
    description = "A Prometheus Client in C";
  };
  libpromhttp = build {
    pname = "libpromhttp";
    subdir = "promhttp";
    buildInputs = [ libmicrohttpd libprom ];
    description = "A Prometheus HTTP Endpoint in C";
  };
}
