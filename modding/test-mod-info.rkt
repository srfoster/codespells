#lang racket

(provide mod-name pak-folder main.rkt)

(require racket/runtime-path)

(define
  mod-name
  "TestMod")

(define-runtime-path
  pak-folder
  "BuildUnreal/WindowsNoEditor/TestMod/Content/Paks/")

(define-runtime-path
  main.rkt
  "main.rkt")
