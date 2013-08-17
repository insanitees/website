#lang racket
(require "shared.rkt" "paypal-credentials.rkt")

(define-unit paypal-callback
  (import)
  (export servlet^)
  (define path #rx"/?paypal/?")
  (define (serve req? make-page)
    (make-page `(body ()))))

(define buy-now-button
  (make-paypal-button "paypal-button.min.js?merchant=" "cart"))

(define add-to-cart-button 
  (make-paypal-button "paypal-button-minicart.min.js?merchant=" "cart"))

(define ((make-paypal-button url button-name) product-name amount)
  `(script ((src (~a url paypal-id))
            (data-button button-name)
            (data-name product-name)
            (data-amount (~a amount)))))