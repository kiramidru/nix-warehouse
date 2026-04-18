{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "celeste";
      version = "1.4.0";

      libs = with pkgs; [
        libGL
        openal
        SDL2
        zlib
        libx11
        libxcursor
        libxext
        libxinerama
        libxrandr
        libxi
        libpulseaudio
        mono
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "Celeste";
        exec = "celeste";
        icon = "celeste";
        comment = "A story driven platformer";
        desktopName = "Celeste";
        genericName = "Celeste";
        categories = [ "Game" ];
      };
    in
    {
      packages = {
        celeste = pkgs.stdenv.mkDerivation {
          inherit pname version;

          src = pkgs.fetchurl {
            url = "https://archive.org/download/celeste-game-linux/game-Celeste_%28v1.4.0.0%29_%5BLinux%5D.tar.xz";
            sha256 = "sha256-O9LgGD8ek1sKcj9oKsdolktm+AYJblsYlqfav0plxuw=";
          };

          nativeBuildInputs = with pkgs; [
            makeWrapper
            autoPatchelfHook
          ];

          buildInputs = libs;

          desktopItems = [ desktopItem ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/opt/celeste
            mkdir -p $out/bin
            cp -rv . $out/opt/celeste/

            LIB_DIR="$out/opt/celeste/lib64"

            chmod +x $out/opt/celeste/Celeste.exe
            find $LIB_DIR -name "*.so*" -exec chmod +x {} +
            find $LIB_DIR -name "*.so*" -exec patchelf --set-rpath "${lib.makeLibraryPath libs}:$LIB_DIR" {} \;

            makeWrapper "${pkgs.mono}/bin/mono" $out/bin/celeste \
              --add-flags "$out/opt/celeste/Celeste.exe" \
              --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libs}:$LIB_DIR" \
              --prefix LD_PRELOAD : "$LIB_DIR/libfmod.so.10:$LIB_DIR/libfmodstudio.so.10" \
              --set SDL_VIDEODRIVER x11 \
              --chdir "$out/opt/celeste"

            runHook postInstall
          '';

          meta.mainProgram = "celeste";
        };
      };
    };
}
