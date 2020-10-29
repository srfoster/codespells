#lang racket

(require "./lib.rkt"
         raco/command-name
         file/zip
         aws/keys
         aws/s3
         setup/getinfo)

;Zip BuildUnreal

#|
(displayln "Zipping BuildUnreal")
(when (file-exists? "BuildUnreal.zip")
  (delete-file "BuildUnreal.zip"))
(zip "BuildUnreal.zip" "BuildUnreal")
|#

;Find S3 credentials

(displayln "Pushing to S3")
(aws-cli-credentials (build-path (find-system-path 'home-dir) ".awscreds"))
(credentials-from-file!)


(define info (get-info/full (current-directory)))

(put/file (info 'release-s3-bucket) ;I guess we assume the region for now
          (build-path "BuildUnreal.zip")
          )

;Push BuildUnreal.zip to s3

;Record where it was pushed (or assume a convention), so it can be found for installations/updates

(displayln "Released!  You may want to push your mod to github now -- or wherever you are hosting your Racket package.")