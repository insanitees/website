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
(struct in:user user ([time #:mutable]) #:transparent)

;; run the server
(define (launch . units)
  (serve/servlet 
   (dispatch units)
   #:servlets-root (current-directory)
   #:extra-files-paths (list (build-path (current-directory) "scripts"))
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
  (define users (make-hash))
  (launch-session-cleaning users)
  (lambda (req)
    (define path (path->string (url->path (request-uri req))))
    (or 
     (for/first ([(rx serve) servlet-map] #:when (regexp-match? rx path))
       (define user (get-user! req users))
       (displayln users)
       (serve req (make-page-maker user) user))
     (raise (exn:dispatcher)))))

;; [listof servlet^] -> [hash regexp? (-> request? make-page/c user? may-be-request?)]
;; creates the servlet map, involking all the units
(define (make-servlet-map servlets)
  (for/hash ([serv^ servlets])
    (define-values/invoke-unit serv^
      (import)
      (export servlet^))
    (values path serve)))

;; [make-hash string? in:user?] -> thread?
;; launch the thread to clean out old users
(define (launch-session-cleaning users)
  (thread 
   (thunk
    (let loop ()
      (sync/timeout 60 never-evt)
      (for-each (lambda (u) (and (> (- (current-seconds) (in:user-time u)) SESSION-LIFETIME)
                                 (hash-remove! users (user-session-id u))))
        (hash-values users))
      (loop)))))

;; make the function that builds a standard header for a page
;; user? -> make-page/c
(define ((make-page-maker user) title body)
  (response/xexpr
   #:cookies (list (make-cookie SESSION-KEY (user-session-id user)))
   `(html (head (title ,(~a title " for " (user-session-id user)))
                (style ((type "text/css")) "p {text-align: center; font-size: 3em;}"))
          ,body)))

;; request? [make-hash string? user?] -> user?
;; the the user for a key. make and add one if it doesn't exist
(define (get-user! req users)
  (define (make-user!)
    (define usr (in:user (~a (gensym 's)) (current-seconds)))
    (hash-set! users (user-session-id usr) usr)
    usr)
  (define key 
    (client-cookie-value
     (findf (lambda (c) (string=? SESSION-KEY (client-cookie-name c)))
            (request-cookies req))))
  (define usr (if key (hash-ref users key make-user!) (make-user!)))
  (set-in:user-time! usr (current-seconds))
  usr)