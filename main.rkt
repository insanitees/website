#lang racket
(require web-server/servlet
         web-server/servlet-env)
 
(define (start req)
  (response/xexpr
   `(html (head (title "Libertees: Coming Soon"))
          (body (p "Under Construction")))))
 
(serve/servlet start
               #:listen-ip #f
               #:servlet-regexp #rx""
               #:port 5674
               #:quit #f
               #:stateless #t
               #:launch-browser? #f
               #:banner #f)