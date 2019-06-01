#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

;;Рисование пикселов на поверхности screen
;;

;; к сожалению прямого доступа к памяти экрана(поверхности) библиотека не предоставляет
;; SDL:surface-pixels возвращает лишь копию экрана которую можно менять, но толку от
;; этого никакого нет!

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
;;(number->string (make-color #xfa #xef 0 0 #xff) 16)  ;; red
;;(number->string (make-color #xfa 0 #xef 0 #xff) 16)  ;; green
;;(number->string (make-color #xfa 0 0 #xef #xff) 16)  ;; blue

;; initialize the video subsystem
(if (not (equal? (SDL:init 'video) 0))
    (begin
      (display "Can't initialize SDL!\n")
      (exit 1)))
(c-atexit (lambda ()
	    (display "SDL:quit\n")
	    (SDL:quit)))

;;(define screen (SDL:set-video-mode 640 480 16 'fullscreen))
(define s_width 256)
(define s_height 256)
(define screen (SDL:set-video-mode s_width s_height 16))
(if (not (SDL:surface? screen))
    (begin
      (display "Can't set videomode\n")
      (exit 1)))

;;(SDL:lock-surface screen)

(define screen-format (SDL:surface-get-format screen))
(display screen-format)(newline)
(define screen-pitch (SDL:surface:w screen))

;;(define pixel_color (SDL:map-rgb screen-format (SDL:make-color 0 0 255))) ;;blue
;;(SDL:fill-rect screen #f pixel_color)

;;cycle pixel set to surface screen
(let ((x 0) (y 0) (offset 0) (pixel_color 0) (alpha 255) (r 0) (g 0) (b 0))
  (do ((x 0 (+ x 1)))
      ((>= x s_width))
    (begin
      (do ((y 0 (+ y 1)))
	  ((>= y s_height))
	(begin
	  (set! r x)
	  (set! b y)
	  ;;(set! pixel_color (SDL:make-color r g b))
	  ;;(set! pixel_color_a (SDL:map-rgba screen-format r g b 255))
	  ;;(set! pixel_color (SDL:map-rgb screen-format r g b))
	  ;;(set! pixel_color #xff0000ff)    ;;Red color
	  ;;(set! offset (+ (* screen-pitch y) x))
	  (set! pixel_color (make-color screen-format r g b alpha))
	  (if (equal? x y)
	      (begin
		(display (string-append "x: " (number->string x) ", y: " (number->string y)
					", color: " (number->string pixel_color 16) "\n"))))
	  (GFX:draw-point screen x y pixel_color)
	  ))
      )))

;;(SDL:unlock-surface screen)
;;(SDL:update-rect screen 0 0 s_width s_height)
(SDL:update-rect screen 0 0 0 0)
;;(SDL:flip)
(SDL:delay 16000)

(display "Sucess!\n")

(exit 0)
