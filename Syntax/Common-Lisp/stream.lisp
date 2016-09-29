(cl:in-package #:climacs-syntax-common-lisp)

(defclass analyzer-stream ()
  ((%analyzer :initarg :analyzer :reader analyzer)
   (%current-line :initform 0 :accessor current-line)
   (%current-column :initform 0 :accessor current-column)))

;;; Make sure that the first parse result that we consider recycling
;;; starts at or beyond the current stream position.  Parse results
;;; that start before the current stream position are either no longer
;;; valid, or have been recycled already, so we remove them.  Two
;;; places are considered for recycling, namely the list of residual
;;; parse results and the suffix.
(defun pop-to-stream-position (analyzer-stream)
  (let ((analyzer (analyzer analyzer-stream)))
    (loop until (or (null (residue analyzer))
		    (> (start-line (first (residue analyzer)))
		       (current-line analyzer-stream))
		    (and (= (start-line (first (residue analyzer)))
			    (current-line analyzer-stream))
			 (>= (start-column (first (residue analyzer)))
			     (current-column analyzer-stream))))
	  do (pop (residue analyzer)))
    (when (null (residue analyzer))
      (loop until (or (null (suffix analyzer))
		      (> (start-line (first (suffix analyzer)))
			 (current-line analyzer-stream))
		      (and (= (start-line (first (suffix analyzer)))
			      (current-line analyzer-stream))
			   (>= (start-column (first (suffix analyzer)))
			       (current-column analyzer-stream))))
	    do (pop-from-suffix analyzer)))))
