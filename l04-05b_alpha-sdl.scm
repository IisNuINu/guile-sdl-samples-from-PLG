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
(define s_width 640)
(define s_height 480)
(define screen (SDL:set-video-mode s_width s_height 16))
(if (not (SDL:surface? screen))
    (begin
      (display "Can't set videomode\n")
      (exit 1)))

;; загрузка картинки
(define (load-check-bmp name-image)
  (let ((image (SDL:load-bmp name-image)))
    (if (not (SDL:surface? image))
	(begin
	  (display (string-append "Unable load bitmap:" name-image "\n"))
	  (exit 1)))
    image))

(define background (load-check-bmp "bg.bmp"))
(define image (load-check-bmp "tux.bmp"))

;;создадим границы прямоугольников копирования
(define src (SDL:make-rect 0 0 (SDL:surface:w background) (SDL:surface:h background)))
(define dst (SDL:make-rect 0 0 (SDL:surface:w background) (SDL:surface:h background)))

;;рисуем фон
(SDL:blit-surface background src screen dst)

;;рисуем пингвина без использования colorkey:
(SDL:rect:set-x! src 0)
(SDL:rect:set-y! src 0)
(SDL:rect:set-w! src (SDL:surface:w image))
(SDL:rect:set-h! src (SDL:surface:h image))

(SDL:rect:set-x! dst 30)
(SDL:rect:set-y! dst 90)
(SDL:rect:set-w! dst (SDL:surface:w image))
(SDL:rect:set-h! dst (SDL:surface:h image))

(SDL:blit-surface image src screen dst)

;;пингвин сохранен с использованием голубого цвета в качестве фона создадим подобный ему
;; colorkey
(define format-image (SDL:surface-get-format image))
(display format-image)(newline)                     ;;<SDL-Pixel-Format -1 24 0 255 RGB>
(define colorkey (SDL:map-rgb format-image 0 0 255)) 
(display colorkey)(newline)
;;я думал не будет работать с map-rgb но для формата 24 отлично все сформировалось и отработало.
(SDL:surface-color-key! image colorkey)              
(SDL:surface-alpha! image 70)

(SDL:rect:set-x! src 0)
(SDL:rect:set-y! src 0)
(SDL:rect:set-w! src (SDL:surface:w image))
(SDL:rect:set-h! src (SDL:surface:h image))

(SDL:rect:set-x! dst (- (SDL:surface:w screen) (SDL:surface:w image) 30))
(SDL:rect:set-y! dst 90)
(SDL:rect:set-w! dst (SDL:surface:w image))
(SDL:rect:set-h! dst (SDL:surface:h image))

(SDL:blit-surface image src screen dst)

;;	  (GFX:draw-point screen x y pixel_color)

;;(SDL:update-rect screen 0 0 s_width s_height)
(SDL:update-rect screen 0 0 0 0)
;;(SDL:flip)
(SDL:delay 16000)

(display "Sucess!\n")

(exit 0)
