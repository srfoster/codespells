#lang racket

(require "./lib.rkt"
         raco/command-name)

(define mod-name
  (command-line
   #:program (short-program+command-name)
   #:args (mod-name)
   mod-name))

(define unreal-project-name (racket-id->unreal-id mod-name))

(displayln "Creating new mod package")
(displayln mod-name)

(system (~a "raco pkg new " mod-name))

(displayln "Creating empty Unreal mod project")

(make-unreal-project #:root (build-path (current-directory) mod-name)
                     unreal-project-name)

(displayln "Creating demo Racket code")

(make-demo-racket-code
 #:root (build-path (current-directory) mod-name)
 mod-name)