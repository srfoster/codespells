#lang racket

(require "./base.rkt" website-js)

;For display of lore things

(provide link-to-collection
         rune-collection-listing
         rune-collection-name->preview-card 
         rune-collection-name->preview-icon
	 lore->name-slug)  

(require syntax/parse/define
	 website-js/components/accordion-cards
	 (for-syntax racket/syntax
		     racket/format))

(provide 
  authored-work-lore->preview-image/page 
  authored-work-lore->authored-work-card
  rune-collection-lore->rune-collection/page

  authored-work-card
  download-button
  coming-soon)

(define (lore->name-slug lore)
  (string-replace 
    (string-downcase (cond 
		       [(authored-work-lore? lore)
			(authored-work-lore-name lore)]
		       [(rune-collection-lore? lore)
			(rune-collection-lore-name lore)]))
    " " "-"))

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

  (define lore 
    (dynamic-require module-name/lore 'lore))

  (rune-collection-listing (rune-collection-lore-name lore) 
			   (rune-collection-lore-preview-image lore)))

(define (rune-collection-name->preview-icon module-name)
  (define module-name/lore (string->symbol
			     (~a module-name "/lore")))

  (define lore 
    (dynamic-require module-name/lore 'lore))

  (link-to-collection (rune-collection-lore-name lore) 
		      (rune-collection-lore-preview-image lore)))



(define (rune-collection-lore->rune-collection/page
	  rune-collection-name
	  #:path path
	  #:wrapper[wrapper identity])

  (define lore (dynamic-require-lore rune-collection-name))
  (page (identity path)
	(wrapper
	  (container
	    (h1 (rune-collection-lore-name lore))
	    (rune-collection-lore-description  lore)
	    (map
	      (lambda (r)
		(card (card-header
			(rune-lore-rune r)
			(h3 (rune-lore-name r)))
		      (card-body
			(rune-lore-description r))))
	      (rune-collection-lore-rune-lores lore))))))


(define (authored-work-lore->preview-image/page authored-work-name #:path path )
  (let ()
    (define lore (dynamic-require-lore authored-work-name))

    (define preview-image
      (authored-work-lore-preview-image lore))
    (page (identity path)  
	  preview-image)))


(define (authored-work-lore->authored-work-card pkg-name )
  (let ()
    (define lore (dynamic-require-lore pkg-name))

    (define name 
      (authored-work-lore-name lore))
    (define description
      (authored-work-lore-description lore))
    (define rune-collections
      (authored-work-lore-rune-collection-names lore))
    (define preview-image
      (authored-work-lore-preview-image lore))

    (authored-work-card (h3 name) 
		(img class: "card-img-top"
		     src: (~a 
			    "works/" (lore->name-slug lore)
			    "/preview.png"))

		(accordion-card #:header "Read More..."
				(h5 "Rune Collections")
				(map 
				  rune-collection-name->preview-icon 
				  rune-collections)
				(br)
				description)

		(hr)

		;Change on s3
		(download-button (~a pkg-name)))))


(define (authored-work-card title img . content)
  (card
    (card-header title
		 img)
    (card-body content)))

(define (download-button name)
  (local-require website/bootstrap/font-awesome)
  (a href: (~a "https://codespells-org.s3.amazonaws.com/StandaloneBuilds/" name "/0.0/" name ".zip")
     (button-success "Download for Windows"
		     (fa-windows))))


(define (coming-soon)
  (alert-primary "Coming soon!"))



