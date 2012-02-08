;;; konoha-mode.el --- Major mode to edit konohascript language files in Emacs

;; Copyright (C) 2011, 2012 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL: https://github.com/syohex/emacs-quickrun
;; Version: 0.4

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; konoha-mode.el provide major mode of `konohascript'.
;; See also http://code.google.com/p/konoha/

;;; History:

;;; Code:

(require 'font-lock)
(require 'cc-mode)

(defgroup konoha nil
  "Konohascript major mode"
  :group 'languages)

(defcustom konoha-tab-width tab-width
  "The tab width to use when indenting"
  :type 'integer
  :group 'konoha)

;; mode
(defvar konoha-mode-map (make-keymap)
  "Keymap for Konohascript major mode.")

;; String Literals

(defvar konoha-string-regexp
  "[uU]?\"\\([^\\]\\|\\\\.\\)*?\"\\|'\\([^\\]\\|\\\\.\\)*?'")

;; Booleans
(defvar konoha-boolean-regexp
  "\\b\\(true\\|false\\|null\\)\\b")

;;
(defvar konoha-type-regexp
  '("int" "Int" "Integer" "char" "short" "long" "byte"
    "float" "double" "Float" "Bytes" "String" "Array" "Map"
    "Set" "Object" "Tuple" "Regex" "boolean" "Boolean"
    "void" "dyn" "var" "Func"))

(defvar konoha-structure-regexp
  '("class" "namespace" "function"))

(defvar konoha-strage-regexp
  '("extends" "interface" "this" "final" "protected" "private" "public"))

(defvar konoha-statement-regexp
  '("as" "default" "from" "is" "isa" "lock" "pragma" "where" "instanceof"))

(defvar konoha-builtin-func-regexp
  '("print" "typeof" "defined" "using" "import" "typeof" "assert"
    "format" "new"))

(defvar konoha-exception-regexp
  '("try" "catch" "finally" "throw"))

(defvar konoha-repeat-regexp
  '("break" "continue" "do" "for" "foreach" "return" "while" "assure"))

(defvar konoha-cond-regexp
  '("if" "else" "switch"))

(defvar konoha-keywords-regexp
  (regexp-opt
   (append konoha-type-regexp
           konoha-structure-regexp
           konoha-strage-regexp
           konoha-statement-regexp
           konoha-builtin-func-regexp
           konoha-exception-regexp
           konoha-repeat-regexp
           konoha-cond-regexp)
   'words))

(defvar konoha-font-lock-keywords
  `(
    (,konoha-string-regexp . font-lock-string-face)
    ;(,konoha-boolean-regexp . font-lock-constant-face)
    (,konoha-keywords-regexp . font-lock-keyword-face)))

(define-derived-mode konoha-mode c-mode
  "Konoha"
  "Major mode for editing konohascript."

  ;; code for syntax highlighting
  (setq font-lock-defaults '((konoha-font-lock-keywords)))

  ;; indentation
  (set (make-local-variable 'tab-width) konoha-tab-width))

(provide 'konoha-mode)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.k$" . konoha-mode))

;;; konoha-mode.el ends here