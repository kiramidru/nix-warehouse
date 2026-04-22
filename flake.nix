{
  description = "Nix Collection of Programs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        ./modules/blender
      ];

      perSystem =
        {
          pkgs,
          config,
          ...
        }:
        {
          formatter = pkgs.nixfmt-rfc-style;

          pre-commit.settings.hooks = {
            nixfmt-rfc-style.enable = true;
            deadnix.enable = true;
            statix.enable = true;
          };

          checks = {
            pre-commit-check = config.pre-commit.check;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixpkgs-fmt
              npins
            ];
          };
        };
    };
}
