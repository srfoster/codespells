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


  (replace-in-file
   (build-path unreal-project-directory "Config" "DefaultGame.ini")
   "TestMod"
   (~a name)))

(define (replace-in-file file find replace)
    
  (define the-file-string
    (file->string
     file))

  (define new-file-string
    (string-replace the-file-string find replace))

  (with-output-to-file #:exists 'replace
    file
    (thunk*
     (displayln new-file-string))))


(define-runtime-path demo-main.rkt
  "test-mod-main.rkt")

(define-runtime-path demo-mod-info.rkt
  "test-mod-info.rkt")

(define (make-demo-racket-code #:root [root (current-directory)] mod-name)
  (copy-file demo-main.rkt
             (build-path root "main.rkt")
             #t)

  (replace-in-file
   (build-path root "main.rkt")
   "TestMod"
   (~a (racket-id->unreal-id mod-name)))

  (replace-in-file
   (build-path root "main.rkt")
   "test-mod"
   (~a mod-name))

  (copy-file demo-mod-info.rkt
             (build-path root "mod-info.rkt")
             #t)

  (replace-in-file
   (build-path root "mod-info.rkt")
   "TestMod"
   (~a (racket-id->unreal-id mod-name)))

  (replace-in-file
   (build-path root "mod-info.rkt")
   "test-mod"
   (~a mod-name))
  )