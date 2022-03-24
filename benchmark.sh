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

read -d '' drv1 <<EOF || :
with import <nixpkgs> { config = {}; };
writeText "txt" "a"
EOF

export sys1 drv1

export parseArgs='nix=$1; expr=$2; shift; shift'
oldBuild() {
    eval "$parseArgs"
    "$nix"/nix-build --no-out-link -E "$expr" "$@"
}
newBuild() {
    eval "$parseArgs"
    "$nix"/nix build --experimental-features nix-command --impure --expr "$expr" --no-link "$@"
}
instantiateEval() {
    eval "$parseArgs"
    "$nix"/nix-instantiate --eval -E "($expr).outPath" "$@"
}
nixEval() {
    eval "$parseArgs"
    "$nix"/nix eval --experimental-features nix-command --impure --expr "($expr).outPath" "$@"
}
instantiate() {
    eval "$parseArgs"
    "$nix"/nix-instantiate -E "$expr" "$@"
}
export -f instantiateEval nixEval oldBuild newBuild instantiate

benchmark() {
    hyperfine --warmup 2 --min-runs 3 "$@"
    echo
}
benchmarkn() {
    runs=$1
    shift
    hyperfine --warmup 2 --min-runs $runs "$@"
    echo
}

#--------------------------------------------------

daemon_store_vs_local_store() {
    export localStore=/tmp/nix-benchmark-store
    clearStore() { chmod -R +w $localStore 2>/dev/null; rm -rf $localStore; }
    clearStore
    benchmark \
        'instantiateEval $nix_2_7 "$sys1"' \
        'instantiate $nix_2_7 "$sys1"' \
        'instantiate $nix_2_7 "$sys1" --store $localStore'
    clearStore
}
# 'instantiateEval $nix_2_7 "$sys1"' ran
#   1.16 ± 0.03 times faster than 'instantiate $nix_2_7 "$sys1" --store $localStore'
#   1.51 ± 0.08 times faster than 'instantiate $nix_2_7 "$sys1"'

instantiate_eval_2_3_vs_2_7() {
    benchmark \
        'instantiateEval $nix_2_3 "$sys1"' \
        'instantiateEval $nix_2_7 "$sys1"'
}
# 'instantiateEval $nix_2_7 "$sys1"' ran
#   1.14 ± 0.04 times faster than 'instantiateEval $nix_2_3 "$sys1"'

instantiate_2_3_vs_2_7() {
    benchmark \
        'instantiate $nix_2_3 "$sys1"' \
        'instantiate $nix_2_7 "$sys1"'
}
# 'instantiate $nix_2_3 "$sys1"' ran
#   1.02 ± 0.02 times faster than 'instantiate $nix_2_7 "$sys1"'

run() {
    echo "$@"
    echo "----------------------------------"
    "$@"
    echo
}

run_all() {
    # run daemon_store_vs_local_store
    run instantiate_eval_2_3_vs_2_7
    run instantiate_2_3_vs_2_7
}

# Run args
"$@"
