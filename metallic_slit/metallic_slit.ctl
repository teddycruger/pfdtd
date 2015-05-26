; Metallic Slit File


(define-param sx 300)
(define-param sy 2000)
(define-param sz 1000)
(define-param dpml 20)
(define-param cell_res 0.25)

; Define metallic slit parameters
(define-param S_ms 40)
(define-param W_ms (* (+ S_ms sx) 0.5))
(define-param T_ms 400)

; Define metallic slit x-offset
(define-param x_ms_offset (* (+ S_ms W_ms) 0.5))

; Set source parameters
(define-param fcen (/ 1 300))
(define-param df (/ 1 900))

; Set source position
(define-param y_source 0)
(define-param z_source 0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; Setup the simulation ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Setup the computation cell
(set! geometry-lattice (make lattice (size sx sy sz)))

; Setup the metallic slit geometry
(set! geometry (list
	(make block (center x_ms_offset 0 0)(size W_ms infinity T_ms)
		(material perfect-electric-conductor))
	(make block (center (* -1 x_ms_offset) 0 0)(size W_ms infinity T_ms)
		(material perfect-electric-conductor))))

; Setup PML layers
(set! pml-layers (list (make pml (thickness dpml))))

; Setup the cell resolution
(set! resolution cell_res)

; Setup the source
(set! sources (list 
	(make source
		(src (make gaussian-src
			(frequency fcen)(fwidth df)))
		(component Ex)
		(center 0 y_source z_source)
		(size S_ms 0 0))))

; Run the simulation
(run-until 8000 
	(at-beginning output-epsilon)
	(to-appended "ex_xy"
		(at-every 50 
			(in-volume (volume (center 0 0 0)(size sx sy no-size))
				output-efield-x)))
	(to-appended "ex_yz"
		(at-every 50 
			(in-volume (volume (center 0 0 0)(size no-size sy sz))
				output-efield-x))))

