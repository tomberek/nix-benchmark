#!/usr/bin/env bash

if [[ ! -v IN_BENCHMARK_SHELL ]]; then
    cd "${BASH_SOURCE[0]%/*}"
    exec nix develop -c bash benchmark.sh "$@"
fi

# A simple NixOS system
read -d '' sys1 <<EOF || :
(import "$nixpkgs/nixos" {
  configuration = { pkgs, lib, ... }: with lib; {
    services.xserver.enable = true;
  };
}).vm
EOF
export sys1

export parseArgs='nix=$1; expr=$2; shift; shift'
instantiateEval() {
    eval "$parseArgs"
    "$nix"/nix-instantiate --eval -E "($expr).outPath" "$@"
}
nixEval() {
    eval "$parseArgs"
    "$nix"/nix eval --experimental-features nix-command --impure --expr "($expr).outPath" "$@"
}
export -f instantiateEval nixEval

run_all() {
	vars=$( printf ",2_%s" $(seq 5 19) | tail -c+2 )
	hyperfine --warmup 2 \
		--export-json output.json \
		--parameter-list version "$vars" \
		'nixEval "$nix_{version}" "$sys1"'
	cat output.json | jq '.[][]|[.parameters.version,.min,.max,.mean,.stddev]|@tsv' -r | awk -v FS=$'\t' 'BEGIN{print "version","min","max","avg","stddev","color"}{print $0,NR}' | sed 's#2_#2.#' > plot.dat
}

"$@"
