;; (require \'asdf)
 
 (in-package :cl-user)
 (defpackage sha-util-asd
 (:use :cl :asdf))
 (in-package :sha-util-asd)
 
 (defsystem :sha-util
 :version "1.0.0"
 :author "wasu"
 :license "MIT"
 :components ((:file "package")
 (:module "src" :components ((:file "sha-util")))))

