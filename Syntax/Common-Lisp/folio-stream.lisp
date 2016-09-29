(cl:in-package #:climacs-syntax-common-lisp)

;;; A folio stream is a stream that uses a folio as a source for the
;;; items to return as a result of reading.
(defclass folio-stream ()
  ((%folio :initarg :folio :reader folio)
   (%current-line-number :initform 0 :accessor current-line-number)
   (%current-item-number :initform 0 :accessor current-item-number)))

(defgeneric next-position (folio line-number item-number))

(defmethod next-position ((folio folio) line-number item-number)
  (if (= (line-length folio line-number) item-number)
      (values (1+ line-number) 0)
      (values line-number (1+ item-number))))

(defgeneric previous-position (folio line-number item-number))

(defmethod previous-position ((folio folio) line-number item-number)
  (if (zerop item-number)
      (values 0 (line-length folio (1- line-number)))
      (values line-number (1- item-number))))

(defgeneric eof-p (folio-stream))

(defmethod eof-p ((stream folio-stream))
  (let* ((folio (folio stream))
	 (last-line-number (1- (line-count (folio stream))))
	 (last-line-length (line-length folio last-line-number)))
    (and (= (current-line-number stream) last-line-number)
	 (= (current-item-number stream) last-line-length))))

(defgeneric forward (folio-stream))

(defmethod forward ((stream folio-stream))
  (with-accessors ((folio folio)
		   (current-line-number current-line-number)
		   (current-item-number current-item-number))
      stream
    (multiple-value-bind (l c)
	(next-position folio current-line-number current-item-number)
      (setf current-line-number l)
      (setf current-item-number c))))

(defgeneric backward (folio-stream))

(defmethod backward ((stream folio-stream))
  (with-accessors ((folio folio)
		   (current-line-number current-line-number)
		   (current-item-number current-item-number))
      stream
    (multiple-value-bind (l c)
	(previous-position folio current-line-number current-item-number)
      (setf current-line-number l)
      (setf current-item-number c))))

(defmethod trivial-gray-streams:stream-read-char ((stream folio-stream))
  (if (eof-p stream)
      :eof
      (with-accessors ((folio folio)
		       (current-line-number current-line-number)
		       (current-item-number current-item-number))
	  stream
	(prog1 (if (= (line-length folio current-line-number)
		      current-item-number)
		   #\Newline
		   (item folio current-line-number current-item-number))
	  (forward stream)))))

(defmethod trivial-gray-streams:stream-unread-char ((stream folio-stream) char)
  (declare (ignore char))
  (backward stream))