{
  description = "tree-sitter-schema — SEMA schema grammar, WASM parser, and editor checks";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forSystems = function:
        nixpkgs.lib.genAttrs systems (system:
          function {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
          });
    in
    {
      packages = forSystems ({ pkgs, ... }:
        let
          wasiCompiler = pkgs.pkgsCross.wasi32.stdenv.cc;
          wasiSdk = pkgs.runCommand "tree-sitter-schema-wasi-sdk" {
            nativeBuildInputs = [ pkgs.makeWrapper ];
          } ''
            mkdir -p "$out/bin"
            makeWrapper ${wasiCompiler}/bin/wasm32-unknown-wasi-clang \
              "$out/bin/wasm32-unknown-wasi-clang" \
              --prefix PATH : ${pkgs.lib.makeBinPath [ wasiCompiler pkgs.llvmPackages.lld ]}
            ln -s ${pkgs.llvmPackages.lld}/bin/wasm-ld "$out/bin/wasm-ld"
          '';
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "tree-sitter-schema";
            version = "0.1.0";
            src = ./.;

            nativeBuildInputs = [
              pkgs.coreutils
              pkgs.emacs
              pkgs.file
              pkgs.findutils
              pkgs.gnugrep
              pkgs.nodejs
              pkgs.tree-sitter
            ];

            buildPhase = ''
              runHook preBuild
              export HOME="$TMPDIR"
              export TREE_SITTER_WASI_SDK_PATH="${wasiSdk}"
              tree-sitter generate
              tree-sitter test
              find test/fixtures -name '*.schema' -print0 \
                | xargs -0 -n1 tree-sitter parse --quiet \
                > "$TMPDIR/schema-fixture-parse.log" 2>&1
              if grep -E 'ERROR|MISSING' "$TMPDIR/schema-fixture-parse.log"; then
                cat "$TMPDIR/schema-fixture-parse.log"
                exit 1
              fi
              emacs --batch -Q -L editors/emacs \
                -f batch-byte-compile editors/emacs/schema-ts-mode.el
              rm -f editors/emacs/*.elc
              tree-sitter build --wasm -o tree-sitter-schema.wasm
              file tree-sitter-schema.wasm | grep WebAssembly
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p "$out"
              cp -R grammar.js package.json README.md LICENSE tree-sitter.json \
                src queries editors test tree-sitter-schema.wasm "$out/"
              runHook postInstall
            '';
          };
        });

      checks = forSystems ({ pkgs, system, ... }: {
        default = self.packages.${system}.default;
      });

      devShells = forSystems ({ pkgs, ... }: {
        default = pkgs.mkShell {
          packages = [
            pkgs.emacs
            pkgs.nodejs
            pkgs.tree-sitter
          ];
        };
      });
    };
}
