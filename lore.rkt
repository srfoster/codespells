#lang racket 

(provide (all-from-out website-js)
	 (all-from-out racket/runtime-path)
	 (except-out (struct-out rune-lore) rune-lore)
	 (rename-out [make-rune-lore rune-lore])

	 (struct-out rune-collection-lore)
	 (struct-out authored-work-lore)
	 define-authored-work-lore
	 define-rune-collection-lore
	 
	 dynamic-require-lore)

(require website-js racket/runtime-path)

;Underlying structures for lore (aka documentation)

(define (dynamic-require-lore pkg-name)
  (dynamic-require (string->symbol (~a pkg-name "/lore")) 'lore))
 
(struct rune-lore            (name description rune) #:transparent)
(struct rune-collection-lore (name description preview-image rune-lores) #:transparent)
(struct authored-work-lore   (name description preview-image rune-collection-names) #:transparent)


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

(define (make-rune-lore #:name name
			#:rune rune
			#:description description)
  (rune-lore name description rune))


;For display of lore things

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



(require syntax/parse/define
	 website-js/components/accordion-cards
	 (for-syntax racket/syntax
		     racket/format))

(provide 
  authored-work-lore->preview-image/page 
  authored-work-lore->authored-work-card
  rune-collection-lore->rune-collection/page

  rune-collection-page
  build->build-card
  build->preview-image-page
  build-card
  download-button
  coming-soon)

(define (rune-collection-lore->rune-collection/page
	  path
	  lore
	  [wrapper identity])
  (page (identity path)
	(wrapper
	  (container
	    (h1 (rune-collection-lore-name lore))
	    (rune-collection-lore-description  lore)
	    (map
	      (lambda (r)
		;Firsts and seconds
		; are gross...
		;  Some kind of rune info struct (along with collection info and build info)
		(card (card-header
			(rune-lore-rune r)
			(h3 (rune-lore-name r)))
		      (card-body
			(rune-lore-description r))))
	      (rune-collection-lore-rune-lores lore))))))


(define-syntax (rune-collection-page stx)
  (syntax-parse stx
		[(_ prefix path wrapper)
		 #:with lore (format-id stx "~a:lore" #'prefix)
		 #`(page path
			 (wrapper
			   (container
			     (h1 (rune-collection-lore-name lore))
			     (rune-collection-lore-description  lore)
			     (map
			       (lambda (r)
				 ;Firsts and seconds
				 ; are gross...
				 ;  Some kind of rune info struct (along with collection info and build info)
				 (card (card-header
					 (rune-lore-rune r)
					 (h3 (rune-lore-name r)))
				   (card-body
				     (rune-lore-description r))))
			       (rune-collection-lore-rune-lores lore)))))]))

(define (authored-work-lore->preview-image/page path lore)
  (let ()
    (define preview-image
      (authored-work-lore-preview-image lore))
    (page (identity path)  
	  preview-image)))

;Maybe not macro?
; Get rid of prefix nonsense.  Maybe Lore->Page func
(define-syntax (build->preview-image-page stx)
  (syntax-parse stx
		[(_ prefix)
		 #:with lore (format-id stx "~a:lore" #'prefix)
		 #'(let ()
		     (define preview-image
		       (authored-work-lore-preview-image lore))
		     (page (list "builds" 
				 (~a 'prefix) 
				 "preview.png")
			   preview-image))
		 ]))



(define (authored-work-lore->authored-work-card pkg-name lore)
  (let ()
    (define name 
      (authored-work-lore-name lore))
    (define description
      (authored-work-lore-description lore))
    (define rune-collections
      (authored-work-lore-rune-collection-names lore))
    (define preview-image
      (authored-work-lore-preview-image lore))

    (build-card (h3 name) 
		(img class: "card-img-top"
		     src: (~a 
			    "builds/" (~a pkg-name)
			    "/preview.png"))
		(accordion-card #:header "Read More..."
				(h5 "Rune Collections")
				(map 
				  rune-collection-name->preview-icon 
				  rune-collections)
				(br)
				description
				)

		(hr)

		;Change on s3
		(download-button (~a pkg-name)))))

;Call authored work?
(define-syntax (build->build-card stx)
  (syntax-parse stx
		[(_ prefix)
		 #:with lore (format-id stx "~a:lore" #'prefix)

		 #`(let ()
		     (define name 
		       (authored-work-lore-name lore))
		     (define description
		       (authored-work-lore-description lore))
		     (define rune-collections
		       (authored-work-lore-rune-collection-names lore))
		     (define preview-image
		       (authored-work-lore-preview-image lore))


                     (build-card (h3 name) 
				 (img class: "card-img-top"
				      src: (~a 
					     "builds/" 'prefix"/preview.png"))
				 (accordion-card #:header "Read More..."
				   (h5 "Rune Collections")
				   (map 
				     rune-collection-name->preview-icon 
				     rune-collections)
                                   (br)
				   description
                                   )

				 (hr)

				 ;Change on s3
				 (download-button (symbol->string 'prefix)))) ]))


(define (build-card title img . content)
  (card
    (card-header title
		 img)
    (card-body content)))

(define (download-button name)
  (local-require website/bootstrap/font-awesome)
  (a href: (~a "https://codespells-org.s3.amazonaws.com/StandaloneBuilds/" name "/0.0/" name ".zip")
     (button-success "Download for Windows"
		     (fa-windows)
		     #;
		     (img:windows.svg width: 25 style: (properties margin-left: 5)))))


(define (coming-soon)
  (alert-primary "Coming soon!"))



