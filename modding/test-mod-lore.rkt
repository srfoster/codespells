#lang at-exp racket

(require test-mod
	 codespells/lore)

(define-rune-collection-lore 
  #:name "A Cool Name for TestMod"
  #:description 
  @md{
    A cool intro about TestMod
  }
  #:rune-lores
  (list)
  #:preview-image preview.png)

