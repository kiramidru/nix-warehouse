{
  description = "Super Smash Bros. Melee - Hardcoded Direct Launch";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      melee-iso = pkgs.fetchurl {
        url = "https://archive.org/download/super-smash-bros.-melee-usa-en-ja-v-1.02/Super%20Smash%20Bros.%20Melee%20%28USA%29%20%28En%2CJa%29%20%28v1.02%29.iso";
        sha256 = "0r30fq8idh066j7882k5hpzi92gh31iz5xcr53vl7lxxj6dbb1f0";
      };

      libs = with pkgs; [
        libX11
        libXcomposite
        libXcursor
        libXdamage
        libXext
        libXfixes
        libXi
        libXrandr
        libxkbcommon
        libGL
        libglvnd
        alsa-lib
        libpulseaudio
        udev
        libusb1

        nss
        nspr
        atk
        dbus
        expat
        pango
        cairo
        fontconfig

        stdenv.cc.cc.lib
        zlib
      ];
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation rec {
        pname = "melee";
        version = "3.5.2";

        src = pkgs.fetchurl {
          url = "https://github.com/project-slippi/Ishiiruka/releases/download/v${version}/Slippi_Online-x86_64.AppImage";
          sha256 = "sha256-wIW1mpG900P3KJn18mMY8IkU/4VlCoSONAbAFhF2YGQ=";
        };

        nativeBuildInputs = with pkgs; [
          makeWrapper
          autoPatchelfHook
        ];

        buildInputs = libs;

        unpackPhase = ''
          appimage-contents $src
          mv squashfs-root source
          cd source
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/melee
          cp -r . $out/opt/melee

          mkdir -p $out/bin
          makeWrapper $out/opt/melee/AppRun $out/bin/melee \
            --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${pkgs.lib.makeLibraryPath libs} \
            --set QT_QPA_PLATFORM x11 \
            --add-flags "-b" \
            --add-flags "-e ${melee-iso}" \
            --add-flags "--fullscreen"

          runHook postInstall
        '';

        appendRunpaths = [ "${pkgs.lib.makeLibraryPath libs}" ];

        meta.mainProgram = "melee";
      };
    };
}
