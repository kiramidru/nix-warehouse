{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "balatro";
      version = "1.0";

      deps = with pkgs; [
        stdenv.cc.cc.lib
        love
        luajit
        SDL2
        libGL
        openal
        libmodplug
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "balatro";
        desktopName = "Balatro";
        exec = "balatro";
        icon = "balatro";
        terminal = false;
        categories = [
          "Game"
        ];
      };
    in
    {
      packages.${pname} = pkgs.stdenv.mkDerivation {
        inherit pname version;

        src = pkgs.fetchurl {
          url = "https://archive.org/download/balatro-linux-love-linuxrulez/Balatro%20%28v.1.0.1o%29%20%2B%20Support%20for%20Mods%20and%20ARM%20added%20%5BLOVE%5D%20%5BLinuxRuleZ%21%5D.sh";
          hash = "sha256-uLUB5vL6lnVLUe3ecOvwUnCVcDsddDFdWEsjpRR8bZQ=";
        };

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          makeWrapper
          p7zip
          copyDesktopItems
        ];

        buildInputs = deps;

        desktopItems = [ desktopItem ];

        unpackPhase = ''
          7z x $src -osource_temp
          PAYLOAD=$(find source_temp -type f | head -n 1)
          7z x "$PAYLOAD" -osource
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/${pname} $out/bin
          cp -r source/Balatro/game/* $out/opt/${pname}

          makeWrapper ${pkgs.love}/bin/love $out/bin/${pname} \
            --add-flags "$out/opt/${pname}/balatro.love" \
            --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps}

          runHook postInstall
        '';

        dontStrip = true;
      };
    };
}
