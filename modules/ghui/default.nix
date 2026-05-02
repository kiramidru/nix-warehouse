{ inputs, ... }:

{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      pname = "ghui";
      version = "2.3.9";
      builder = inputs.bun2nix.packages.${system}.default;
      src = pkgs.fetchFromGitHub {
        owner = "kitlangton";
        repo = "ghui";
        rev = "v${version}";
        hash = "sha256-8xfP7qNFge7XFiLeEdoPYLGNShO5ECyDT3hN/n2ZUzs=";
      };
    in
    {
      packages.${pname} = builder.mkDerivation {
        inherit pname version src;

        nativeBuildInputs = [ pkgs.makeWrapper ];

        bunDeps = builder.fetchBunDeps {
          bunNix = ./bun.nix;
          src = src;
        };

        bunBuildFlags = [
          "src/index.tsx"
          "--outfile"
          pname
          "--compile"
          "--minify"
          "--sourcemap"
          "--bytecode"
          "--target"
          "bun"
          "--format"
          "esm"
        ];

        postInstall = ''
          wrapProgram $out/bin/${pname} \
            --prefix PATH : ${
              pkgs.lib.makeBinPath [
                pkgs.gh
                pkgs.git
              ]
            }
        '';
      };
    };
}
