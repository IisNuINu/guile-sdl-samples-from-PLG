#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

;;испольование OpenGL
;;

;;(setenv "LTDL_LIBRARY_PATH" "/usr/lib/guile-sdl:/usr/share/guile/site/2.2")
;;(setenv "LTDL_LIBRARY_PATH" "/usr/lib/guile-sdl")        ;;path to SDL bind
;;(setenv "LD_LIBRARY_PATH" "/usr/share/guile/site/2.2")   ;;path to OpenGL bind

(use-modules ((gl)   #:prefix GL:))
(use-modules ((gl enums) #:prefix ENUM:))
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

(SDL:gl-set-attribute (ENUM:get-p-name  doublebuffer) 1)
(SDL:gl-set-attribute (ENUM:get-p-name  red-bits) 5)
(SDL:gl-set-attribute (ENUM:get-p-name  green-bits) 6)
(SDL:gl-set-attribute (ENUM:get-p-name  blue-bits) 5)

;;(define screen (SDL:set-video-mode 640 480 16 'fullscreen))
(define s_width 640)
(define s_height 480)
(define screen (SDL:set-video-mode s_width s_height 16 '(doublebuf opengl)))
(if (not (SDL:surface? screen))
    (begin
      (display "Can't set videomode\n")
      (exit 1)))

(SDL:set-caption "OpenGL with SDL!")

(GL:gl-viewport 80 0 480 480)

(GL:set-gl-matrix-mode (ENUM:matrix-mode  projection))
(GL:gl-load-identity)

(GL:gl-frustum -1.0 1.0 -1.0 1.0 1.0 100.0)
(GL:set-gl-clear-color 0 0 0 0)
(GL:set-gl-matrix-mode (ENUM:matrix-mode modelview))
(GL:gl-load-identity)
(GL:gl-clear (ENUM:clear-buffer-mask color-buffer))
(GL:gl-begin (ENUM:begin-mode  triangles)
	  (GL:gl-color 1.0 0 0)
	  (GL:gl-vertex 0.0 1.0 -2.0)
	  (GL:gl-color 0 1.0 0)
	  (GL:gl-vertex 1.0 -1.0 -2.0)
	  (GL:gl-color 0  0  1.0)
	  (GL:gl-vertex -1.0  -1.0 -2.0))

;;glEnd();
;;glFlush();


;;Display the back buffer to the screen. */
(SDL:gl-swap-buffers)

(SDL:delay 10000)

(display "Sucess!\n")

(exit 0)

    

      
    


