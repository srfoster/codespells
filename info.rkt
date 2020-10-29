#lang info
(define collection "codespells")
(define deps '("base" "https://github.com/srfoster/codespells-server.git" "aws"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/codespells.scrbl" ())))
(define pkg-desc "Description Here")
(define version "0.0")
(define pkg-authors '(ThoughtSTEM))

(define raco-commands
  '(("codespells" codespells/modding/new-mod
                  "Creates a new CodeSpells mod" 100)
    ("codespells-release" codespells/modding/release
                          "Releases a new CodeSpells mod" 100)
    ("codespells-install" codespells/modding/install
                          "Installs a new CodeSpells mod" 100)))