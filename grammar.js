/**
 * @file Tree-sitter grammar for authored SEMA schema files.
 * @license MIT
 */
/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

const nameCharacters = /[A-Za-z_][A-Za-z0-9_:\-]*/;
const atomCharacters = /[^()\[\]{}\s]+/;

module.exports = grammar({
  name: "schema",

  conflicts: $ => [
    [$.import_entry, $.raw_object],
  ],

  extras: $ => [
    /[\s\uFEFF\u2060\u200B]/,
    $.comment,
  ],

  word: $ => $.name,

  rules: {
    source_file: $ => choice(
      $._authored_schema,
      $.macro_library,
      $.raw_core_schema,
    ),

    _authored_schema: $ => seq(
      optional(field("imports", $.imports)),
      field("input", $.root_enum),
      field("output", $.root_enum),
      field("namespace", $.namespace),
      optional(field("relations", $.relations)),
    ),

    imports: $ => seq("{", repeat($.import_entry), "}"),
    import_entry: $ => seq(
      field("name", $.name),
      field("source", $._reference),
    ),

    root_enum: $ => seq("[", repeat($.variant_signature), "]"),

    namespace: $ => seq("{", repeat($.namespace_entry), "}"),
    namespace_entry: $ => seq(
      field("name", $.name),
      field("value", $._declaration_value),
    ),

    _declaration_value: $ => choice(
      $.stream_declaration,
      $.family_declaration,
      $.struct_declaration,
      $.enum_declaration,
      $.pipe_text,
      $._reference,
    ),

    struct_declaration: $ => seq("{", repeat(choice($.field_declaration, $.derived_member)), "}"),
    field_declaration: $ => prec(1, seq(
      field("name", $.name),
      field("value", choice(
        $.derived_marker,
        $._reference,
        $.struct_declaration,
        $.enum_declaration,
        $.pipe_text,
      )),
    )),
    derived_member: $ => $._reference,
    derived_marker: $ => "*",

    enum_declaration: $ => seq("[", repeat($.variant_signature), "]"),

    variant_signature: $ => choice(
      $.streaming_variant,
      $.data_variant,
      $.self_tagged_variant,
      $.unit_variant,
    ),
    unit_variant: $ => field("name", $.variant_name),
    self_tagged_variant: $ => seq(
      "(",
      field("name", $.variant_name),
      ")",
    ),
    data_variant: $ => seq(
      "(",
      field("name", $.variant_name),
      field("payload", $.variant_payload),
      ")",
    ),
    streaming_variant: $ => seq(
      "(",
      field("name", $.variant_name),
      field("payload", $.variant_payload),
      field("relation", $.stream_relation_keyword),
      field("stream", $.variant_name),
      ")",
    ),
    variant_payload: $ => choice(
      $.struct_declaration,
      $.enum_declaration,
      $.pipe_text,
      $._reference,
    ),
    stream_relation_keyword: $ => choice("opens", "belongs"),

    stream_declaration: $ => seq(
      "(",
      field("head", $.stream_keyword),
      field("body", $.stream_body),
      ")",
    ),
    stream_keyword: $ => "Stream",
    stream_body: $ => seq("{", repeat($.stream_field), "}"),
    stream_field: $ => seq(
      field("key", $.stream_field_key),
      field("value", $._reference),
    ),
    stream_field_key: $ => choice("token", "opened", "event", "close"),

    family_declaration: $ => seq(
      "(",
      field("head", $.family_keyword),
      field("body", $.family_body),
      ")",
    ),
    family_keyword: $ => "Family",
    family_body: $ => seq("{", repeat($.family_field), "}"),
    family_field: $ => seq(
      field("key", $.family_field_key),
      field("value", choice($.family_key, $.table_name, $._reference)),
    ),
    family_field_key: $ => choice("record", "table", "key"),
    family_key: $ => token(prec(5, choice("Domain", "Identified"))),
    table_name: $ => token(prec(2, /[a-z][A-Za-z0-9_\-]*/)),

    relations: $ => seq("[", repeat($.relation), "]"),
    relation: $ => seq(
      "(",
      field("name", $.relation_keyword),
      field("values", $.relation_values),
      ")",
    ),
    relation_keyword: $ => "Equivalence",
    relation_values: $ => seq("[", repeat($.relation_value), "]"),
    relation_value: $ => choice($.relation_path, $.name),
    relation_path: $ => seq("(", repeat1($.name), ")"),

    macro_library: $ => repeat1($.schema_macro),
    schema_macro: $ => seq(
      "(",
      field("head", $.schema_macro_keyword),
      field("name", $.name),
      field("position", $.name),
      field("pattern", $.raw_object),
      field("template", $.raw_object),
      ")",
    ),
    schema_macro_keyword: $ => "SchemaMacro",

    raw_core_schema: $ => $.raw_map,
    raw_object: $ => choice(
      $.raw_parenthesized,
      $.raw_vector,
      $.raw_map,
      $.pipe_text,
      $.integer,
      $.name,
      $.atom,
    ),
    raw_parenthesized: $ => seq("(", repeat($.raw_object), ")"),
    raw_vector: $ => seq("[", repeat($.raw_object), "]"),
    raw_map: $ => seq("{", repeat($.raw_object), "}"),

    _reference: $ => choice(
      $.vector_reference,
      $.optional_reference,
      $.scope_reference,
      $.map_reference,
      $.bytes_reference,
      $.plain_reference,
    ),
    plain_reference: $ => field("name", $.name),
    vector_reference: $ => seq(
      "(",
      field("head", $.vector_keyword),
      field("item", $._reference),
      ")",
    ),
    vector_keyword: $ => choice("Vec", "Vector"),
    optional_reference: $ => seq(
      "(",
      field("head", $.optional_keyword),
      field("item", $._reference),
      ")",
    ),
    optional_keyword: $ => choice("Optional", "Option"),
    scope_reference: $ => seq(
      "(",
      field("head", $.scope_keyword),
      field("item", $._reference),
      ")",
    ),
    scope_keyword: $ => choice("ScopeOf", "Scope"),
    map_reference: $ => seq(
      "(",
      field("head", $.map_keyword),
      field("pair", $.map_reference_pair),
      ")",
    ),
    map_keyword: $ => choice("Map", "KeyValue"),
    map_reference_pair: $ => seq(
      "(",
      field("key", $._reference),
      field("value", $._reference),
      ")",
    ),
    bytes_reference: $ => seq(
      "(",
      field("head", $.bytes_keyword),
      field("width", $.integer),
      ")",
    ),
    bytes_keyword: $ => "Bytes",

    variant_name: $ => $.name,
    name: $ => token(prec(1, nameCharacters)),

    pipe_text: $ => token(seq(
      "[|",
      repeat(choice(
        /[^\\|]/,
        /\\./,
        /\|[^\]]/,
      )),
      "|]",
    )),

    integer: $ => token(prec(4, /[0-9]+/)),
    atom: $ => token(prec(0, atomCharacters)),
    comment: $ => token(seq(";;", /[^\n]*/)),
  },
});
