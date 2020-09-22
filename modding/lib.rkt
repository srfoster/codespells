#lang racket


(provide make-unreal-project
         make-demo-racket-code
         racket-id->unreal-id
         find-pkg-root-dir)

(require racket/runtime-path)

;Todo: Expose to CLI raco tool
;Todo: Move small "TestMod" here (remove assets)

(define (uppercasify s)
  (define (uppercase-first-letter s)
    (string-append
     (string-upcase (substring s 0 1))
     (substring s 1)))
  
  (string-join
   (map uppercase-first-letter (string-split s "-"))
   ""))

(define (racket-id->unreal-id id)
  (string->symbol
   (uppercasify
    (~a id))))

(define (find-pkg-root-dir dir-p)
  (if (file-exists? (build-path dir-p "info.rkt"))
      (~a (last (explode-path (simplify-path dir-p))))
      (find-pkg-root-dir (build-path dir-p ".."))
      ))

(define-runtime-path template-unreal-project-directory
  "TestMod")

(define (make-unreal-project #:root [root (current-directory)] name)
  (make-directory
   (build-path root "Unreal"))
  
  (make-directory
   (build-path root "BuildUnreal"))
  
  (define unreal-project-directory
    (build-path root "Unreal" (~a name)))

  (when (directory-exists?  unreal-project-directory)
    (delete-directory/files unreal-project-directory))
  
  (copy-directory/files template-unreal-project-directory
                        unreal-project-directory)

  (rename-file-or-directory
   (build-path unreal-project-directory "TestMod.uproject")
   (build-path unreal-project-directory (~a name ".uproject"))
   #t)

   
  (rename-file-or-directory
   (build-path unreal-project-directory "Plugins" "TestMod")
   (build-path unreal-project-directory "Plugins" (~a name))
   #t)

  (rename-file-or-directory
   (build-path unreal-project-directory "Plugins" (~a name) "TestMod.uplugin")
   (build-path unreal-project-directory "Plugins" (~a name) (~a name ".uplugin"))
   #t)

  (define DefaultGame.ini
    (file->string
     (build-path unreal-project-directory "Config" "DefaultGame.ini")))

  (define new-DefaultGame.ini
    (string-replace DefaultGame.ini "TestMod" (~a name)))

  (with-output-to-file #:exists 'replace
    (build-path unreal-project-directory "Config" "DefaultGame.ini")
    (thunk*
     (displayln new-DefaultGame.ini))))


(define-runtime-path demo-main.rkt
  "test-mod-main.rkt")

(define (make-demo-racket-code #:root [root (current-directory)] mod-name)
  (copy-file demo-main.rkt
             (build-path root "main.rkt")
             #t)

  ;TODO: Fix TestMod -> upcase mod-name
  ;  Actually, just infer based on the enclosing folder, or pkg name, or a global var...
  )