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
(require syntax/parse/define
	 (for-syntax racket/format
		     racket/list))

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
(define-syntax
  (define-authored-work-lore stx)

  (syntax-parse
    stx
    [(_ 
       #:name name
       #:description description
       #:rune-collections rune-collections
       #:preview-image preview-image)
     #`(begin
         #,(define-media-from stx "images")
         (provide lore)
         (define lore
           (authored-work-lore
             name description preview-image rune-collections)))]
    )
  )

(define-syntax 
  (define-rune-collection-lore stx)

  (syntax-parse 
    stx
    [(_
       #:name name
       #:description description
       #:rune-lores rune-lores
       #:preview-image preview-image)
     #`(begin
	 #,(define-media-from stx "images")

	 (provide lore)
	 (define lore
	   (rune-collection-lore
	     name description preview-image rune-lores )))]))

;A constructor with keywords, for better readability in constructing rune lores
(define (make-rune-lore #:name name
			#:rune rune
			#:description description)
  (rune-lore name description rune))


(define-for-syntax 
  (define-media-from stx path)
  (define dir
    (apply build-path
	   (append
	     (drop-right (explode-path (syntax-source stx)) 1)
	     (list path))))

  (define files
    (directory-list dir))

  (define defs
    (map
      (lambda (f)
	;For each thing in path...
	; Define a media page and a website path
	(define-media-file stx 
			   dir 
			   (string->symbol (~a f))) )  
      files))

  #`(begin 
      #,(datum->syntax stx '(provide media))
      #,(datum->syntax stx '(define media
			      (list )))

      #,@defs
      ))

(provide next-media-id)
(define
  (next-media-id)
  (set! media-id (add1 media-id))
  media-id
  )

(define
  media-id
  0
  )

(define-for-syntax 
  (define-media-file ctx file-dir file-name) 
  (datum->syntax
    ctx
    `(begin
       (define ,file-name
	 (list
	   "lore-media" (~a (next-media-id)) 
	   (~a ',file-name)))

       (let ()
	 (define media-page
	   (page (identity ,file-name)
		 (build-path ,(~a file-dir "/" file-name))
		 #;
		 (apply build-path 
			(flatten
			  (list
			    ,file-dir
			    ,file-name)))))

	 (set! media
	   (cons media-page media))))))


