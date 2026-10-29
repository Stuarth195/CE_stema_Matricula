#lang typed/racket

(require typed/json)
(require "Estructuras.rkt")
(require "Output.rkt")

;; ============================================================
;; PRUEBA EXTENDIDA DE GENERACIÓN DE ARCHIVO JSON DE SALIDA
;;
;; Simula combinaciones con cursos variados:
;; - Con requisitos y correquisito.
;; - Con requisitos y sin correquisito.
;; - Sin requisitos ni correquisitos.
;;
;; Ejecutar: racket Pruebas_Output.rkt
;; ============================================================

;; Ruta de destino donde se creará el archivo JSON de salida.
(: ruta-salida-json String)
(define ruta-salida-json
  "C:/Users/shoko/OneDrive/Attachments/Documents/GitHub/CE_stema_Matricula/Racket/Inputs_Pruebas/combinaciones_salida.json")

;; Muestra el nombre de la prueba en la consola.
(: mostrar-encabezado (-> String Void))
(define (mostrar-encabezado nombre)
  (newline)
  (displayln "============================================================")
  (printf "  ~a\n" nombre)
  (displayln "============================================================"))

;; ------------------------------------------------------------
;; 1. CREACIÓN DE BLOQUES DE HORARIO Y GRUPOS
;; ------------------------------------------------------------

(define h1 (Horario-info "Lunes" "07:30" "09:20"))
(define h2 (Horario-info "Miércoles" "07:30" "09:20"))
(define h3 (Horario-info "Martes" "09:30" "11:20"))
(define h4 (Horario-info "Jueves" "09:30" "11:20"))
(define h5 (Horario-info "Viernes" "13:00" "15:50"))
(define h6 (Horario-info "Miércoles" "13:00" "17:00"))

;; Grupos
(define g-ma1102-1 (Grupo 1 (list h1 h2)))
(define g-ic1803-1 (Grupo 1 (list h3 h4)))
(define g-fis1101-1 (Grupo 1 (list h5)))
(define g-qu1101-1 (Grupo 1 (list h6)))

;; ------------------------------------------------------------
;; 2. CREACIÓN DE CURSOS (VARIADOS)
;; ------------------------------------------------------------

;; Curso 1: Con requisitos y SIN correquisito (Cálculo II)
(define curso-ma1102 
  (Curso "Ingeniería en Computadores" 
         "MA1102" 
         "Cálculo II" 
         4 
         (list g-ma1102-1) 
         (list "MA1101")    ;; Tiene requisitos
         #f                 ;; Sin correquisito
         #f 
         #t))

;; Curso 2: Con requisitos Y CON correquisito (Física I y su laboratorio)
(define curso-fis1101 
  (Curso "Ingeniería en Computadores" 
         "FI1101" 
         "Física I" 
         4 
         (list g-fis1101-1) 
         (list "MA1101")    ;; Requisito
         "FI1102"           ;; Correquisito (Laboratorio de Física I)
         #f 
         #t))

;; Curso 3: SIN requisitos y SIN correquisito (Curso introductorio)
(define curso-qu1101 
  (Curso "Ingeniería en Computadores" 
         "QU1101" 
         "Química General I" 
         3 
         (list g-qu1101-1) 
         '()                ;; Sin requisitos
         #f                 ;; Sin correquisito
         #f 
         #t))

;; Curso 4: Con requisitos y SIN correquisito (Taller)
(define curso-ic1803 
  (Curso "Ingeniería en Computadores" 
         "IC1803" 
         "Taller de Programación" 
         4 
         (list g-ic1803-1) 
         (list "IC1802") 
         #f 
         #f 
         #t))

;; ------------------------------------------------------------
;; 3. CREACIÓN DE LISTA DE COMBINACIONES
;; ------------------------------------------------------------

;; Combinación que agrupa los diferentes tipos de cursos
(define comb1
  (Combinacion
   (list (cons curso-ma1102 g-ma1102-1)
         (cons curso-fis1101 g-fis1101-1)
         (cons curso-qu1101 g-qu1101-1)
         (cons curso-ic1803 g-ic1803-1))
   15
   (list "Ingeniería en Computadores")))

(define lista-combinaciones (list comb1))

;; ------------------------------------------------------------
;; 4. EJECUCIÓN DE LA EXPORTACIÓN
;; ------------------------------------------------------------

(module+ main
  (mostrar-encabezado "EXPORTANDO COMBINACIONES EXTENDIDAS A JSON")
  
  (printf "Generando archivo en:\n~a\n\n" ruta-salida-json)
  
  (exportar-combinaciones-json ruta-salida-json lista-combinaciones)
  
  (if (file-exists? ruta-salida-json)
      (begin
        (displayln "¡ÉXITO! El archivo .json con la variedad de cursos fue creado.")
        (printf "Total de combinaciones exportadas: ~a\n" (length lista-combinaciones)))
      (displayln "ERROR: No se pudo encontrar el archivo generado."))
  
  (displayln "============================================================"))