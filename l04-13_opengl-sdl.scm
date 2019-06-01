#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

;;Использование OpenGL

;;(setenv "LTDL_LIBRARY_PATH" "/usr/lib/guile-sdl:/usr/share/guile/site/2.2")
(setenv "LTDL_LIBRARY_PATH" "/usr/lib/guile-sdl")
(setenv "LT_LIBRARY_PATH" "/usr/share/guile/site/2.2")

(use-modules ((gl)))
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

(SDL:gl-set-attribute (get-p-name doublebuffer) 1)
(SDL:gl-set-attribute (get-p-name red-bits) 5)
(SDL:gl-set-attribute (get-p-name green-bits) 6)
(SDL:gl-set-attribute (get-p-name blue-bits) 5)

;;(define screen (SDL:set-video-mode 640 480 16 'fullscreen))
(define s_width 640)
(define s_height 480)
(define screen (SDL:set-video-mode s_width s_height 16 '(doublebuf opengl)))
(if (not (SDL:surface? screen))
    (begin
      (display "Can't set videomode\n")
      (exit 1)))

(SDL:set-caption "OpenGL with SDL!")

(gl-viewport 80 0 480 480)

(set-gl-matrix-mode (matrix-mode projection))
(gl-load-identity)

(gl-frustum -1.0 1.0 -1.0 1.0 1.0 100.0)
(set-gl-clear-color 0 0 0 0)
(set-gl-matrix-mode (matrix-mode modelview))
(gl-load-identity)
(gl-clear (clear-buffer-mask color-buffer))
(gl-begin (begin-mode triangles)
	  (gl-color 1.0 0 0)
	  (gl-vertex 0.0 1.0 -2.0)
	  (gl-color 0 1.0 0)
	  (gl-vertex 1.0 -1.0 -2.0)
	  (gl-color 0  0  1.0)
	  (gl-vertex -1.0  -1.0 -2.0))

;;glEnd();
;;glFlush();


;;Display the back buffer to the screen. */
(SDL:gl-swap-buffers)

(SDL:delay 10000)

(display "Sucess!\n")

(exit 0)

    

      
    


