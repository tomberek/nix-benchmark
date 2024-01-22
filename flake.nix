{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs_old.url = "github:NixOS/nixpkgs/release-22.05";

  outputs = { self, nixpkgs, nixpkgs_old }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgs_old = nixpkgs_old.legacyPackages.${system};

    shellEnvVars = {
      inherit nixpkgs;

      # nix_2_3 = "${pkgs.nixVersions.nix_2_3}/bin";
      nix_2_4 = "${pkgs_old.nixVersions.nix_2_4}/bin";
      nix_2_5 = "${pkgs_old.nixVersions.nix_2_5}/bin";
      nix_2_6 = "${pkgs_old.nixVersions.nix_2_6}/bin";
      nix_2_7 = "${pkgs_old.nixVersions.nix_2_7}/bin";
      nix_2_8 = "${pkgs_old.nixVersions.nix_2_8}/bin";
      nix_2_9 = "${pkgs_old.nixVersions.nix_2_9}/bin";
      nix_2_10 = "${pkgs.nixVersions.nix_2_10}/bin";
      nix_2_11 = "${pkgs.nixVersions.nix_2_11}/bin";
      nix_2_12 = "${pkgs.nixVersions.nix_2_12}/bin";
      nix_2_13 = "${pkgs.nixVersions.nix_2_13}/bin";
      nix_2_14 = "${pkgs.nixVersions.nix_2_14}/bin";
      nix_2_15 = "${pkgs.nixVersions.nix_2_15}/bin";
      nix_2_16 = "${pkgs.nixVersions.nix_2_16}/bin";
      nix_2_17 = "${pkgs.nixVersions.nix_2_17}/bin";
      nix_2_18 = "${pkgs.nixVersions.nix_2_18}/bin";
      nix_2_19 = "${pkgs.nixVersions.nix_2_19}/bin";

      IN_BENCHMARK_SHELL = true;
    };

    shellPkgs = with pkgs; [
      hyperfine
      bash
      coreutils
      strace
      gnuplot_qt
      gawk
    ];

    shellHook = ''
        . ./benchmark.sh
    '';
  in {
    devShell.${system} = derivation ({
      inherit system shellHook;
      name = "shell-env";
      outputs = [ "out" ];
      builder = pkgs.stdenv.shell;
      PATH = pkgs.lib.makeBinPath shellPkgs;
    } // shellEnvVars);
  };
}
