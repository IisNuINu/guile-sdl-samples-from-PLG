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
(define s_width 320)
(define s_height 200)
(define screen (SDL:set-video-mode s_width s_height 16))
(if (not (SDL:surface? screen))
    (begin
      (display "Can't set videomode\n")
      (exit 1)))

;; загрузка картинки
(define (load-check-img name-image)
  (let ((image (SDL:load-image name-image)))
    (if (not (SDL:surface? image))
	(begin
	  (display (string-append "Unable load image:" name-image "\n"))
	  (exit 1)))
    image))

(define image-with-alpha (load-check-img "with-alpha2.png"))
(define image-without-alpha (load-check-img "without-alpha.png"))
(define background (load-check-img "bg.png"))

;;рисуем фон
;;создадим границы прямоугольников копирования
(define src (SDL:make-rect 0 0 (SDL:surface:w background) (SDL:surface:h background)))
(define dst (SDL:make-rect 0 0 (SDL:surface:w background) (SDL:surface:h background)))

(SDL:blit-surface background src screen dst)

;;рисуем первое изображение имеющее альфа канал:
;;(SDL:surface-alpha! image-with-alpha 0)
(SDL:rect:set-x! src 0)
(SDL:rect:set-y! src 0)
(SDL:rect:set-w! src (SDL:surface:w image-with-alpha))
(SDL:rect:set-h! src (SDL:surface:h image-with-alpha))

(SDL:rect:set-x! dst 40)
(SDL:rect:set-y! dst 50)
(SDL:rect:set-w! dst (SDL:rect:w src))
(SDL:rect:set-h! dst (SDL:rect:h src))

(SDL:blit-surface image-with-alpha src screen dst)

;;рисуем второе изображение не имеющее альфа канала, устанавливаем прозрачность 50 проц.
(SDL:surface-alpha! image-without-alpha 70)
(SDL:rect:set-x! src 0)
(SDL:rect:set-y! src 0)
(SDL:rect:set-w! src (SDL:surface:w image-without-alpha))
(SDL:rect:set-h! src (SDL:surface:h image-without-alpha))

(SDL:rect:set-x! dst 180)
(SDL:rect:set-y! dst 50)
(SDL:rect:set-w! dst (SDL:rect:w src))
(SDL:rect:set-h! dst (SDL:rect:h src))

(SDL:blit-surface image-without-alpha src screen dst)

;;	  (GFX:draw-point screen x y pixel_color)

;;(SDL:update-rect screen 0 0 s_width s_height)
(SDL:update-rect screen 0 0 0 0)
;;(SDL:flip)
(SDL:delay 16000)


(display "Sucess!\n")

(exit 0)
