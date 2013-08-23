#lang racket
#|
This module provides values to handle paypal integration
|#
(provide
 (contract-out
  ;; resource constructor
  [resource (-> string? string? resource?)]
  ;; render a resource
  [render-resource (-> resource? xexpr?)]
  ;; get a buy-now button
  [buy-now-button make-paypal-button/c]
  ;; get an add-to-cart button
  [add-to-cart-button make-paypal-button/c]))

(require xml)

(define paypal-id "38RSLLJ9AKUNG")

(struct resource (name image-url) #:transparent)

(define make-paypal-button/c (-> string? (and/c number? real? (curry < 0)) xexpr?))
(define ((make-paypal-button file button-name) product-name amount)
  `(script ((src ,(~a "scripts/" file "?merchant=" paypal-id))
            (data-button ,button-name)
            (data-name ,product-name)
            (data-amount ,(~a amount)))))

(define (render-resource r)
  `(div ()
        ,(resource-name r)
        ,(buy-now-button (resource-name r) 1)
        ,(add-to-cart-button (resource-name r) 1)
        ,(resource-image-url r)))

(define buy-now-button
  (make-paypal-button "paypal-button.min.js" "buynow"))

(define add-to-cart-button 
  (make-paypal-button "paypal-button-minicart.min.js" "cart"))