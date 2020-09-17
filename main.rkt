#lang at-exp racket

(provide once-upon-a-time
         demo-aether
         current-file-name ;helps with simple mods
         (all-from-out racket codespells-server codespells-runes codespells/demo-aether))

(require codespells/demo-aether codespells-runes)

(module reader syntax/module-reader
  codespells/main)

(define (once-upon-a-time #:aether aether #:world world)
  (displayln "Starting World and Aether")
  
  (world)
  (aether) 
  
  (let loop ()
    (sleep 1)
    (loop)))


(define-syntax (current-file-name stx)
  #`#,(syntax-source stx))

(define (dl from to size-in-megabytes)
  (local-require net/url)

  (define the-url (string->url from))
  (define in (get-pure-port the-url))
  (define out (open-output-file to))

  (thread (λ () (listen-for-progress in 0 size-in-megabytes)))
  
  (copy-port in out)
  
  (close-output-port out)
  )

(define (listen-for-progress in last-percent-complete total-metabytes)
  (sync (port-progress-evt in))
  (unless (port-closed? in)
    (define-values [line col pos] (port-next-location in))
    ;pos is the byte position

    (define percent-complete (* 100 (exact->inexact (/ pos (* total-metabytes 1000000)))))

    ;(displayln percent-complete)

    (if (> percent-complete (+ 1 last-percent-complete))
        (begin
          (printf "World download progress: ~a%\n"
                (~r (min percent-complete 100)
                    #:precision 2))
          (listen-for-progress in percent-complete total-metabytes))
        (listen-for-progress in last-percent-complete total-metabytes))
    
    
    
    ))



;TODO: Probably time to move this world stuff to a new file, if not a codespells-worlds repo
; Essentially a new module evolving below this line...

(provide demo-world spawn-mod-blueprint)

(require racket/runtime-path
         codespells-server
         codespells-server/unreal-client)

(define-runtime-path js-runtime "./js/on-start.js")

(define (spawn-mod-blueprint mod-folder
                             mod-name
                             blueprint-name)
  (unreal-eval-js
   @~a{
       var C = functions.bpFromMod("@(string-replace (path->string mod-folder)
                                                     "\\"
                                                     "\\\\")/",
                                   "@mod-name",
                                   "@blueprint-name")

       var o = new C(GWorld,{X:@(current-x), Y:@(current-z), Z:@(current-y)},
                            {Roll:@(current-roll), Pitch:@(current-pitch), Yaw:@(current-yaw)})
   }))

(define (demo-world)
  (local-require file/unzip net/sendurl)

  ;TODO: Once there's another world we want to release, extract all this into a more general world downloader function

  (define world-installation-source "https://codespells-org.s3.amazonaws.com/WorldTemplates/demo-world/0.0/CodeSpellsDemoWorld.zip")
  (define world-installation-target (build-path (current-directory) "CodeSpellsDemoWorld"))
 
  (lambda ()
    (displayln "Starting Demo World") 

    (when (not (file-exists? (build-path (current-directory) "CodeSpellsDemoWorld.zip")))
      (displayln "Downloading world zip file...")
      (dl world-installation-source
        (build-path (current-directory) "CodeSpellsDemoWorld.zip")
        560 ;It's about 558.8 Megabytes, I think
        ))

    (when (not (directory-exists? world-installation-target))
      (displayln "Unzipping")
      (unzip (build-path (current-directory) "CodeSpellsDemoWorld.zip")))

    (copy-file js-runtime
               (build-path (current-directory)
                           "CodeSpellsDemoWorld"
                           "CodeSpellsDemoWorld"
                           "Content"
                           "Scripts"
                           "on-start.js")
               #t)

    (displayln "Running exe") ;Assume Windows for now

    (thread (thunk (system (~a (build-path world-installation-target "CodeSpellsDemoWorld.exe")))))


    ))

