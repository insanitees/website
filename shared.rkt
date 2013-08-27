#lang racket
#|
This module provides bindings meant to be shared by all servlets, as well as defining the signature for a servlet
|#
(provide 
 ;; signature for a servlet
 servlet^
 if-enabled
 (contract-out
  ;; creates a page with a standard header 
  [make-page/c contract?]))

(require web-server/servlet/servlet-structs
         web-server/http/request-structs
         xml
         (for-syntax racket/file))

(define-signature servlet^
  ((contracted
    [path regexp?]
    [serve (-> request? make-page/c can-be-response?)])))

(define make-page/c (-> string? (and/c xexpr? (compose (curry equal? 'body) first))
                        can-be-response?))

(define-for-syntax settings-map
  (dynamic-require "settings.rkt" 'settings-map))

(define-for-syntax (get-setting v)
  (hash-ref settings-map v (lambda () #f)))

(define-syntax (if-enabled stx)
  (syntax-case stx ()
    [(_ v then else)
     (if (get-setting (syntax->datum #'v))
         #'then
         #'else)]))
  
     
