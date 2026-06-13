# tree-sitter-schema

Tree-sitter grammar and editor highlighting support for authored SEMA
`.schema` files.

This grammar is structural-macro-aware: it parses schema positions and names
the typed macro forms that schema-next currently lowers from NOTA:

- root input and output enum vectors
- namespace struct, enum, alias, stream, and family declarations
- enum variant signatures, including `opens` and `belongs` stream relations
- type reference macros: `Vec`, `Vector`, `Optional`, `Option`, `ScopeOf`,
  `Scope`, `Map`, `KeyValue`, and `Bytes`
- relation blocks such as `Equivalence`

## Local Checks

```sh
nix shell nixpkgs#nodejs --command tree-sitter generate
tree-sitter test
tree-sitter highlight test/highlight/advanced.schema
```

The parser also accepts schema-next's raw-core single-map files and
`SchemaMacro` library source so existing `.schema` files do not render as a
wall of errors while edited.

On NixOS, `tree-sitter build --wasm` may fail if the CLI downloads a generic
Linux wasi-sdk. The VSCodium settings expect `tree-sitter-schema.wasm`, which
can be built on a host where the tree-sitter WASM toolchain runs:

```sh
tree-sitter build --wasm -o tree-sitter-schema.wasm
```

## Editor Support

- `queries/highlights.scm`, `queries/locals.scm`, and `queries/folds.scm` are
  the canonical tree-sitter query files.
- `editors/emacs/schema-ts-mode.el` provides an Emacs 29+ tree-sitter major
  mode with differentiated faces for schema object kinds.
- `editors/vscodium/` contains a VSCodium language-registration extension and
  `tree-sitter-vscode` settings for semantic-token highlighting.
