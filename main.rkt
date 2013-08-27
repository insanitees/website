#lang racket
(require "dispatch.rkt" "shared.rkt" [prefix-in paypal: "paypal.rkt"])

;; test servlet^
(define-unit under-construction@
  (import)
  (export servlet^)
  
  (define (serve req make-page)
    (make-page
     "Libertees: Coming Soon"
    `(body (p "Under Construction"))))
  (define path #rx"^/\\.$"))

(define-unit list@
  (import)
  (export servlet^)
  (define path #rx"^/list")
  (define (map-files func p)
    (fold-files (lambda (f t l)
                  (if (not (equal? t 'file))
                      l
                      (cons (func f) l)))
                null
                p)) 
  (define (serve req make-page)
    (make-page 
     "Its a List!!!"
     `(body
       ,@(map-files (lambda (f) (paypal:render-resource (apply paypal:resource (file->value f))))
                    (build-path (current-directory) "resources/paypal"))))))
                     
(define servlets
  `(,under-construction@
    ,@(if-enabled debug (list list@) null)))
(apply launch servlets)