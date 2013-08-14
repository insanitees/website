#lang racket
#|
This module provides bindings meant to be shared by all servlets, as well as defining the signature for a servlet
|#
(provide 
 ;; signature for a servlet
 servlet^
 (contract-out
  ;; user struct
  [user (-> string? user?)]
  [user? (-> any/c boolean?)]
  [user-session-id (-> user? string?)]))

(require web-server/servlet/servlet-structs
         web-server/http/request-structs)

(define-signature servlet^
  ((contracted
    [path regexp?]
    [serve (-> request? user? can-be-response?)])))

(struct user (session-id) #:transparent)