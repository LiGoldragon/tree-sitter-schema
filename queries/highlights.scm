; Comments and literals
(comment) @comment
(pipe_text) @string
(integer) @number

; Root structure
(source_file
  input: (root_enum) @module
  output: (root_enum) @module
  namespace: (namespace) @module)
(imports) @namespace
(relations) @namespace

; Declarations by object kind
(namespace_entry
  name: (name) @type.definition
  value: (struct_declaration))
(namespace_entry
  name: (name) @type.enum.definition
  value: (enum_declaration))
(namespace_entry
  name: (name) @type.stream.definition
  value: (stream_declaration))
(namespace_entry
  name: (name) @type.family.definition
  value: (family_declaration))
(namespace_entry
  name: (name) @type.alias.definition
  value: (plain_reference))
(namespace_entry
  name: (name) @type.alias.definition
  value: (vector_reference))
(namespace_entry
  name: (name) @type.alias.definition
  value: (optional_reference))
(namespace_entry
  name: (name) @type.alias.definition
  value: (scope_reference))
(namespace_entry
  name: (name) @type.alias.definition
  value: (map_reference))
(namespace_entry
  name: (name) @type.alias.definition
  value: (bytes_reference))

; Imports
(import_entry
  name: (name) @namespace.definition)

; Struct fields and derived inline markers
(field_declaration
  name: (name) @property.definition)
(derived_member) @type
(derived_marker) @operator

; Enum and root variants
(unit_variant
  name: (variant_name (name) @constructor))
(self_tagged_variant
  name: (variant_name (name) @constructor))
(data_variant
  name: (variant_name (name) @constructor))
(streaming_variant
  name: (variant_name (name) @constructor)
  relation: (stream_relation_keyword) @keyword.modifier
  stream: (variant_name (name) @type.stream))

; Metadata macros
(stream_keyword) @function.macro
(family_keyword) @function.macro
(stream_field_key) @property.builtin
(family_field_key) @property.builtin
(family_key) @constant.builtin

; Relations
(relation_keyword) @function.macro
(relation_path (name) @type)

; Macro-library schema source
(schema_macro_keyword) @function.macro
(schema_macro
  name: (name) @function.macro
  position: (name) @keyword)
(raw_parenthesized) @punctuation.special
(raw_vector) @punctuation.special
(raw_map) @punctuation.special

; Type-reference structural macros
(vector_keyword) @function.macro
(optional_keyword) @function.macro
(scope_keyword) @function.macro
(map_keyword) @function.macro
(bytes_keyword) @function.macro
(map_reference_pair) @punctuation.special

; Named references
(plain_reference name: (name) @type)
(table_name) @string.special

; Builtin scalar references override generic named references.
((plain_reference name: (name) @type.builtin)
  (#any-of? @type.builtin "String" "Integer" "Boolean" "Path"))

; Delimiters
"(" @punctuation.bracket
")" @punctuation.bracket
"[" @punctuation.bracket
"]" @punctuation.bracket
"{" @punctuation.bracket
"}" @punctuation.bracket
