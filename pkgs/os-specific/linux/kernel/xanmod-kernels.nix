{ lib, stdenv, fetchFromGitHub, buildLinux, ... } @ args:

let
  # These names are how they are designated in https://xanmod.org.

  # NOTE: When updating these, please also take a look at the changes done to
  # kernel config in the xanmod version commit
  ltsVariant = {
    version = "6.6.30";
    hash = "sha256-fQATjYekxV/+24mqyel3bYfgUMN4NhOHR9yyL6L5bl0=";
    variant = "lts";
  };

  mainVariant = {
    version = "6.8.9";
    hash = "sha256-OUlT/fiwLGTPnr/7gneyZBio/l8KAWopcJqTpSjBMl0=";
    variant = "main";
  };

  rtVariant = {
    version = "6.6.14";
    suffix = "rt21-xanmod1";
    hash = "sha256-k6Q5gHkWI9RvLhbPWfiH6in/TnKjiVGFPnbXV4kqIMo=";
    variant = "rt";
  };

  xanmodKernelFor = { version, suffix ? "xanmod1", hash, variant }: buildLinux (args // rec {
    inherit version;
    modDirVersion = lib.versions.pad 3 "${version}-${suffix}";

    src = fetchFromGitHub {
      owner = "xanmod";
      repo = "linux";
      rev = modDirVersion;
      inherit hash;
    };

    structuredExtraConfig = with lib.kernel; {
      # CPUFreq governor Performance
      CPU_FREQ_DEFAULT_GOV_PERFORMANCE = lib.mkOverride 60 yes;
      CPU_FREQ_DEFAULT_GOV_SCHEDUTIL = lib.mkOverride 60 no;

      # Full preemption
      PREEMPT = lib.mkOverride 60 yes;
      PREEMPT_VOLUNTARY = lib.mkOverride 60 no;

      # Google's BBRv3 TCP congestion Control
      TCP_CONG_BBR = yes;
      DEFAULT_BBR = yes;

      # WineSync driver for fast kernel-backed Wine
      WINESYNC = module;

    } // lib.optionalAttrs (variant == "main" || variant == "lts") {
      # Preemptive Full Tickless Kernel at 250Hz
      HZ = freeform "250";
      HZ_250 = yes;
      HZ_1000 = no;

    } // lib.optionalAttrs (variant == "rt") {
      # Preemptive Full Tickless Kernel at 250Hz
      HZ = freeform "1000";
      HZ_250 = no;
      HZ_1000 = yes;

      PREEMPT_RT = yes;
      PREEMPT_VOLUNTARY = yes;
    };

    extraMeta = {
      branch = lib.versions.majorMinor version;
      maintainers = with lib.maintainers; [ moni lovesegfault atemu shawn8901 zzzsy ];
      description = "Built with custom settings and new features built to provide a stable, responsive and smooth desktop experience";
      broken = stdenv.isAarch64;
    };
  } // (args.argsOverride or { }));
in
{
  lts = xanmodKernelFor ltsVariant;
  main = xanmodKernelFor mainVariant;
  rt = xanmodKernelFor rtVariant;
}
