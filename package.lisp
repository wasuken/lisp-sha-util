;; (in-package :cl-user)
(defpackage sha-util
  (:use :cl)
  (:export :digest :rotate :main-loop :create-random-string))
