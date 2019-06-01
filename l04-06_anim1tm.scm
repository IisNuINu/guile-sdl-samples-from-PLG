#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

;;анимация - первая попытка.
;;


(setenv "LTDL_LIBRARY_PATH" "/usr/local/lib/guile-sdl")
(use-modules ((sdl sdl) #:prefix SDL:)
	     ((sdl gfx) #:prefix GFX:)
             (srfi srfi-1)
             (srfi srfi-2))

(define (c-atexit proc)
  (let ((old-exit exit))
    (set! exit (lambda args
		 (display "atexit\n")
		 (proc)
		 (apply old-exit args)))))

(define (make-color format r g b alpha)
  ;;map-rgb, map-rgba почему то не работают сформируем цвета в ручную
  (logior alpha (ash (logior b (ash (logior g (ash r 8)) 8)) 8)))


(define NUM_PENGUINS 100)
(define MAX_SPEED    6)

(define (make-penguin x y dx dy)
  (cons (cons x y)
	(cons dx dy)))

(define (penguin:x p)
  (caar p))
(define (penguin:y p)
  (cdar p))
(define (penguin:dx p)
  (cadr p))
(define (penguin:dy p)
  (cddr p))

(define (penguin-print p)
  (display (string-append
	    "x: "    (number->string (penguin:x p))
	    ", y: "  (number->string (penguin:y p))
	    ", dx: " (number->string (penguin:dx p))
	    ", dy: " (number->string (penguin:dy p)) "\n")))
;;(define p (make-penguin 15 12 3 4))
;;(penguin-print p)

;; initialize the video subsystem
(if (not (equal? (SDL:init 'video) 0))
    (begin
      (display "Can't initialize SDL!\n")
      (exit 1)))
(c-atexit (lambda ()
	    (display "SDL:quit\n")
	    (SDL:quit)))

;;(define screen (SDL:set-video-mode 640 480 16 'fullscreen))
(define s_width 640)
(define s_height 480)
(define screen (SDL:set-video-mode s_width s_height 16))
(if (not (SDL:surface? screen))
    (begin
      (display "Can't set videomode\n")
      (exit 1)))

;;инициализация списка пигвинов
(define (init_penguins)
  (let ((i 0) (penguins '()))
    (do ((i 0 (+ i 1)))
	((>= i NUM_PENGUINS))
      (set! penguins
	    (cons
	     (make-penguin
	      (random s_width (random-state-from-platform))
	      (random s_height (random-state-from-platform))
	      (- (random (* MAX_SPEED 2) (random-state-from-platform)) MAX_SPEED)
	      (- (random (* MAX_SPEED 2) (random-state-from-platform)) MAX_SPEED))
	     penguins)))
    penguins))


;;перемещение пингвинов
;; перемещение одного пингвина
(define (move_penguin p surface)
  (let ((x 0) (y 0) (dx (penguin:dx p)) (dy (penguin:dy p)))
    (set! x (+ (penguin:x p) dx))
    (set! y (+ (penguin:y p) dy))
    (if (or (< x 0)
	    (> x (- (SDL:surface:w surface) 1)))
	(set! dx (- dx))) 
    (if (or (< y 0)
	    (> y (- (SDL:surface:h surface) 1)))
	(set! dy (- dy)))
    (make-penguin x y dx dy)))

;; перемещение всего списка
;;возвращает список перемещенных пингвинов.
(define (move_penguins penguins surface)
  (map (lambda (p) (move_penguin p surface)) penguins))

;; рисуем пингвинов на экране
(define (draw_penguins penguins image surface)
  (let ((src (SDL:make-rect 0 0 (SDL:surface:w image) (SDL:surface:h image)))
	(dst (SDL:make-rect 0 0 (SDL:surface:w image) (SDL:surface:h image)))
	(half_w (quotient (SDL:surface:w image) 2))
	(half_h (quotient (SDL:surface:h image) 2)))
    (for-each (lambda (p) 
		(SDL:rect:set-x! dst (- (penguin:x p) half_w))
		(SDL:rect:set-y! dst (- (penguin:y p) half_h))
		(SDL:blit-surface  image  src surface dst))
	      penguins)))

;; загрузка картинки
(define (load-check-img name-image)
  (let ((image (SDL:load-image name-image)))
    (if (not (SDL:surface? image))
	(begin
	  (display (string-append "Unable load image:" name-image "\n"))
	  (exit 1)))
    image))

(define (load-check-bmp name-image)
  (let ((image (SDL:load-bmp name-image)))
    (if (not (SDL:surface? image))
	(begin
	  (display (string-append "Unable load image:" name-image "\n"))
	  (exit 1)))
    image))

;;грузим изображения
(define background (load-check-bmp "bg.bmp"))
(define penguin-image (load-check-bmp "smallpenguin.bmp"))

;;зададим colorkey для изображения пингвина
(define format-image (SDL:surface-get-format penguin-image))
(define colorkey (SDL:map-rgb format-image 0 0 255))
(SDL:surface-color-key! penguin-image colorkey)

;;сгененируем пингвинов
(define penguins (init_penguins))

;;приступим к анимации

;;создадим границы прямоугольников копирования
(define src (SDL:make-rect 0 0 (SDL:surface:w background) (SDL:surface:h background)))
(define dst (SDL:make-rect 0 0 (SDL:surface:w background) (SDL:surface:h background)))

(define MAX_CYCLES 1300)

(define start-time (gettimeofday))
(let ((i 0))
  (do ((i 0 (+ i 1)))
      ((>= i MAX_CYCLES))
    (begin
      (SDL:blit-surface background src screen dst)       ;;рисуем фон
      (draw_penguins  penguins  penguin-image screen)    ;;рисуем пингвинов
      (SDL:update-rect screen 0 0 0 0)                   ;; отображаем все на экране
      (set! penguins (move_penguins penguins screen))))) ;; перемещаем пингвинов.

(define end-time (gettimeofday))
(define delta-mks (+ (* 1000000 (- (car end-time) (car start-time)))
		     (- (cdr end-time) (cdr start-time))))
(define mks-per-cadr (quotient delta-mks MAX_CYCLES))
(define cadr-in-sec  (quotient 1000000 mks-per-cadr))
(display (string-append "All time execute: " (number->string delta-mks)
			"mks, mks per cadr: " (number->string mks-per-cadr)
			"mks, Cadr in sec: " (number->string cadr-in-sec) "\n"))

;;	  (GFX:draw-point screen x y pixel_color)
;;(SDL:update-rect screen 0 0 s_width s_height)
;;(SDL:flip)

(display "Sucess!\n")

(exit 0)
