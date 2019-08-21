;; (require \'asdf)
 
 (in-package :cl-user)
 (defpackage sha-util-test-asd
 (:use :cl :asdf))
 (in-package :sha-util-test-asd)
 
 (defsystem sha-util-test
 :depends-on (:sha-util)
 :version "1.0.0"
 :author "wasu"
 :license "MIT"
 :components ((:module "t" :components ((:file "sha-util-test"))))
 :perform (test-op :after (op c)
 (funcall (intern #.(string :run) :prove) c)))

