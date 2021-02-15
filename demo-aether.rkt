#lang at-exp racket

(provide demo-aether
         setup-demo-aether
         demo-aether-lang
         teleport)

(require codespells-server/lang
         codespells-server/unreal-js/unreal-client
         )

(define (teleport)
  (unreal-eval-js @~a{functions.teleport({X: @(current-x),Y:@(current-z),Z:@(current-y)})}))

(define (setup-demo-aether)
  (unreal-eval-js @~a{
 functions.teleport = function(location){
  var cc = GWorld.GetAllActorsOfClass(Root.ResolveClass('Avatar')).OutActors[0];
  cc.SetActorLocation(location);
 }

 functions.browserWindow = function(id, url){                                       
  var widget = widgets[id];
  
  if(!widget){
   widget = GWorld.CreateWidget(WB_TextSpellcrafting_C, GWorld.GetPlayerController(0));
   console.log(widget);
   widget.WebBrowser_309.InitialURL = url;
   widget.AddToViewport();
   widgets[id] = widget;
  }

  widget.SetVisibility(ESlateVisibility.Visible);
  var control = GWorld.GetPlayerController(0);
  control.SetInputMode_UIOnly();
  control.bShowMouseCursor = true;                                 
 }

 })

  
  (unreal-eval-js @~a{
 class MyIH extends Root.ResolveClass("InputHelper") {
  HandleKeyPressed(key) {
   if(key.KeyName == 'C'){
    functions.browserWindow("editor", "http://localhost:@(codespells-server-port)/editor");          
   }
  }
 } 

 let MyIH_C = require('uclass')()(global,MyIH);
 new MyIH_C(GWorld);
 })
  (unreal-eval-js @~a{
      functions.browserWindow("welcome", "http://localhost:@(codespells-server-port)/");     
    }))


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