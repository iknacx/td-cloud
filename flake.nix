{
  description = "Presentación";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "cloud";
      buildInputs = with pkgs; [
        zig zls valgrind python3
        nodejs
        nodejs.pkgs.pnpm
      ];
    };
  };
}
