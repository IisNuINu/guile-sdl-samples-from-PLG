#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")


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
(define pixel_color 0)

(begin
  ;;(set! pixel_color (SDL:map-rgb screen-format (SDL:make-color 255 0 0))) ;;red
  ;;(set! pixel_color (SDL:map-rgb screen-format (SDL:make-color 0 255 0))) ;;green
  (set! pixel_color (SDL:map-rgb screen-format (SDL:make-color 0 0 255))) ;;blue
  (display (string-append " color: " (number->string pixel_color) "\n"))
  (SDL:fill-rect screen #f pixel_color))

;;(SDL:unlock-surface screen)
(SDL:update-rect screen 0 0 s_width s_height)
;;(SDL:update-rect screen 0 0 0 0)
;;(SDL:flip screen)
(SDL:delay 16000)

(display "Sucess!\n")

(exit 0)
