#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")


;; к сожалению прямого доступа к памяти экрана(поверхности) библиотека не предоставляет
;; SDL:surface-pixels возвращает лишь копию экрана которую можно менять, но толку от 

(setenv "LTDL_LIBRARY_PATH" "/usr/local/lib/guile-sdl")
(use-modules ((sdl sdl) #:prefix SDL:)
             (srfi srfi-1)
             (srfi srfi-2)
	     (srfi srfi-4))

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

(SDL:lock-surface screen)

(define raw-pixels (SDL:surface-pixels screen #f)) ;;define new uniform vector - srfi-4

(define (make-set-pixel uvec)
  (cond
   ((u8vector? uvec)
    u8vector-set!)
   ((u16vector? uvec)
    u16vector-set!)
   ((u32vector? uvec)
    u32vector-set!)
   ((u64vector? uvec)
    u64vector-set!)))

    
(define set-pixel (make-set-pixel raw-pixels))
(display set-pixel)(newline)
(define screen-format (SDL:surface-get-format screen))
(display screen-format)(newline)
(define screen-pitch (SDL:surface:w screen))

;;cycle pixel set to surface screen
(let ((x 0) (y 0) (offset 0) (pixel_color 0) (r 0) (g 0) (b 0))
  (do ((x 0 (+ x 1)))
      ((>= x s_width))
    (begin
      (do ((y 0 (+ y 1)))
	  ((>= y s_height))
	(begin
	  (set! r x)
	  (set! b y)
	  (set! pixel_color (SDL:map-rgb screen-format r g b))
	  ;;(set! offset (+ (* (/ screen-pitch 2) y) x))
	  (set! offset (+ (* screen-pitch y) x))
	;;(display (string-append "x: " (number->string x) ", y: " (number->string y)
	;;			", offset: " (number->string offset) ", color: "
	;;			(number->string pixel_color) "\n"))
	;;(set-pixel raw-pixels offset pixel_color)))
	  (u16vector-set! raw-pixels offset pixel_color)))
      ;;(display (string-append "x: " (number->string x) ", y: " (number->string y)
      ;;			      ", offset: " (number->string offset) ", color: "
      ;;(number->string pixel_color) "\n"))
      )))

(display raw-pixels)
(SDL:unlock-surface screen)
;;(SDL:update-rect screen 0 0 s_width s_height)
(SDL:update-rect screen 0 0 0 0)
(SDL:delay 16000)

(display "Sucess!\n")

(exit 0)
