;;;; 地圖太大發生bug
;;;; press any key will continue
;;;; until you press 'q'

(defpackage :game-of-life
  (:nicknames "GOF")
  (:use :cl
        :charms)
  (:export :main))
(in-package :game-of-life)

(setf *random-state* (make-random-state t))
(defvar *max-x* 40)
(defvar *max-y* 20)
(defvar *cell-symbol* #\O)

(defmacro refresh ()
  '(progn
    (refresh-window *standard-window*)))

(defun print-board (board)
  (with-restored-cursor *standard-window*
    (dotimes (i *max-x*)
      (dotimes (j *max-y*)
        (write-char-at-point *standard-window* (aref board i j) i j))))
    board)

(defun neighbours (board x y)
  (let ((sum 0))
    (do ((i (- x 1) (+ i 1)))
        ((> i (+ x 1)))
      (do ((j (- y 1) (+ j 1)))
          ((> j (+ y 1)))
        (unless (or (and (= i x) (= j y))
                    (< i 0) (>= i *max-x*)
                    (< j 0) (>= j *max-y*))
          (when (eql (aref board i j) *cell-symbol*)
            (incf sum)))))
    sum))

(defun next-generation (board)
  (let ((new-board (make-array (list *max-x* *max-y*)
                               :initial-element #\space)))
    (dotimes (i *max-x*)
      (dotimes (j *max-y*)
        (let ((sum (neighbours board i j)))
          (if (eql (aref board i j) *cell-symbol*)
              (if (or (< sum 2) (> sum 3))
                  (setf (aref new-board i j) #\space)
                  (setf (aref new-board i j) *cell-symbol*))
              (when (= sum 3)
                (setf (aref new-board i j) *cell-symbol*))))))
    new-board))

;; (defmacro with-board (&body body)
;;   `(let ((board (make-array (list *max-x* *max-y*)
;;                             :initial-element #\space)))
;;      (dotimes (i *max-x*)
;;        (dotimes (j *max-y*)
;;          (when (< 90 (random 100))
;;            (setf (aref board i j) *cell-symbol*))))
;;      ,@body))

(defun make-board ()
  (let ((board (make-array (list *max-x* *max-y*)
                            :initial-element #\space)))
     (dotimes (i *max-x*)
       (dotimes (j *max-y*)
         (when (< 80 (random 100))
           (setf (aref board i j) *cell-symbol*))))
     board))

(defun main ()
  (let ((board (make-board)))
    (with-curses ()
      (disable-echoing)

      (loop :named main-loop
         until (eql (charms:get-char charms:*standard-window*
                             :ignore-error t) #\q)
         do (progn
              (print-board board)
              (setf board (next-generation board))
              (refresh))))))

(main)
