#lang racket
(require "dispatch.rkt" "shared.rkt")

;; test servlet^
(define-unit under-construction@
  (import)
  (export servlet^)
  
  (define (serve req make-page _)
    (make-page
     "Libertees: Coming Soon"
    `(body (p "Under Construction"))))
  (define path #rx".*"))

(launch under-construction@)