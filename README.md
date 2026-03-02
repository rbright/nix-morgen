# nix-morgen

[![CI](https://github.com/rbright/nix-morgen/actions/workflows/ci.yml/badge.svg)](https://github.com/rbright/nix-morgen/actions/workflows/ci.yml)

Nix package for [Morgen](https://morgen.so/).

## What this repo provides

- Nix package: `morgen` (binary: `morgen`)
- Nix app output: `.#morgen`
- Packaging for the latest upstream v4 Linux `.deb`
- Desktop entry for launchers like Walker/Vicinae
- Local quality gate (`just`) and GitHub Actions CI

## Upstream source pin

Current source URL:

- `https://dl.todesktop.com/210203cqcj00tw1/builds/260126rpo7mcydr/linux/deb/x64`

## Quickstart

```sh
# list commands
just --list

# full local validation gate
just check

# build
just build
```

## Build and run directly with Nix

```sh
nix build -L 'path:.#morgen'
nix run 'path:.#morgen'
```

## Notes

- License: proprietary/unfree. You must comply with Morgen's terms.
- Platform: `x86_64-linux`.

## Use from another flake

```nix
{
  inputs.nixMorgen.url = "github:rbright/nix-morgen";

  outputs = { self, nixpkgs, nixMorgen, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            nixMorgen.packages.${pkgs.system}.morgen
          ];
        })
      ];
    };
  };
}
```
