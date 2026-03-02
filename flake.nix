{
  description = "Nix package for Morgen";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      supportedSystems = [ "x86_64-linux" ];
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "morgen" ];
        };
        morgen = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          inherit morgen;
          default = morgen;
        };

        apps = {
          morgen = {
            type = "app";
            program = "${morgen}/bin/morgen";
            meta = {
              description = "Run Morgen";
            };
          };
          default = {
            type = "app";
            program = "${morgen}/bin/morgen";
            meta = {
              description = "Run Morgen";
            };
          };
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bash
            pkgs.deadnix
            pkgs.just
            pkgs.nix
            pkgs.nixfmt
            pkgs.prek
            pkgs.ripgrep
            pkgs.shellcheck
            pkgs.statix
          ];
        };

        formatter = pkgs.nixfmt;
      }
    );
}
