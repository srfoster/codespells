#lang codespells

(require test-mod/mod-info)

(define-classic-rune (hello)
  #:background "blue"
  #:foreground (circle 40 'solid 'blue)
  (spawn-mod-blueprint pak-folder mod-name "HelloWorld"))

(define-classic-rune-lang my-mod-lang #:eval-from main.rkt
  (hello))

(module+ main
  (codespells-workspace ;TODO: Change this to your local workspace if different
   (build-path (current-directory) ".." "CodeSpellsWorkspace"))
  
  (once-upon-a-time
   #:world (demo-world)
   #:aether (demo-aether
             #:lang (my-mod-lang #:with-paren-runes? #t))))
