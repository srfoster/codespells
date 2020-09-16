#lang racket

(provide once-upon-a-time
         demo-aether
         demo-world
         (all-from-out racket))

(require codespells/demo-aether)

(module reader syntax/module-reader
  codespells/main)

(define (once-upon-a-time #:aether aether #:world world)
  (displayln "Starting World and Aether")
  
  (world)
  (aether) 
  
  (let loop ()
    (sleep 1)
    (loop)))




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
    

    (displayln "Running exe") ;Assume Windows for now

    (thread (thunk (system (~a (build-path world-installation-target "CodeSpellsDemoWorld.exe")))))

    ))

