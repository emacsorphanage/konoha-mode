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
  "\\<\\(true\\|false\\|null\\)\\>")

;; builtin functions
(defvar konoha-builtin-func-regexp
  (regexp-opt
   '("print" "typeof" "defined" "using" "import" "typeof" "assert"
    "format" "new")
   'words))

;; Data type
(defvar konoha-type-regexp
  (regexp-opt
   '("int" "Int" "Integer" "char" "short" "long" "byte"
     "float" "double" "Float" "Bytes" "String" "Array" "Map"
     "Set" "Object" "Tuple" "Regex" "boolean" "Boolean"
     "void" "dyn" "var" "Func")
   'words))

;; keywords
(defvar konoha-structure-keywords
  '("class" "namespace" "function" "def"))

(defvar konoha-strage-keywords
  '("extends" "interface" "this" "final" "protected" "private" "public"))

(defvar konoha-statement-keywords
  '("as" "default" "from" "is" "isa" "lock" "pragma" "where" "instanceof"))

(defvar konoha-exception-keywords
  '("try" "catch" "finally" "throw"))

(defvar konoha-repeat-keywords
  '("break" "continue" "do" "for" "foreach" "return" "while" "assure"))

(defvar konoha-cond-keywords
  '("if" "else" "switch"))

(defvar konoha-keywords-regexp
  (regexp-opt
   (append konoha-structure-keywords
           konoha-strage-keywords
           konoha-statement-keywords
           konoha-exception-keywords
           konoha-repeat-keywords
           konoha-cond-keywords)
   'words))

(defvar konoha-font-lock-keywords
  `(
    (,konoha-type-regexp . font-lock-type-face)
    (,konoha-string-regexp . font-lock-string-face)
    (,konoha-boolean-regexp . font-lock-constant-face)
    (,konoha-builtin-func-regexp . font-lock-builtin-face)
    (,konoha-keywords-regexp . font-lock-keyword-face)))

(defvar konoha-mode-hook nil
  "A hook for you to run your own code when the mode is loaded")

(define-derived-mode konoha-mode java-mode
  "Konoha"
  "Major mode for editing konohascript."

  ;; code for syntax highlighting
  (setq font-lock-defaults '((konoha-font-lock-keywords)))

  ;; indentation
  (set (make-local-variable 'tab-width) konoha-tab-width))

;;
;; REPL
;;

(require 'comint)

(defvar konoha-buffer nil "*The current konoha process buffer.*")

(when (require 'ansi-color nil t)
 (autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
 (add-hook 'inferior-konoha-mode-hook 'ansi-color-for-comint-mode-on))

(defvar inferior-konoha-mode-map (make-sparse-keymap)
  "konoha interactive mode map")

;; Install the process communication commands in the konoha-mode keymap.
(define-key konoha-mode-map (kbd "C-c C-r") 'konoha-send-region)

(define-derived-mode inferior-konoha-mode comint-mode "Inferior Konoha"
  ;; Customize in inferior-konoha-mode-hook
  (setq comint-prompt-regexp "^>>> *")
  (setq mode-line-process '(":%s"))
  (setq comint-input-filter (function konoha-input-filter)))

(defcustom inferior-konoha-filter-regexp "\\`\\s *\\S ?\\S ?\\s *\\'"
  "Input matching this regexp are not saved on the history list.
Defaults to a regexp ignoring all inputs of 0, 1, or 2 letters."
  :type 'regexp
  :group 'inf-konoha)

(defun konoha-input-filter (str)
  "Don't save anything matching `inferior-konoha-filter-regexp'."
  (not (string-match inferior-konoha-filter-regexp str)))

(defun konoha-send-region (start end)
  "Send the current region to the inferior Konoha process."
  (interactive "r")
  (let* ((str (buffer-substring-no-properties start end))
         (ignore-newline (replace-regexp-in-string "[\r\n]" "" str)))
    (comint-send-string (konoha-proc) ignore-newline)))

(defun konoha-proc ()
  (unless (and konoha-buffer
               (get-buffer konoha-buffer)
               (comint-check-proc konoha-buffer))
    (konoha-interactively-start-process))
  (or (konoha-get-process)
      (error "No current process.  See variable `konoha-buffer'")))

(defun konoha-get-process ()
  "Return the current Konoha process or nil if none is running."
  (get-buffer-process (if (eq major-mode 'inferior-konoha-mode)
                          (current-buffer)
                        konoha-buffer)))

(defun konoha-interactively-start-process (&optional cmd)
  "Start an inferior konoha process.  Return the process started.
Since this command is run implicitly, always ask the user for the
command to run."
  (save-window-excursion
    (run-konoha (read-string "Run Konoha: " konoha-program-name))))

(defvar konoha-program-name "konoha")
(defvar konoha-repl-name "*konoha*")

(defun run-konoha (cmd)
  (interactive (list (if current-prefix-arg
                         (read-string "Run konoha: " konoha-program-name)
                       konoha-program-name)))
  (if (not (comint-check-proc "*konoha*"))
      (let ((cmdlist (split-string-and-unquote cmd)))
        (set-buffer (apply 'make-comint "konoha" (car cmdlist)
                           nil (cdr cmdlist)))
        (inferior-konoha-mode)))
  (setq konoha-program-name cmd)
  (setq konoha-buffer "*konoha*")
  (pop-to-buffer "*konoha*"))

(defun konoha-start-file (prog)
  (let* ((progname (file-name-nondirectory prog))
         (start-file (concat "~/.emacs_" progname))
         (alt-start-file (concat user-emacs-directory "init_" progname ".clj")))
    (if (file-exists-p start-file)
        start-file
      (and (file-exists-p alt-start-file) alt-start-file))))

(provide 'konoha-mode)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.k$" . konoha-mode))

;;; konoha-mode.el ends here
