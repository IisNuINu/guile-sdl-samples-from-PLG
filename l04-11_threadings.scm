#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

;; Работа с потоками без использования потоков SDL


(setenv "LTDL_LIBRARY_PATH" "/usr/local/lib/guile-sdl")
(use-modules ((sdl sdl) #:prefix SDL:)
	     ((sdl gfx) #:prefix GFX:)
             (srfi srfi-1)
             (srfi srfi-2))
(use-modules (ice-9 threads))


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
(define counter 0)
(define counter_mutex (make-mutex))
(if (not (mutex? counter_mutex))
    (begin
      (display "Can't create mutex\n")
      (exit 1)))
(define exit_flag #f)

(define (ThreadEntryPoint data)
  (let ((name data) (i 0))
    (do ((i 0 (identity i)))
	((identity exit_flag))
      (begin
	(display (string-append "In is: " name "\n"))
	(lock-mutex counter_mutex)
	(display (string-append "In:'" name "' the counter is: " (number->string counter) "\n"))
	(set! counter (+ counter 1))
	(unlock-mutex counter_mutex)
	(SDL:delay (random 3000 (random-state-from-platform)))))
    (display "Exit from:") (display name) (newline)))

(display "Press Ctrl-C to exit the programm\n")
(let ((thread1 (make-thread ThreadEntryPoint "Thread 1"))
      (thread2 (make-thread ThreadEntryPoint "Thread 2"))
      (thread3 (make-thread ThreadEntryPoint "Thread 3"))
      (i 0))
  (do ((i 0 (identity i)))
      ((> counter 20))
    (SDL:delay 1000))
  (set! exit_flag #t)
  (display "exit_flag has been set by main()\n")
  (SDL:delay 3500))
(display "Sucess!\n")
(exit 0)


