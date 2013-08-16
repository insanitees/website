#lang racket
#|
this module provides bindings to launch the server
|#
(provide 
 (contract-out
  [launch (->* ()
               #:rest (cons/c (unit/c (import) (export servlet^))
                              (listof (unit/c (import) (export servlet^))))
               any)]))
(require web-server/servlet
         web-server/servlet-env
         web-server/dispatchers/dispatch)
(require "shared.rkt")

(define SESSION-KEY "session")
(define SESSION-LIFETIME (* 60 60 24)) ;; a day in seconds

;; run the server
(define (launch . units)
  (serve/servlet 
   (dispatch units)
   #:servlets-root (current-directory)
   #:extra-files-paths (list (build-path (current-directory) "styles"))
   #:servlet-path ""
   #:listen-ip #f
   #:servlet-regexp #rx""
   #:port 5674
   #:quit? #f
   #:stateless? #t
   #:launch-browser? #f
   #:banner? #f))

;; [listof servlet^] -> (-> request? may-be-responce?)
;; make the dispatcher for main
(define (dispatch servlets)
  (define servlet-map (make-servlet-map servlets))
  (lambda (req)
    (define path (path->string (url->path (request-uri req))))
    (or 
     (for/first ([(rx serve) servlet-map] #:when (regexp-match? rx path))
       (serve req page-maker))
     (raise (exn:dispatcher)))))

;; [listof servlet^] -> [hash regexp? (-> request? make-page/c user? may-be-request?)]
;; creates the servlet map, involking all the units
(define (make-servlet-map servlets)
  (for/hash ([serv^ servlets])
    (define-values/invoke-unit serv^
      (import)
      (export servlet^))
    (values path serve)))

;; make the function that builds a standard header for a page
;; user? -> make-page/c
(define (page-maker title body)
  (response/xexpr
   `(html (head (title ,title)
                (link ((rel "stylesheet") (type "text/css") (href "main.css"))))
          ,body)))