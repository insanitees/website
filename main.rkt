#lang racket
(require web-server/servlet
         web-server/servlet-env
         web-server/dispatchers/dispatch)
(require "shared.rkt")

;; run the server
(define (main)
  (serve/servlet 
   (dispatch (list under-construction@))
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
  (define servlet-map
    (for/hash ([serv^ servlets])
      (define-values/invoke-unit serv^
        (import)
        (export servlet^))
      (values path serve)))
  (define users (make-hash))
  (lambda (req)
    (define uri (path->string (url->path (request-uri req))))
    (define user (get-user! req users))
    (or 
     (for/first ([(rx serve) servlet-map] #:when (regexp-match? rx uri))
       (serve req user))
     (raise (exn:dispatcher)))))

;; request? [make-hash string? user?] -> user?
;; the the user for a key. make and add one if it doesn't exist
(define (get-user! req users)
  (define (make-user!)
    (define usr (user (~a (gensym 's))))
    (hash-set! users (user-session-id usr) usr)
    usr)
  (define key
    (match
      (bindings-assq
       #"session"
       (request-bindings/raw req))
    [(? binding:form? b)
     (string->number
      (bytes->string/utf-8
       (binding:form-value b)))]
      [_ #f]))
  (if key (hash-ref users key make-user!) (make-user!)))

;; test servlet^
(define-unit under-construction@
  (import)
  (export servlet^)

  (define (serve req _)
    (response/xexpr
     `(html (head (title "Libertees: Coming Soon")
                  (style ((type "text/css")) "p {text-align: center; font-size: 3em;}"))
            (body (p "Under Construction")))))
  (define path #rx".*"))

(main)