{ nixpkgs ? import <nixpkgs> {}
, compiler ? "default"
}:
let
  # Can't use overlays as there is a infinite recursion in the list of
  # dependencies that needs to be fixed first.
  inherit (nixpkgs) pkgs;

  haskellPackages = if compiler == "default"
    then pkgs.haskellPackages
    else pkgs.haskell.packages.${compiler};

  waarg = import ./waargonaut-deps.nix;

  modifiedHaskellPackages = haskellPackages.override (old: {
    overrides = pkgs.lib.composeExtensions
      (old.overrides or (_: _: {}))
      (waarg pkgs);
  });

  drv = modifiedHaskellPackages.callPackage ./waargonaut.nix {};
in
  drv
