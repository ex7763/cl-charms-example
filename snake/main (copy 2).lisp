;;;; TODO
;;;; Auto move
;;;; score
(setf *random-state* (make-random-state t))
(defpackage snake
  (:use :cl
        :cl-user
        ;:charms/ll
        :charms)
  (:export :main))
(in-package :snake)

(defvar *max-x* 20)
(defvar *max-y* 10)
(defvar *x* 1)
(defvar *y* 1)
(defvar *in*)
(defvar *food* '(-1 -1))
(defvar *direction* #\k)
(defvar *delay-time* 0.05)

;;   no object
;; Q snake head
;; = snake body
;; E food
(defvar *map* (make-array (list *max-x* *max-y*) :initial-element #\space))
(defvar *body* (list (list *x* *y*) (list *x* (+ *y* 1))))

(defun body-x (n)
  (car (nth n *body*)))

(defun body-y (n)
  (cadr (nth n *body*)))

(defun food-x ()
  (car *food*))

(defun food-y ()
  (cadr *food*))

;; Refresh the window
(defmacro refresh ()
  '(progn
    (sleep *delay-time*)
    (refresh-window *standard-window*)))

;; Can't pass wal
;; (defun check-cursor ()
;;   (if (<= *x* 0)
;;       (setf *x* 0))
;;   (if (>= *x* (- *max-x* 1))
;;       (setf *x* (- *max-x* 1)))
;;   (if (<= *y* 0)
;;       (setf *y* 0))
;;   (if (>= *y* (- *max-y* 1))
;;       (setf *y* (- *max-y* 1))))

;; Can pass wall
(defun check-cursor ()
  (setf *x* (mod *x* *max-x*))
  (setf *y* (mod *y* *max-y*)))

(defun print-map (win)
  (with-restored-cursor win
    (dotimes (i *max-x*)
      (dotimes (j *max-y*)
        (write-char-at-point win (aref *map* i j) i j)))
    (write-char-at-point win #\E (food-x) (food-y))))

(defun print-snake (win)
  (with-restored-cursor win
    (dotimes (i (length *body*))
      (write-char-at-point win #\= (car (nth i *body*)) (cadr (nth i *body*)))))
  (write-char-at-cursor win #\Q))

(defun move-snake (eat-or-not)
  (if (and (= *x* (body-x 0)) (= *y* (body-y 0)))
      (return-from move-snake nil)
      (progn
        (if (not eat-or-not)
            (setf *body* (subseq *body* 0 (- (length *body*) 1))))
        (push (list *x* *y*) *body*))))

(defmacro control (in)
  `(progn
     (case ,in
       ((nil) nil)
       ((#\q) (return))
       ((#\k) (progn
                (setf *direction* #\k)
                (decf *y*)))
       ((char-code #\j) (progn
                (setf *direction* #\j)
                (incf *y*)))
       ((char-code (#\h)) (progn
                (setf *direction* #\h)
                (decf *x*)))
       ((#\l) (progn
                (setf *direction* #\l)
                (incf *x*)))
       (otherwise (case *direction*
                    ((#\k) (progn
                             (setf *direction* #\k)
                             (decf *y*)))
                    ((#\j) (progn
                             (setf *direction* #\j)
                             (incf *y*)))
                    ((#\h) (progn
                             (setf *direction* #\h)
                             (decf *x*)))
                    ((#\l) (progn
                             (setf *direction* #\l)
                             (incf *x*))))))
     
     (check-cursor)
     (move-snake (eat-food))
     (move-cursor *standard-window* *x* *y*)))

(defun check-crash ()
  (dotimes (i (- (length *body*) 1))
    (if (and (= (body-x 0) (body-x (+ i 1)))
             (= (body-y 0) (body-y (+ i 1))))
        (return-from check-crash t)))
  nil)

(defun create-food ()
  (let ((x (random *max-x*))
        (y (random *max-y*)))
    (if (> (food-x) -1)
        nil
        (if (and (= (body-x 0) x) (= (body-y 0) y))
            (create-food)
            (setf *food* (list x y))))))

(defun eat-food ()
  (if (and (= *x* (food-x)) (= *y* (food-y)))
      (progn
        (setf *food* '(-1 -1))
        t)
      nil))

(defun reset ()
  (setf *x* 0)
  (setf *y* 0)
  (setf *food* '(-1 -1))
  (setf *body* (list (list *x* *y*) (list *x* (+ *y* 1)))))

(defmacro gameover ()
  '(if (check-crash)
    (progn
      (sleep 2)
      (reset)
      (return))))

(defun main ()
  (with-curses ()
    (disable-echoing)
    (enable-raw-input :interpret-control-characters t)
    (enable-non-blocking-mode *standard-window*)
    ;(enable-extra-keys *standard-window*)
    ;(charms/ll:cbreak)
    (charms/ll:curs-set 0)

    (do ((in (charms/ll:getch) (charms/ll:getch)))
        ((= in (char-code #\q)))
      (progn
            (control in)
           
            (create-food)
            (print-map *standard-window*)
            (print-snake *standard-window*)
            (gameover)
            (refresh)))))
