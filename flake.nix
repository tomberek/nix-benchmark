{
  # unstable (2022-03-17)
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/3eb07eeafb52bcbf02ce800f032f18d666a9498d";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    shellEnvVars = {
      inherit nixpkgs;

      nix_2_3 = "${pkgs.nix_2_3}/bin";
      nix_2_7 = "${pkgs.nix}/bin";

      IN_BENCHMARK_SHELL = true;
    };

    shellPkgs = with pkgs; [
      hyperfine
      bash
      coreutils
      strace
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
