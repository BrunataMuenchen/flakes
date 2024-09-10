{
  description = "A basic C project setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
  };

  outputs =
    { self, flake-utils, devshell, nixpkgs, treefmt-nix, ... }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlays.default ];
        };
        callPackage =
          pkgs.darwin.apple_sdk_11_0.callPackage or pkgs.callPackage;
        treefmtEval = treefmt-nix.lib.evalModule pkgs (pkgs: {
          projectRootFile = "flake.nix";
          settings.global.excludes = [ "./extern/**" ];

          programs.nixfmt.enable = true;
        });
      in {
        formatter = treefmtEval.config.build.wrapper;
        devShells.default = pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
        };
        # This could be your package!
        # packages.default = pkgs.callPackage ./default.nix {};
      }));
}