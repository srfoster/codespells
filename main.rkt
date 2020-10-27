#lang at-exp racket

(provide once-upon-a-time
         demo-aether
         current-file-name ;helps with simple mods
         codespells-workspace
         (all-from-out racket
                       codespells-server
                       codespells-server/unreal-client
                       codespells-runes codespells/demo-aether))

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

(provide demo-world spawn-mod-blueprint )

(require racket/runtime-path
         codespells-server
         codespells-server/unreal-client)

(define-runtime-path js-runtime "./js/on-start.js")

(define (spawn-mod-blueprint mod-folder
                             mod-name
                             blueprint-name)
  (unreal-js
   @~a{
       (function(){
       var C = functions.bpFromMod("@(string-replace (path->string mod-folder)
                                                     "\\"
                                                     "\\\\")/",
                                   "@mod-name",
                                   "@blueprint-name")

       var o = new C(GWorld,{X:@(current-x), Y:@(current-z), Z:@(current-y)},
                            {Roll:@(current-roll), Pitch:@(current-pitch), Yaw:@(current-yaw)})

       return o
       })()
   }))


#; ;Just retaining as example of requests from JS. Not useful as a log.  Move elsewhere
(define (log s) ; Could also just pipe in the Unreal logs, might be more useful...
  @unreal-js{
    (function(){
    let request = require('request')
    return request("POST","http://localhost:8081/eval-spell?lang=racket&spell=(displayln \""+@|s|+"\")", {})
    })()      
 })






(define codespells-workspace (make-parameter (current-directory)))

(define (demo-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/demo-world/0.0/CodeSpellsDemoWorld.zip"
   "CodeSpellsDemoWorld"
   560 ;It's about 558.8 Megabytes, I think
   ))

;TODO: Move to new package
(provide voxel-world)
(define (voxel-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/voxel-world/0.0/VoxelWorld.zip"
   "VoxelWorld"
   606))

(define (fetch-and-run-world world-installation-source world-name size-in-mb)
  (local-require file/unzip net/sendurl)

  (define zip-file-name (last (string-split world-installation-source "/")))
  (define world-installation-target (build-path (codespells-workspace) world-name))
 
  (lambda ()
    (displayln (~a "Starting World: " world-name)) 

    (when (not (file-exists? (build-path (codespells-workspace) zip-file-name)))
      (displayln "Downloading world zip file...")
      (dl world-installation-source
        (build-path (codespells-workspace) zip-file-name)
        size-in-mb
        ))

    (when (not (directory-exists? world-installation-target))
      (displayln "Unzipping")
      (unzip (build-path (codespells-workspace) zip-file-name))
      (rename-file-or-directory
       (build-path (current-directory) world-name)
       world-installation-target) )

    (copy-file js-runtime
               (build-path (codespells-workspace)
                           world-name
                           world-name
                           "Content"
                           "Scripts"
                           "on-start.js")
               #t)

    (define exe (~a (build-path world-installation-target (~a world-name ".exe" )
                                )))
    (displayln (~a "Running " exe)) ;Assume Windows for now

    (thread (thunk (system exe)))


    ))



;Another module shaping up here

(provide define-classic-rune
         define-classic-rune-lang
         spawn-this-mod-blueprint
         (all-from-out 2htdp/image))

(require racket/runtime-path
         syntax/parse/define
         (for-syntax racket/syntax racket/path racket/list)
         2htdp/image)

(define-syntax (define-classic-rune stx)
  (syntax-parse stx
    [(_ head #:background bg #:foreground fg lines ...)
     #:with name (car (syntax-e #'head))
     #:with name-rune (format-id stx "~a-rune" #'name)
     #:with name-rune-binding (format-id stx "~a-rune-binding" #'name)

     #`(begin
         (provide name)
         
         (define head
           lines ...)

         (define (name-rune)
           (svg-rune-description
            (rune-background
             #:color bg
             (rune-image fg))))

         (define name-rune-binding
           (html-rune 'name (name-rune)))
         )]))

(define-syntax (define-classic-rune-lang stx)
  (syntax-parse stx
    [(_ name (rune-names ...))
     #:with rune-bindings (map (lambda (n) (format-id stx "~a-rune-binding" n))
                               (syntax->list #'(rune-names ...))) ;(format-id stx "~a-rune-binding" 'hello)
     #`(begin
         (provide name)
         (define (name #:with-paren-runes? [with-paren-runes? #f])
           (local-require codespells-runes)
           (rune-lang #,(syntax-source stx)
                      (rune-list #:with-paren-runes? with-paren-runes?
                              
                                 #,@#'rune-bindings
                                 ))))]))



(require (for-syntax codespells/modding/lib racket/format))

(define-for-syntax (this-unreal-mod-location stx)
  (build-path (path-only (syntax-source stx))
                  "BuildUnreal"
                  "WindowsNoEditor"
                  (~a (racket-id->unreal-id
                       (find-pkg-root-dir (path-only (syntax-source stx)))))
                  "Content"
                  "Paks"))

(define-for-syntax (this-unreal-mod-name stx)
  (~a (racket-id->unreal-id
           (find-pkg-root-dir (path-only (syntax-source stx))))))


;TODO: Could check at compile time that this BP exists...
;  Could tell them what to do in the Unreal project...
                       
(define-syntax (spawn-this-mod-blueprint stx)
  (syntax-parse stx
    [(_ name)
     #`(spawn-mod-blueprint
        #,(this-unreal-mod-location stx)
        #,(this-unreal-mod-name stx)
        name)
     ]))

