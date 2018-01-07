(defpackage :snake-asd
  (:use :cl
        :asdf))
(in-package :snake-asd)

(defsystem #:snake
    :version "0.1"
    :name "snake"
    :author "Hsu"
    :license "MIT License"
    :depends-on (:cl-charms)
    :serial t
    :components ((:file "main")))
