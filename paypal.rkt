#lang racket
#|
This module provides values to handle paypal integration
|#
(provide
 (contract-out
  ;; servlet to handle paypal callback
  [paypal-callback@ (unit/c (import) (export servlet^))]
  ;; get a buy-now button
  [buy-now-button make-paypal-button/c]
  ;; get an add-to-cart button
  [add-to-cart-button make-paypal-button/c]))

(require "shared.rkt" "paypal-credentials.rkt" xml)
(require web-server/http/request-structs)
(require net/url)

(define make-paypal-button/c (-> string? (and/c number? real? (curry < 0)) xexpr?))
(define ((make-paypal-button url button-name) product-name amount)
  `(script ((src (~a url paypal-id))
            (data-button button-name)
            (data-name product-name)
            (data-amount (~a amount)))))

(define buy-now-button
  (make-paypal-button "paypal-button.min.js?merchant=" "cart"))

(define add-to-cart-button 
  (make-paypal-button "paypal-button-minicart.min.js?merchant=" "cart"))

(define-unit paypal-callback@
  (import)
  (export servlet^)
  (define path #rx"/?paypal/?")
  
  ;; see https://developer.paypal.com/webapps/developer/docs/classic/ipn/integration-guide/IPNIntro/
  ;; for callback information
  (define (serve req make-page)
    (if (verify req)
        (handle-valid-IPN-request req)
        (raise-bad-paypal-IPN req)))
  
  (define (handle-valid-IPN-request req)
    #f)
  
  ;; request? -> boolean?
  ;; could we validate the IPN message
  (define (verify req)
    ;; todo: validate https certs
    (define req-uri (request-uri req))
    (define validate-url
      (struct-copy url req-uri
                   [query (cons (cons 'cmd "_notify-validate")
                                (url-query req-uri))]
                   [path (list (path/param "cgi-bin" empty) (path/param "webscr" empty))]
                   [host "www.sandbox.paypal.com"]
                   [scheme "https"]))
    (define resp (port->string (get-pure-port validate-url)))
    (equal? resp "VALID"))
  
  #;(define (get-reciever-information req)
    )
  #;(define (get-transaction-information req)
    )
  #;(define (get-buyer-info req)
    )
  ;; request? -> string?
  ;; get raw string of the address
  #;(define (get-address req)
    )
  #;(define (get-payment-info req)
    )
  
  ;; request bytes (-> bytes A) -> (maybe A)
  (define (load-binding req key convert)
    (define raw-binding
      (bindings-assq key (request-bindings/raw req)))
    (match key 
      [(? binding:form? b)
       (convert (binding:form-value b))]
      [_ #f])))