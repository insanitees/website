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

(define-unit paypal-callback@
  (import)
  (export servlet^)
  (define path #rx"/?paypal/?")
  (define (serve req? make-page)
    (make-page `(body ()))))

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