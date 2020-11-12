#lang racket 

(provide 

  (except-out (struct-out rune-lore) rune-lore)
  (rename-out [make-rune-lore rune-lore])

  (struct-out rune-collection-lore)
  (struct-out authored-work-lore)
  define-authored-work-lore
  define-rune-collection-lore
  dynamic-require-lore)

(require website-js racket/runtime-path)

;Underlying structures for lore (aka documentation)

;You can get a lore object from a package name,
;  via dynamic-require
(define (dynamic-require-lore pkg-name)
  (dynamic-require (string->symbol (~a pkg-name "/lore")) 'lore))
 
;Lore objects come in three types -- depending on the kind of thing the lore is
;  is about

;Note that rune-collection-lores have rune-lores inside of them.
;Whereas authored-work-lores merely have package names of rune collections

(struct rune-lore            (name description rune) #:transparent)
(struct rune-collection-lore (name description preview-image rune-lores) #:transparent)
(struct authored-work-lore   (name description preview-image rune-collection-names) #:transparent)

;Some convenient macros for defining/providing lores
(define-syntax-rule 
  (define-authored-work-lore 
    #:name name
    #:description description
    #:rune-collections rune-collections
    #:preview-image preview-image)
  (begin
    (provide lore)
    (define lore
      (authored-work-lore
	name description preview-image rune-collections))))

(define-syntax-rule 
  (define-rune-collection-lore 
    #:name name
    #:description description
    #:rune-lores rune-lores
    #:preview-image preview-image)
  (begin
    (provide lore)
    (define lore
      (rune-collection-lore
	name description preview-image rune-lores ))))

;A constructor with keywords, for better readability in constructing rune lores
(define (make-rune-lore #:name name
			#:rune rune
			#:description description)
  (rune-lore name description rune))

