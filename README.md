# Emacs Major Mode of KonohaScript

## Introduction

konoha-mode.el provides Emacs major-mode of KonohaScript.

## Sample configuration

    (require 'konoha-mode)

    ;; setting for flymake
    (require 'flymake)
    (add-to-list 'flymake-allowed-file-name-masks '("\\.k\\'" flymake-konoha-init))

    (defun flymake-konoha-init ()
      (let* ((temp-file (flymake-init-create-temp-buffer-copy
                         'flymake-create-temp-inplace))
             (local-file (file-relative-name
                          temp-file
                          (file-name-directory buffer-file-name))))
        (list "konoha" (list "-c" local-file))))

    (defvar konoha-compiler-message-regexp
      "^\s+-\s+([^:]+:\\([[:digit:]]+\\))\s+(\\(error\\|warning\\))\s+\\(.+\\)$")

    (defun flymake-konoha-load ()
      (interactive)
      (add-to-list 'flymake-err-line-patterns
                   `(,konoha-compiler-message-regexp
                     nil 1 nil 3))
      (flymake-mode t))

    (add-hook 'konoha-mode-hook
              (lambda ()
                (flymake-konoha-load)))
    
    ;; setting for quickrun
    (quickrun-add-command "konoha"
                      '((:command      . "konoha")
                        (:compile-only . "%c -c %s"))
                      :mode 'konoha-mode)
    (add-to-list 'quickrun-file-alist '("\\.k$" . "konoha"))


## See also

- [Official Site](http://code.google.com/p/konoha/)
- [Wiki in Japanese](http://konoha.sourceforge.jp/d/doku.php)
