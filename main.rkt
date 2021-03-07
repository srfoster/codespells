#lang at-exp racket

(provide once-upon-a-time
         extra-unreal-command-line-args
         multiplayer
         server-ip-address
         
         demo-aether
         current-file-name ;helps with simple mods
         codespells-workspace
         (all-from-out racket
                       codespells-server
                       codespells-server/unreal-js/unreal-client
                       codespells-runes codespells/demo-aether)
         define-runtime-path
         spawn-mod-blueprint ;should this file be providing this?
         #%module-begin)

(require codespells/demo-aether
         codespells-runes
         codespells-server/unreal-js/util
         (rename-in racket [#%module-begin #%old-module-begin]))

(module reader syntax/module-reader
  codespells/main)

(define server-ip-address (make-parameter "127.0.0.1"))

(define multiplayer (make-parameter #f))

(define extra-unreal-command-line-args (make-parameter ""))

(define (once-upon-a-time #:aether aether #:world world)
  (displayln "Starting World and Aether")
  
  (world)
  (parameterize ([running-as-multiplayer-server? (eq? 'server (multiplayer))])
   (aether))
  
  (let loop ()
    (sleep 1)
    (loop)))





;Should move dl to utility (outside of CodeSpells)

(provide dl)

(define (find-dl-size url)
  (local-require net/http-easy)

  (/
   (string->number (bytes->string/utf-8 (response-headers-ref (head url) 'Content-Length)))
   1000000))

(define (dl from to [size-in-megabytes (find-dl-size from)])
  (local-require net/url)

  (define the-url (string->url from))
  (define in (get-pure-port the-url))
  (define out (open-output-file to))

  (thread (λ () (listen-for-progress in 0 size-in-megabytes)))
  
  (copy-port in out)
  
  (close-output-port out))

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
        (listen-for-progress in last-percent-complete total-metabytes))))



;TODO: Probably time to move this world stuff to a new file, if not a codespells-worlds repo
; Essentially a new module evolving below this line...

(provide demo-world)

(require racket/runtime-path
         codespells-server
         codespells-server/unreal-js/unreal-client)

(define-runtime-path js-runtime "./js/on-start.js")

(define codespells-workspace (make-parameter (current-directory)))

(define (demo-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/demo-world/0.0/CodeSpellsDemoWorld.zip"
   "CodeSpellsDemoWorld"
   "Minimal_Default"
   ))

;TODO: Move to new package
(provide temple-world)
(define (temple-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/temple-world/0.0/TempleWorld.zip"
   "TempleWorld"
   "DemoMap3"))

;TODO: Move to new package
(provide village-world)
(define (village-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/village-world/0.0/VillageWorld.zip"
   "VillageWorld"
   "AdvancedVillagePack_Showcase"))

;TODO: Move to new package
(provide polar-facility-world)
(define (polar-facility-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/polar-facility-world/0.0/PolarFacilityWorld.zip"
   "PolarFacilityWorld"
   "PolarFacilityMap"))

;TODO: Move to new package
(provide voxel-world)
(define (voxel-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/voxel-world/0.0/VoxelWorld.zip"
   "VoxelWorld"
   "VoxelWorld"
   ))

;TODO: Move to new package
(provide log-cabin-world)
(define (log-cabin-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/log-cabin-world/0.0/LogCabinWorld.zip"
   "LogCabinWorld"
   "Demonstration_Map"))

;TODO: Move to new package
(provide forest-world)
(define (forest-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/forest-world/0.0/ForestWorld.zip"
   "ForestWorld"
   "Demo_Scene"))

;TODO: Move to new package
(provide cave-world)
(define (cave-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/cave-world/0.0/CaveWorld.zip"
   "CaveWorld"
   "LV_Soul_Cave"))

(provide arena-world)
(define (arena-world)
  (fetch-and-run-world
   "https://codespells-org.s3.amazonaws.com/WorldTemplates/arena-world/0.0/ArenaWorld.zip"
   "ArenaWorld"
   "DemoMap1"))

(define (fetch-and-run-world world-installation-source world-name [map-name #f])
  (local-require file/unzip net/sendurl)

  (define zip-file-name (last (string-split world-installation-source "/")))
  (define world-installation-target (build-path (codespells-workspace) world-name))
 
  (lambda ()
    (displayln (~a "Starting World: " world-name)) 

    (when (and
           (not (file-exists? (build-path (codespells-workspace) zip-file-name)))
           (not (directory-exists? world-installation-target)))
      (displayln "Downloading world zip file...")

      (dl world-installation-source
        (build-path (codespells-workspace) zip-file-name)
        ))

    (when (not (directory-exists? world-installation-target))
      (displayln "Unzipping")
      (unzip (build-path (codespells-workspace) zip-file-name))
      (rename-file-or-directory
       (build-path (current-directory) world-name)
       world-installation-target))
    
    (copy-file js-runtime
               (build-path (codespells-workspace)
                           world-name
                           world-name
                           "Content"
                           "Scripts"
                           "on-start.js")
               #t)

    (define multiplayer-command-line
      (if (not (multiplayer))
          ""
          (if (not map-name)
              (error (~s "No map name is set for " world-name))
              (if (eq? (multiplayer) 'client)
                  (server-ip-address)
                  (~a map-name "?listen")))))
    
    (define exe (~a (build-path world-installation-target (~s world-name ".exe"))
                    " " multiplayer-command-line
                    " -unreal-server=" (unreal-server-port)
                    " -codespells-server=" (codespells-server-port)
                    " " (extra-unreal-command-line-args)
                    ))
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
         (provide name name-rune)
         
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
    [(_ name #:eval-from eval-from (rune-names ...))
     #:with rune-bindings (map (lambda (n) (format-id stx "~a-rune-binding" n))
                               (syntax->list #'(rune-names ...))) ;(format-id stx "~a-rune-binding" 'hello)
     #`(begin
         (provide name)
         (define (name #:with-paren-runes? [with-paren-runes? #f])
           (local-require codespells-runes)
           (rune-lang eval-from ;#,(syntax-source stx)
                      (rune-list #:with-paren-runes? with-paren-runes?
                              
                                 #,@#'rune-bindings
                                 ))))]))



(require (for-syntax codespells/modding/lib racket/format))

(define-for-syntax (this-unreal-mod-location stx)
  ;Hmmm.   This doesn't work when we do `raco exe`, still references the old path
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


(define-syntax (#%module-begin stx)
  (syntax-parse stx
    [(_ things ...)
     #`(#%old-module-begin

        things ...
        )]))
                       
(define-syntax (spawn-this-mod-blueprint stx)
  (syntax-parse stx
    [(_ name)

     
     #`(spawn-mod-blueprint
        #,(datum->syntax stx 'MyPak)
        #,(datum->syntax stx 'mod-name)
        name)

     #;
     #`(spawn-mod-blueprint
        #,(this-unreal-mod-location stx)
        #,(this-unreal-mod-name stx)
        name)
     ]))

(define-syntax (current-file-name stx)

  (datum->syntax stx 'main.rkt)

  #;
  #`#,(syntax-source stx))


(provide require-mod)
(require syntax/parse/define
         (for-syntax racket/syntax))
(define-syntax (require-mod stx)
  (syntax-parse stx
    [(_ name)
     #:with name: (format-id stx "~a:" #'name)
     #'(begin
         (provide (all-from-out name))

         (require
           (prefix-in name: (only-in name my-mod-lang))
           (except-in name my-mod-lang)
           ))]))


(provide mod)
(define-syntax (mod stx)
  (syntax-parse stx
    [(mod the-mod-name
          #:pak-folder
          pak-folder-name)
     #`(begin
         (module mod-info racket
           (define mod-name "MyMod")
           ;(define-runtime-path main.rkt "main.rkt")
           ;(define-runtime-path MyPak pak-folder-name)
           )
         (require 'mod-info)
         )
     #;
     (datum->syntax stx `(begin
                           (define mod-name ,(syntax->datum #'the-mod-name))
                           (define-runtime-path main.rkt "main.rkt")
                           (define-runtime-path MyPak ,(syntax->datum #'pak-folder-name))
                           ))]))
