#lang racket
#|
This module provides bindings meant to be shared by all servlets, as well as defining the signature for a servlet
|#
(provide 
 ;; signature for a servlet
 servlet^
 ;; our exceptions
 (struct-out exn:insanitees)
 (struct-out exn:insanitees:bad-paypal-IPN)
 (contract-out
  ;; creates a page with a standard header 
  [make-page/c contract?]
  [debug (parameter/c boolean?)]))

(require web-server/servlet/servlet-structs
         web-server/http/request-structs
         xml)

(define-signature servlet^
  ((contracted
    [path regexp?]
    [serve (-> request? make-page/c can-be-response?)])))

(define make-page/c (-> string? (and/c xexpr? (compose (curry equal? 'body) first))
                        can-be-response?))

(define debug (make-parameter #f))

(struct exn:insanitees exn () #:transparent)
(struct exn:insanitees:bad-paypal-IPN exn:insanitees (req) #:transparent)