#lang at-exp racket

(provide demo-aether
         setup-demo-aether
         demo-aether-lang
         teleport)

(require codespells-server/unreal-client
         codespells-server/in-game-lang)

(define (teleport)
  (unreal-eval-js @~a{functions.teleport({X: @(current-x),Y:@(current-z),Z:@(current-y)})}))

(define (setup-demo-aether)
  (unreal-eval-js @~a{
    functions.teleport = function(location){
      var cc = GWorld.GetAllActorsOfClass(Root.ResolveClass('Avatar')).OutActors[0];
      cc.SetActorLocation(location)
    }}))




(define (demo-aether-lang)
  (local-require codespells-runes 2htdp/image)
  (rune-lang 'codespells/demo-aether
             (list
              (html-rune '|(| 
                         (open-paren-rune))

              (html-rune '|)|
                         (close-paren-rune))
                      
              (html-rune 'teleport 
                         (svg-rune-description
                          (rune-background
                           #:color "green"
                           (rune-image
                            (overlay
                             (circle 5 'solid 'green)
                             (circle 10 'solid 'black)
                             (circle 15 'solid 'green)
                             (circle 20 'solid 'black)
                             (circle 25 'solid 'green)))))))))


(define (demo-aether #:lang [aether-lang (demo-aether-lang)]
                     #:setup [more-aether-setup (thunk* (void))])
  (lambda ()
    (local-require codespells-server)
    (displayln "Starting Demo Aether")

    (setup-demo-aether)
    (more-aether-setup)

    ;Start the server with the appropriate Runes -- Just the teleport rune for now
    (parameterize
        ([current-editor-lang aether-lang])
      (codespells-server-start))))