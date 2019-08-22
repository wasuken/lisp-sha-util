(in-package #:sha-util)

(defun rotate (x r)
  (logior (logand (ash x r) #xffffffff)
		  (ash x (- (- 32 r)))))

(defun str-repeat (str len)
  (let ((result ""))
	(dotimes (n len)
	  (setf result (concatenate 'string result str)))
	result))

(defun digest (str)
  (let* ((k (mapcar #'(lambda (x) (floor (* (sqrt (coerce x 'double-float)) (expt 2 30)))) '(2 3 5 10)))
		 (len (length str))
		 (m (reduce #'(lambda (acc x) (concatenate 'string acc x))
					(mapcar #'(lambda (x)
								(ppcre:regex-replace-all " " (format nil "~02x" (char-int x)) "0"))
							(coerce str 'list)))))
	(hash (concatenate 'string m
					   (concatenate 'string "80" (str-repeat "00" (mod (- (+ len 9)) 64))
									(ppcre:regex-replace-all " " (format nil "~16x" (* 8 len)) "0")))
		  k)))

(defun hash (msg k)
  (let ((h '(#x67452301 #xEFCDAB89 #x98BADCFE #x10325476 #xC3D2E1F0))
		(m msg))
	(loop until (string= m "")
	   do (let ((w '()))
			(dotimes (n 16)
			  (cond ((< (length m) 8)
					 (push (read-from-string (concatenate 'string "#x" (subseq m 0 (length m)))) w)
					 (setf m ""))
					(t
					 (push (read-from-string (concatenate 'string "#x" (subseq m 0 8))) w)
					 (setf m (subseq m 8)))))
			(setf w (reverse w))
			(dolist (i (mylib:range 16 79))
			  (setf w (append w (list (rotate (logxor
											   (logxor
												(logxor
												 (logxor (nth (- i 3) w))
												 (nth (- i 8) w))
												(nth (- i 14) w))
											   (nth (- i 16) w))
											  1)))))
			(setf h (main-loop h w k))
			(print h)))
	(format nil "~{~A~}"
			(mapcar #'(lambda (x)
						(string-downcase (ppcre:regex-replace-all " " (format nil "~8x" x) "0")))
					h))))


(defun main-loop (h w k)
  (let ((h-2 (copy-list h)))
	(dotimes (i 80)
	  (let ((f (cond ((<= i 19)
					  (logior (logand (nth 1 h-2) (nth 2 h-2))
							  (logand (boole boole-c1 (nth 1 h-2) 2) (nth 3 h-2))))
					 ((and (<= i 59) (>= i 40))
					  (logior (logand (nth 1 h-2) (nth 2 h-2))
							  (logand (nth 1 h-2) (nth 3 h-2))
							  (logand (nth 2 h-2) (nth 3 h-2))))
					 (t (logxor (nth 1 h-2) (nth 2 h-2) (nth 3 h-2))))))
		(loop for x in (list (logand (+ (rotate (nth 0 h-2) 5)
										(nth 4 h-2)
										f
										(nth (floor (/ i 20)) k)
										(nth i w))
									 #xffffffff)
							 (nth 0 h-2)
							 (rotate (nth 1 h-2) 30)
							 (nth 2 h-2)
							 (nth 3 h-2))
		   for j in (mylib:range 0 4)
		   do (progn
				(setf (nth j h-2) x)))))
	(loop for x in h-2
	   for j in (mylib:range 0 4)
	   do (progn
			(setf (nth j h-2) (logand (+ (nth j h) x) #xffffffff))))
	h-2))

(defun create-random-string ()
  (print (write-to-string (get-universal-time)))
  (digest (write-to-string (get-universal-time))))
