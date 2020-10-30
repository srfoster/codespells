#lang racket

(require "./lib.rkt"
         raco/command-name
         file/zip
         aws/keys
         aws/s3
         setup/getinfo)

(define skip-zip? (make-parameter #f))

(command-line
   #:program (short-program+command-name)
   #:once-each
   [("-z" "--skip-zip") "Skip zipping BuildUnreal/"
                        (skip-zip? #t)])

;Zip BuildUnreal

(when (not (skip-zip?))
  (displayln "Zipping BuildUnreal")
  (when (file-exists? "BuildUnreal.zip")
    (delete-file "BuildUnreal.zip"))
  (zip "BuildUnreal.zip" "BuildUnreal"))

;Find S3 credentials

(displayln "Pushing to S3")
(aws-cli-credentials (build-path (find-system-path 'home-dir) ".awscreds"))
(credentials-from-file!)

(define info (get-info/full (current-directory)))

(define (url->bucket+path url)
  ;Assuming a url like: "https://codespells-org.s3.amazonaws.com/ModBuilds/fire-particles/0.0/BuildUnreal.zip"
  (define parts (string-split url "."))
  (define http://bucket-name (first parts))
  (define bucket-name (last (string-split http://bucket-name "/")))

  (define path (last (string-split url ".com")))

  (string-append bucket-name path))


(put/file (url->bucket+path (info 'release-url)) ;I guess we assume the region for now
          (build-path "BuildUnreal.zip"))

;Push BuildUnreal.zip to s3

;Record where it was pushed (or assume a convention), so it can be found for installations/updates

(displayln "Released!  You may want to push your mod to github now -- or wherever you are hosting your Racket package.")