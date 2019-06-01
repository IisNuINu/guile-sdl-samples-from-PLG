#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

;;инициализация SDL
;;

;;(setenv "LTDL_LIBRARY_PATH" "/usr/local/lib/guile-sdl")
;;(add-to-load-path "/usr/local/lib/guile-sdl")
(add-to-load-path "/home/bear/inst/guile-sdl-0.5.2/src/.libs")

(use-modules ((sdl sdl) #:prefix SDL:)
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

(define screen (SDL:set-video-mode 640 480 16 'fullscreen))
;;(define screen (SDL:set-video-mode 1366 768 16 'fullscreen))
(if (not (SDL:surface? screen))
    (begin
      (display "Can't set videomode\n")
      (exit 1)))

(display "Sucess!\n")

(exit 0)
