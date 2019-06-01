#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

;;вывод звука с помощью SDL
;;


(use-modules ((sdl sdl) #:prefix SDL:)
	     ((sdl mixer) #:prefix MIX:)
             (srfi srfi-1)
             (srfi srfi-2))

(define (c-atexit proc)
  (let ((old-exit exit))
    (set! exit (lambda args
		 (display "atexit\n")
		 (proc)
		 (apply old-exit args)))))
(use-modules (ice-9 receive))

;; initialize the video subsystem
(if (not (equal? (SDL:init '(video audio)) 0))
    (begin
      (display "Can't initialize SDL!\n")
      (exit 1)))
(MIX:open-audio)

; exit procedure set
(c-atexit (lambda ()
	    (display "close audio and SDL:quit\n")
	    (MIX:close-audio)
	    (SDL:quit)))

(define s_width 256)
(define s_height 256)
(define screen (SDL:set-video-mode s_width s_height 16))
(if (not (SDL:surface? screen))
    (begin
      (display "Can't set videomode\n")
      (exit 1)))

(SDL:set-caption "Audio play!")

(define (load-music)
  (MIX:load-music "background.ogg"))
;; load the files
(define background (load-music))
(define fx (MIX:load-wave "fx.ogg"))
(display fx) (newline)


(MIX:music-volume 72)
(MIX:volume 45)

(let ((ch 0) (freq #f) (format #f) (channels #f) (event (SDL:make-event)) (type #f) (cont #t))
  (let loop ((i 1)) 
    (if (and cont
	      (SDL:wait-event event))
	 (begin
	   (set! type (SDL:event:type event))
	   (cond
	    ((equal? type 'key-down)
	     (begin
	       (display "Key down: ")
	       (display (string-append "Keysym: '" (symbol->string (SDL:event:key:keysym:sym event))))
	       (display "', Mod: ") (display (SDL:event:key:keysym:mod event)) (newline)
	       (cond
		((equal? (SDL:event:key:keysym:sym event) 'q)
		 (begin
		  (display "'Q' pressed, exiting!\n")
		  (set! cont #f)))
		((equal? (SDL:event:key:keysym:sym event) 'g)
		 (begin
		   (display "device-ffc is: ")
		   (receive (l_freq l_format l_channels) (MIX:device-ffc)
			    (set! freq l_freq)
			    (set! format l_format)
			    (set! channels l_channels))
		   (display "Freq: ") (display freq)
		   (display ", format: ") (display format )
		   (display ", Channels: ") (display channels)
		   (newline)))
		((equal? (SDL:event:key:keysym:sym event) 'p) ;;играть музыку
		 (begin
		   (display "Play music command\n")
		   (set! ch (MIX:play-music background))
		   (display "Channel play: ")
		   (display ch)
		   (newline)))
		((equal? (SDL:event:key:keysym:sym event) 's) ;;остановить проигрывание музыки
		 (begin
		   (display "Stop music command\n")
		   (MIX:halt-music)
		   ))
		((equal? (SDL:event:key:keysym:sym event) 'h) ;;пауза в проигрывании музыки
		 (begin
		   (display "Pause music command\n")
		   (MIX:pause-music)
		   ))
		((equal? (SDL:event:key:keysym:sym event) 'r) ;;возобновить проигрывание музыки
		 (begin
		   (display "Resume music command\n")
		   (MIX:resume-music)
		   ))
		((equal? (SDL:event:key:keysym:sym event) 'b) ;;проигрывание звука fx
		 (begin
		   (display "Bang fx!\n")
		   (set! ch (MIX:play-channel fx))
		   ;;(MIX:set-position 1 90 0)
		   (display "Playing fx with channel: ")
		   (display ch)
		   (newline)
		   ))
	       )))
	    ((equal? type 'quit)
	     (begin
	       (display "Get quit event\n")
	       (set! cont #f)))
	    )
	   (loop (+ i 0))))))
	   ;;(loop (identity i))))))





;;(SDL:delay 10000)

(display "Sucess!\n")

(exit 0)

    

      
    


