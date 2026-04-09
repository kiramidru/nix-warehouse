{
  description = "A free and open source 3D creation suite (upstream binaries)";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:

    let

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };

      mkBlender =
        {
          pname,
          version,
          src,
        }:
        with pkgs;

        let
          libs = [
            wayland
            libdecor
            libx11
            libxi
            libxxf86vm
            libxfixes
            libxrender
            libxkbcommon
            libGLU
            libglvnd
            numactl
            SDL2
            libdrm
            ocl-icd
            stdenv.cc.cc.lib
            openal
            alsa-lib
            pulseaudio
          ]
          ++ lib.optionals (lib.versionAtLeast version "3.5") [
            libsm
            libice
            zlib
          ]
          ++ lib.optionals (lib.versionAtLeast version "4.5") [ vulkan-loader ];
        in

        stdenv.mkDerivation {
          inherit pname version src;

          buildInputs = [ makeWrapper ];

          preUnpack = ''
            mkdir -p $out/libexec
            cd $out/libexec
          '';

          installPhase = ''
            cd $out/libexec
            mv blender-* blender

            mkdir -p $out/share/applications
            mkdir -p $out/share/icons/hicolor/scalable/apps
            mv ./blender/blender.desktop $out/share/applications/blender.desktop
            mv ./blender/blender.svg $out/share/icons/hicolor/scalable/apps/blender.svg

            mkdir $out/bin

            makeWrapper $out/libexec/blender/blender $out/bin/blender \
              --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${lib.makeLibraryPath libs}

            patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              blender/blender

            patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)"  \
              $out/libexec/blender/*/python/bin/python3*
          '';

          meta.mainProgram = "blender";
        };

      mkTest =
        { blender }:
        pkgs.runCommand "blender-test" { buildInputs = [ blender ]; } ''
          blender --version
          touch $out
        '';

    in
    {

      overlays.default = final: prev: {
        blender_2_82 = mkBlender {
          pname = "blender-bin";
          version = "2.82a";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.82/blender-2.82a-linux64.tar.xz";
            sha256 = "sha256-+0ACWBIlJcUaWJcZkZfnQBBJT3HyshIsTdEiMk5u3r4=";
          };
        };

        blender_2_83 = mkBlender {
          pname = "blender-bin";
          version = "2.83.20";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.83/blender-2.83.20-linux-x64.tar.xz";
            sha256 = "sha256-KuPyb39J+TUrcPUFuPNj0MtRshS4ZmHZTuTpxYjEFPg=";
          };
        };

        blender_2_90 = mkBlender {
          pname = "blender-bin";
          version = "2.90.1";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.90/blender-2.90.1-linux64.tar.xz";
            sha256 = "sha256-BUZoxGo+VpIfKDcJ9Ro194YHhhgwAc8uqb4ySdE6xmc=";
          };
        };

        blender_2_91 = mkBlender {
          pname = "blender-bin";
          version = "2.91.2";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.91/blender-2.91.2-linux64.tar.xz";
            sha256 = "sha256-jx4eiFJ1DhA4V5M2x0YcGlSS2pc84Yjh5crpmy95aiM=";
          };
        };

        blender_2_92 = mkBlender {
          pname = "blender-bin";
          version = "2.92.0";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.92/blender-2.92.0-linux64.tar.xz";
            sha256 = "sha256-LNF61unWwkGsFLhK1ucrUHruyXnaPZJrGhRuiODrPrQ=";
          };
        };

        blender_2_93 = mkBlender {
          pname = "blender-bin";
          version = "2.93.18";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.93/blender-2.93.18-linux-x64.tar.xz";
            sha256 = "sha256-+H9z8n0unluHbqpXr0SQIGf0wzHR4c30ACM6ZNocNns=";
          };
        };

        blender_3_0 = mkBlender {
          pname = "blender-bin";
          version = "3.0.1";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.0/blender-3.0.1-linux-x64.tar.xz";
            sha256 = "sha256-TxeqPRDtbhPmp1R58aUG9YmYuMAHgSoIhtklTJU+KuU=";
          };
        };

        blender_3_1 = mkBlender {
          pname = "blender-bin";
          version = "3.1.2";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.1/blender-3.1.2-linux-x64.tar.xz";
            sha256 = "sha256-wdNFslxvg3CLJoHTVNcKPmAjwEu3PMeUM2bAwZ5UKVg=";
          };
        };

        blender_3_2 = mkBlender {
          pname = "blender-bin";
          version = "3.2.2";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.2/blender-3.2.2-linux-x64.tar.xz";
            sha256 = "sha256-FyZWAVfZDPKqrrbSXe0Xg9Zr/wQ4FM2VuQ/Arx2eAYs=";
          };
        };

        blender_3_3 = mkBlender {
          pname = "blender-bin";
          version = "3.3.21";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.3/blender-3.3.21-linux-x64.tar.xz";
            sha256 = "sha256-KvaLcca7JOLT4ho+LbOax9c2tseEPASQie/qg8zx8Y0=";
          };
        };

        blender_3_4 = mkBlender {
          pname = "blender-bin";
          version = "3.4.1";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.4/blender-3.4.1-linux-x64.tar.xz";
            sha256 = "sha256-FJf4P5Ppu73nRUIseV7RD+FfkvViK0Qhdo8Un753aYE=";
          };
        };

        blender_3_5 = mkBlender {
          pname = "blender-bin";
          version = "3.5.1";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.5/blender-3.5.1-linux-x64.tar.xz";
            sha256 = "sha256-2Crn72DqsgsVSCbE8htyrgAerJNWRs0plMXUpRNvfxw=";
          };
        };

        blender_3_6 = mkBlender {
          pname = "blender-bin";
          version = "3.6.23";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.6/blender-3.6.23-linux-x64.tar.xz";
            sha256 = "sha256-DpoYr00AYLgl6WF+JKd191ng+fZyccBi89U6U5AwrwA=";
          };
        };

        blender_4_0 = mkBlender {
          pname = "blender-bin";
          version = "4.0.2";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.0/blender-4.0.2-linux-x64.tar.xz";
            sha256 = "sha256-VYOlWIc22ohYxSLvF//11zvlnEem/pGtKcbzJj4iCGo=";
          };
        };

        blender_4_1 = mkBlender {
          pname = "blender-bin";
          version = "4.1.1";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.1/blender-4.1.1-linux-x64.tar.xz";
            sha256 = "sha256-qy6j/pkWAaXmvSzaeG7KqRnAs54FUOWZeLXUAnDCYNM=";
          };
        };

        blender_4_2 = mkBlender {
          pname = "blender-bin";
          version = "4.2.15";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.2/blender-4.2.15-linux-x64.tar.xz";
            sha256 = "sha256-udzB0GhhUpd55/r42Cyd01Y0Q9+x6xQhJCTIxAt3B04=";
          };
        };

        blender_4_3 = mkBlender {
          pname = "blender-bin";
          version = "4.3.2";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.3/blender-4.3.2-linux-x64.tar.xz";
            sha256 = "sha256-TaHJVmc8BIXmMFTlY+5pGYzI+A2BV911kt/8impVkuY=";
          };
        };

        blender_4_4 = mkBlender {
          pname = "blender-bin";
          version = "4.4.3";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.4/blender-4.4.3-linux-x64.tar.xz";
            sha256 = "sha256-jTvgfSvEErUCxr/jz+PiIZWkFkB2hn2ph84UjXPCeUY=";
          };
        };

        blender_4_5 = mkBlender {
          pname = "blender-bin";
          version = "4.5.4";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.5/blender-4.5.4-linux-x64.tar.xz";
            sha256 = "sha256-Lm746Z/DYycnBCndyOe60oWd2HiloTfS4L8PAvZ5JQU=";
          };
        };

        blender_5_0 = mkBlender {
          pname = "blender-bin";
          version = "5.0.1";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender5.0/blender-5.0.1-linux-x64.tar.xz";
            sha256 = "sha256-gBlYDuG3Ji5QX0GWoAI3zPdDyI0gWzjTQgFRBnbmCwk=";
          };
        };
        blender_5_1 = mkBlender {
          pname = "blender-bin";
          version = "5.1.0";
          src = builtins.fetchurl {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender5.1/blender-5.1.0-linux-x64.tar.xz";
            sha256 = "sha256-fyR1mQYTyNTHrFaXgD/PQNCVQcH9jCOTb0sHoWmpIMc=";
          };
        };
      };

      lib.mkBlender = mkBlender;

      packages.x86_64-linux = rec {
        inherit (pkgs)
          blender_2_82
          blender_2_83
          blender_2_90
          blender_2_91
          blender_2_92
          blender_2_93
          blender_3_0
          blender_3_1
          blender_3_2
          blender_3_3
          blender_3_4
          blender_3_5
          blender_3_6
          blender_4_0
          blender_4_1
          blender_4_2
          blender_4_3
          blender_4_4
          blender_4_5
          blender_5_0
          blender_5_1
          ;
        default = blender_5_1;
      };

      checks.x86_64-linux = {
        blender_2_82 = mkTest { blender = self.packages.x86_64-linux.blender_2_82; };
        blender_2_83 = mkTest { blender = self.packages.x86_64-linux.blender_2_83; };
        blender_2_90 = mkTest { blender = self.packages.x86_64-linux.blender_2_90; };
        blender_2_91 = mkTest { blender = self.packages.x86_64-linux.blender_2_91; };
        blender_2_92 = mkTest { blender = self.packages.x86_64-linux.blender_2_92; };
        blender_2_93 = mkTest { blender = self.packages.x86_64-linux.blender_2_93; };
        blender_3_0 = mkTest { blender = self.packages.x86_64-linux.blender_3_0; };
        blender_3_1 = mkTest { blender = self.packages.x86_64-linux.blender_3_1; };
        blender_3_2 = mkTest { blender = self.packages.x86_64-linux.blender_3_2; };
        blender_3_3 = mkTest { blender = self.packages.x86_64-linux.blender_3_3; };
        blender_3_4 = mkTest { blender = self.packages.x86_64-linux.blender_3_4; };
        blender_3_5 = mkTest { blender = self.packages.x86_64-linux.blender_3_5; };
        blender_3_6 = mkTest { blender = self.packages.x86_64-linux.blender_3_6; };
        blender_4_0 = mkTest { blender = self.packages.x86_64-linux.blender_4_0; };
        blender_4_1 = mkTest { blender = self.packages.x86_64-linux.blender_4_1; };
        blender_4_2 = mkTest { blender = self.packages.x86_64-linux.blender_4_2; };
        blender_4_3 = mkTest { blender = self.packages.x86_64-linux.blender_4_3; };
        blender_4_4 = mkTest { blender = self.packages.x86_64-linux.blender_4_4; };
        blender_4_5 = mkTest { blender = self.packages.x86_64-linux.blender_4_5; };
        blender_5_0 = mkTest { blender = self.packages.x86_64-linux.blender_5_0; };
        blender_5_1 = mkTest { blender = self.packages.x86_64-linux.blender_5_1; };
      };

    };
}
