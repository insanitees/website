#lang racket
(require "dispatch.rkt" "shared.rkt")

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
  (define (serve req make-page)
    (make-page 
     "Its a List!!!"
     `(body
       ,@(fold-files (lambda (f t l) 
                       (if (not (equal? t 'file))
                           l
                           (cons (file->value f) l)))
                     null
                     (build-path (current-directory) "list-test"))))))
                     

(launch list@ under-construction@)