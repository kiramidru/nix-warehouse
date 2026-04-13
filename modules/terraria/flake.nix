{
  description = "Terraria (GOG Linux) - NixOS Native Wrapper";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      libs = with pkgs; [
        stdenv.cc.cc.lib
        libGL
        libglvnd
        libx11
        libxi
        libxcursor
        libxrandr
        alsa-lib
        libpulseaudio
        udev
        libusb1
        openal
        SDL2
        zlib
      ];
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation rec {
        pname = "terraria";
        version = "1.4.5.6";

        src = pkgs.fetchurl {
          url = "https://archive.org/download/terraria-linux-gog/terraria_v1_4_5_6_89299.sh";
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };

        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.autoPatchelfHook
          pkgs.unzip
        ];
        buildInputs = libs;

        unpackCmd = "unzip -q $src -d source || true";

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/terraria
          cp -r data/noarch/game/* $out/opt/terraria/

          mkdir -p $out/bin
          makeWrapper $out/opt/terraria/Terraria.bin.x86_64 $out/bin/terraria \
            --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${pkgs.lib.makeLibraryPath libs} \
            --set TERM xterm

          runHook postInstall
        '';

        meta.mainProgram = "terraria";
      };
    };
}
