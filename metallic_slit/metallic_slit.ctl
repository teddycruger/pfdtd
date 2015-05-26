; Metallic Slit Waveguide
;
; Simulation for a metallic slit (ms) waveguide
;
; By: Levi Smith
; Date: May 26, 2015
;
; Language: Scheme
;
; File type: *.ctl used as an input file for the
;            MEEP FDTD field solver
;
;
; Comments: Gaussian source


;;;;;; Geometry ;;;;;;;
;
;
;  |<-W_ms->|
;  |        | 
;  ----------        ----------
;     ^     |        |
;     |     |        |
;    T_ms   |<-S_ms->|
;     |     |        |
;     v     |        |
;  ----------        ----------
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; User-defined variables ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Computational cell parameters
(define-param sx 500)
(define-param sy 3000)
(define-param sz 1200)
(define-param dpml 100)
(define-param cell_res 0.25)

; Define metallic slit parameters
(define-param S_ms 40)
(define-param W_ms (* (+ S_ms sx) 0.5))
(define-param T_ms 400)

; Define metallic slit x-offset
(define-param x_ms_offset (* (+ S_ms W_ms) 0.5))

; Set source parameters
(define-param fcen (/ 1 300))
(define-param df (/ 1 300))

; Set source position
(define-param y_pml_gap 200)
(define-param y_source (+ dpml y_pml_gap (* -0.5 sy)))
(define-param z_source (* 0.5 T_ms))

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
			(in-volume (volume (center 0 0 0)(size sx sy 0))
				output-efield-x)))
	(to-appended "ex_yz"
		(at-every 50 
			(in-volume (volume (center 0 0 0)(size 0 sy sz))
				output-efield-x))))

