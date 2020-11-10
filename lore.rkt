#lang racket 

(require website-js)

(provide link-to-collection
         rune-collection-listing
         rune-collection-name->preview-card 
         rune-collection-name->preview-icon)  

(define (link-to-collection name [content name])
  (a href: 
     ;The path convention on codespells.org
     (~a "/collections/"
	 (string-replace 
	   (string-downcase name)
	   " " "-")
	 "/index.html")
     content))

(define (rune-collection-listing name preview)
  (card 
    (card-header
      (link-to-collection name))
    (card-body
      preview)))


(define (rune-collection-name->preview-card module-name)
  (define module-name/lore (string->symbol
			     (~a module-name "/lore")))

  (define name 
    (dynamic-require module-name/lore 'name))

  (define preview-image 
    (dynamic-require module-name/lore 'preview-image))

  (rune-collection-listing (name) 
			   (preview-image)))

(define (rune-collection-name->preview-icon module-name)
  (define module-name/lore (string->symbol
			     (~a module-name "/lore")))

  (define name 
    (dynamic-require module-name/lore 'name))

  (define preview-image 
    (dynamic-require module-name/lore 'preview-image))

  (link-to-collection (name) (preview-image)))
