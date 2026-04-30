{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "duck-detective";
      version = "2.3.9";

      deps = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        wayland
        libdecor
        dbus
        pango
        cairo
        gdk-pixbuf
        glib
        udev
        libGL
        libx11
        libxext
        libxrandr
        libpulseaudio
        libxkbcommon
        libXcursor
        libXinerama
        libXi
        udev
      ];
    in
    {
      packages.${pname} = pkgs.stdenv.mkDerivation {
        inherit pname version;

        src = pkgs.fetchurl {
          url = "https://archive.org/download/duck-detective-the-ghost-of-glamping-gog-linux/duck_detective_the_ghost_of_glamping_2_3_9_85667.sh";
          hash = "sha256-/xJe3ZZQMigbzz5vfl0Ey7aq33yuG3oyUG4yo9ZpqS8=";
        };

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          makeWrapper
          unzip
        ];

        buildInputs = deps;

        unpackPhase = "unzip -q $src -d source || true";

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/${pname} $out/bin
          cp -r source/data/noarch/game/* $out/opt/${pname}

          makeWrapper "$out/opt/${pname}/Duck Detective - The Ghost of Glamping" $out/bin/${pname} \
            --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps}

          runHook postInstall
        '';

        dontStrip = true;
      };
    };
}
