;;; schema-ts-mode.el --- Tree-sitter mode for SEMA schema -*- lexical-binding: t; -*-

;; Package-Requires: ((emacs "29.1"))

;;; Commentary:

;; Tree-sitter-backed major mode for authored SEMA .schema files.

;;; Code:

(require 'treesit)

(defgroup schema-ts nil
  "Tree-sitter support for SEMA schema files."
  :group 'languages)

(defface schema-ts-struct-face
  '((t :inherit font-lock-type-face :weight bold :foreground "#4EC9B0"))
  "Face for schema struct declarations."
  :group 'schema-ts)

(defface schema-ts-enum-face
  '((t :inherit font-lock-type-face :weight bold :foreground "#C586C0"))
  "Face for schema enum declarations."
  :group 'schema-ts)

(defface schema-ts-stream-face
  '((t :inherit font-lock-type-face :weight bold :foreground "#569CD6"))
  "Face for schema stream declarations."
  :group 'schema-ts)

(defface schema-ts-family-face
  '((t :inherit font-lock-type-face :weight bold :foreground "#DCDCAA"))
  "Face for schema family declarations."
  :group 'schema-ts)

(defcustom schema-ts-language-source
  '(schema "https://github.com/LiGoldragon/tree-sitter-schema")
  "Tree-sitter grammar source for SEMA schema."
  :type '(repeat sexp)
  :group 'schema-ts)

(defvar schema-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'schema
   :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'schema
   :feature 'literal
   '((pipe_text) @font-lock-string-face
     (integer) @font-lock-number-face
     (table_name) @font-lock-string-face)

   :language 'schema
   :feature 'declaration
   '((namespace_entry
      name: (name) @schema-ts-struct-face
      value: (struct_declaration))
     (namespace_entry
      name: (name) @schema-ts-enum-face
      value: (enum_declaration))
     (namespace_entry
      name: (name) @schema-ts-stream-face
      value: (stream_declaration))
     (namespace_entry
      name: (name) @schema-ts-family-face
      value: (family_declaration))
     (namespace_entry
      name: (name) @font-lock-type-face)
     (field_declaration
      name: (name) @font-lock-property-name-face))

   :language 'schema
   :feature 'variant
   '((unit_variant name: (variant_name (name) @font-lock-constant-face))
     (self_tagged_variant name: (variant_name (name) @font-lock-constant-face))
     (data_variant name: (variant_name (name) @font-lock-constant-face))
     (streaming_variant
      name: (variant_name (name) @font-lock-constant-face)
      relation: (stream_relation_keyword) @font-lock-keyword-face
      stream: (variant_name (name) @schema-ts-stream-face)))

   :language 'schema
   :feature 'macro
   '((stream_keyword) @font-lock-function-name-face
     (family_keyword) @font-lock-function-name-face
     (relation_keyword) @font-lock-function-name-face
     (vector_keyword) @font-lock-function-name-face
     (optional_keyword) @font-lock-function-name-face
     (scope_keyword) @font-lock-function-name-face
     (map_keyword) @font-lock-function-name-face
     (bytes_keyword) @font-lock-function-name-face
     (stream_field_key) @font-lock-property-name-face
     (family_field_key) @font-lock-property-name-face
     (family_key) @font-lock-builtin-face)

   :language 'schema
   :feature 'reference
   '(((plain_reference name: (name) @font-lock-builtin-face)
      (:match "^(String\\|Integer\\|Boolean\\|Path)$" @font-lock-builtin-face))
     (plain_reference name: (name) @font-lock-type-face))))

(defun schema-ts-mode-install-language-source ()
  "Register `schema' in `treesit-language-source-alist'."
  (interactive)
  (add-to-list 'treesit-language-source-alist schema-ts-language-source))

;;;###autoload
(define-derived-mode schema-ts-mode prog-mode "Schema"
  "Major mode for SEMA schema files."
  (unless (treesit-ready-p 'schema)
    (schema-ts-mode-install-language-source))
  (when (treesit-ready-p 'schema)
    (treesit-parser-create 'schema)
    (setq-local treesit-font-lock-settings schema-ts-mode--font-lock-settings)
    (setq-local treesit-font-lock-feature-list
                '((comment)
                  (literal reference)
                  (macro variant declaration)))
    (treesit-major-mode-setup)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.schema\\'" . schema-ts-mode))

(provide 'schema-ts-mode)

;;; schema-ts-mode.el ends here
