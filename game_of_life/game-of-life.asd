(defpackage :game-of-life-asd
  (:use :cl
        :asdf))
(in-package :game-of-life-asd)

(defsystem #:game-of-life
    :version "0.1"
    :name "game-of-life"
    :author "Hsu"
    :license "MIT License"
    :depends-on (:cl-charms)
    :serial t
    :components ((:file "main")))
