#lang racket
#|
This module provides values to handle paypal integration
|#
(provide
 (contract-out
  ;; get a buy-now button
  [buy-now-button make-paypal-button/c]
  ;; get an add-to-cart button
  [add-to-cart-button make-paypal-button/c]))

(require xml)

(define make-paypal-button/c (-> string? (and/c number? real? (curry < 0)) xexpr?))
(define ((make-paypal-button url button-name) product-name amount)
  `(script ((src (~a url paypal-id))
            (data-button button-name)
            (data-name product-name)
            (data-amount (~a amount)))))

(define buy-now-button
  (make-paypal-button "paypal-button.min.js?merchant=" "buynow"))

(define add-to-cart-button 
  (make-paypal-button "paypal-button-minicart.min.js?merchant=" "cart"))