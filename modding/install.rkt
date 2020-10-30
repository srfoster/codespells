#lang at-exp racket

(require codespells setup/getinfo file/unzip)

(displayln "Installing")

(define info (get-info/full (current-directory)))

(dl (info 'release-url)
    "BuildUnreal.zip")

(unzip "BuildUnreal.zip")