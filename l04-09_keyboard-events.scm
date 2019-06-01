#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

;; Работа с сообщениями от мышки.


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
      (display "Can't set videomode: ")
      (display (SDL:get-error))
      (newline)
      (exit 1)))


(let ((stop #f) (ret #t) (event (SDL:make-event)) (type #f) (cont #t))
  (do ((cont #t (identity #t)))
      ((or stop
	   (not (SDL:wait-event event))))
    (begin
      (set! type (SDL:event:type event))
      (cond
       ((equal? type 'key-down)
	(begin
	  (display "Key down: ")
	  (display (string-append "Keysym: '" (symbol->string (SDL:event:key:keysym:sym event))))
	  (display "', Mod: ") (display (SDL:event:key:keysym:mod event)) (newline)
	  (if (equal? (SDL:event:key:keysym:sym event) 'q)
	      (begin
		(display "'Q' pressed, exiting!\n")
		(set! stop #t)))))
       ((equal? type 'key-up)
	(begin
	  (display "Key up: ")
	  (display (string-append "Keysym: '" (symbol->string (SDL:event:key:keysym:sym event))))
	  (display "', Mod: ") (display (SDL:event:key:keysym:mod event)) (newline)))
       ((equal? type 'quit)
	(begin
	  (display "Get quit event\n")
	  (set! stop #t)))
      ))))



(display "Sucess!\n")

(exit 0)
