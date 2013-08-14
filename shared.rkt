#lang racket
#|
This module provides bindings meant to be shared by all servlets, as well as defining the signature for a servlet
|#
(provide 
 ;; signature for a servlet
 servlet^
 (contract-out
  ;; creates a page with a standard header 
  [make-page/c contract?]
  ;; user struct
  [user (-> bytes? user?)]
  [user? (-> any/c boolean?)]
  [user-session-id (-> user? bytes?)]))

(require web-server/servlet/servlet-structs
         web-server/http/request-structs
         xml)

(define-signature servlet^
  ((contracted
    [path regexp?]
    [serve (-> request? make-page/c user? can-be-response?)])))

(define make-page/c (-> string? (and/c xexpr? (λ (x) (equal? (first x) 'body))) can-be-response?))

(struct user (session-id) #:transparent)