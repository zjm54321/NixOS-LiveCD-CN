{
  description = "zjm54321 的 NixOS Live-CD 环境配置";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    {
      packages.x86_64-linux.default = self.nixosConfigurations.exampleIso.config.system.build.isoImage;
      nixosConfigurations = {
        exampleIso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./iso.nix
          ];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt-rfc-style
            nil
          ];
        };
      }
    );
}
