{
  description = "ZMK firmware for the Lily58 (nice!nano v2 + nice!oled)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      # Builds both halves: result/zmk_left.uf2 and result/zmk_right.uf2
      # Mirrors build.yaml; west dependencies come from config/west.yml.
      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "lily58-firmware";

        src = nixpkgs.lib.sourceFilesBySuffices self [ ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" ];

        board = "nice_nano_v2";
        shield = "lily58_%PART% nice_oled";

        # Refresh with `nix run .#update` after changing config/west.yml
        zephyrDepsHash = "sha256-8Jb0zlRKgJd2LQge/MN2UiHu2HGWvn6TUq90xCZhm/A=";

        meta = {
          description = "ZMK firmware for the Lily58";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
