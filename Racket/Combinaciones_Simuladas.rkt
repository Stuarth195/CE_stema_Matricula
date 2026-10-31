#lang typed/racket

(require "Estructuras.rkt")

(provide combinaciones-simuladas)

;; ============================================================
;; COMBINACIONES SIMULADAS - PRUEBA DE INTEGRACION
;;
;; Solo construye datos tipados y expone una secuencia.
;; NO importa Output.rkt, NO crea archivos y NO escribe JSON.
;; Sustituye temporalmente la secuencia futura de David/Claudio.
;; ============================================================

;; Horarios y grupos de ejemplo.
(define horario-calculo-lunes (Horario-info "LUN" "07:30" "09:20"))
(define horario-calculo-miercoles (Horario-info "MIE" "07:30" "09:20"))
(define horario-fisica-viernes (Horario-info "VIE" "13:00" "15:50"))
(define horario-quimica-miercoles (Horario-info "MIE" "13:00" "17:00"))
(define horario-taller-martes (Horario-info "MAR" "09:30" "11:20"))

(define grupo-calculo (Grupo 1 (list horario-calculo-lunes horario-calculo-miercoles)))
(define grupo-fisica (Grupo 1 (list horario-fisica-viernes)))
(define grupo-quimica (Grupo 1 (list horario-quimica-miercoles)))
(define grupo-taller (Grupo 1 (list horario-taller-martes)))

;; Cursos ficticios que respetan la estructura Curso del proyecto.
(define curso-calculo
  (Curso "Ingeniería en Computadores" "MA1102" "Cálculo II" 4
         (list grupo-calculo) (list "MA1101") #f #f #t))

(define curso-fisica
  (Curso "Ingeniería en Computadores" "FI1101" "Física I" 4
         (list grupo-fisica) (list "MA1101") "FI1102" #f #t))

(define curso-quimica
  (Curso "Ingeniería en Computadores" "QU1101" "Química General I" 3
         (list grupo-quimica) '() #f #f #t))

(define curso-taller
  (Curso "Ingeniería en Computadores" "IC1803" "Taller de Programación" 4
         (list grupo-taller) (list "IC1802") #f #f #t))

;; Datos ya preparados: no se generan combinaciones algorítmicamente.
(define combinacion-uno
  (Combinacion
   (list (cons curso-calculo grupo-calculo)
         (cons curso-fisica grupo-fisica)
         (cons curso-quimica grupo-quimica)
         (cons curso-taller grupo-taller))
   15
   (list "Ingeniería en Computadores")))

(define combinacion-dos
  (Combinacion
   (list (cons curso-calculo grupo-calculo)
         (cons curso-quimica grupo-quimica))
   7
   (list "Ingeniería en Computadores")))

;; Interfaz que consumirá main.rkt: secuencia tipada de Combinacion.
;; in-list construye una secuencia compatible con Output.rkt.
;; Es un simulador de la interfaz, no la implementación de streams de David.
(: combinaciones-simuladas (Sequenceof Combinacion))
(define combinaciones-simuladas
  (in-list (list combinacion-uno combinacion-dos)))
