#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

;;загрузка и вывод картинки.
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

;; загрузка картинки
(define name-image "test-image.bmp")
(define image (SDL:load-bmp name-image))
(if (not (SDL:surface? image))
    (begin
      (display "Unable load bitmap. \n")
      (exit 1)))

;;создадим границы прямоугольников копирования
(define src (SDL:make-rect 0 0 (SDL:surface:w image) (SDL:surface:h image)))
(define dst (SDL:make-rect 0 0 (SDL:surface:w image) (SDL:surface:h image)))

;;копируем рисунок
(SDL:blit-surface image src screen dst)

;;	  (GFX:draw-point screen x y pixel_color)

;;(SDL:update-rect screen 0 0 s_width s_height)
(SDL:update-rect screen 0 0 0 0)
;;(SDL:flip)
(SDL:delay 16000)

(display "Sucess!\n")

(exit 0)
