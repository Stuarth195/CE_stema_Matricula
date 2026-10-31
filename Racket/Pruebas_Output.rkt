#lang typed/racket

(require typed/json
         "Estructuras.rkt"
         "Output.rkt")

;; ============================================================
;; PRUEBAS DEL MODULO OUTPUT (Typed Racket)
;;
;; Prueba 1: secuencia vacia (0 combinaciones).
;; Prueba 2: secuencia con una combinacion.
;; Prueba 3: secuencia con dos combinaciones.
;;
;; Los in-list producen streams compatibles con Sequenceof.
;; No se necesita importar racket/stream ni usar Streamof.
;; ============================================================

;; Mantiene la misma ruta de salida utilizada en tus pruebas.
(: ruta-salida-json String)
(define ruta-salida-json
  "C:/Inputs_Pruebas/combinaciones_salida.json")

(: mostrar-encabezado (-> String Void))
(define (mostrar-encabezado nombre)
  (newline)
  (displayln "============================================================")
  (printf "  ~a\n" nombre)
  (displayln "============================================================"))

;; ------------------------------------------------------------
;; 1. HORARIOS Y GRUPOS DE PRUEBA
;; ------------------------------------------------------------

(define h1 (Horario-info "Lunes" "07:30" "09:20"))
(define h2 (Horario-info "Miércoles" "07:30" "09:20"))
(define h3 (Horario-info "Martes" "09:30" "11:20"))
(define h4 (Horario-info "Jueves" "09:30" "11:20"))
(define h5 (Horario-info "Viernes" "13:00" "15:50"))
(define h6 (Horario-info "Miércoles" "13:00" "17:00"))

(define g-ma1102-1 (Grupo 1 (list h1 h2)))
(define g-ic1803-1 (Grupo 1 (list h3 h4)))
(define g-fis1101-1 (Grupo 1 (list h5)))
(define g-qu1101-1 (Grupo 1 (list h6)))

;; ------------------------------------------------------------
;; 2. CURSOS CON DISTINTOS CASOS
;; ------------------------------------------------------------

;; Con requisito y sin correquisito.
(define curso-ma1102
  (Curso "Ingeniería en Computadores"
         "MA1102" "Cálculo II" 4
         (list g-ma1102-1)
         (list "MA1101")
         #f #f #t))

;; Con requisito y con correquisito.
(define curso-fis1101
  (Curso "Ingeniería en Computadores"
         "FI1101" "Física I" 4
         (list g-fis1101-1)
         (list "MA1101")
         "FI1102" #f #t))

;; Sin requisitos ni correquisito.
(define curso-qu1101
  (Curso "Ingeniería en Computadores"
         "QU1101" "Química General I" 3
         (list g-qu1101-1)
         '()
         #f #f #t))

;; Con requisito y sin correquisito.
(define curso-ic1803
  (Curso "Ingeniería en Computadores"
         "IC1803" "Taller de Programación" 4
         (list g-ic1803-1)
         (list "IC1802")
         #f #f #t))

;; ------------------------------------------------------------
;; 3. COMBINACIONES FICTICIAS SOLO PARA PROBAR OUTPUT
;; ------------------------------------------------------------

(define comb1
  (Combinacion
   (list (cons curso-ma1102 g-ma1102-1)
         (cons curso-fis1101 g-fis1101-1)
         (cons curso-qu1101 g-qu1101-1)
         (cons curso-ic1803 g-ic1803-1))
   15
   (list "Ingeniería en Computadores")))

(define comb2
  (Combinacion
   (list (cons curso-qu1101 g-qu1101-1))
   3
   (list "Ingeniería en Computadores")))

;; Output.rkt recibe (Sequenceof Combinacion).
;; in-list devuelve una secuencia que tambien es un stream.
(: stream-vacio (Sequenceof Combinacion))
(define stream-vacio
  (in-list (ann '() (Listof Combinacion))))

(: stream-una-combinacion (Sequenceof Combinacion))
(define stream-una-combinacion
  (in-list (list comb1)))

(: stream-varias-combinaciones (Sequenceof Combinacion))
(define stream-varias-combinaciones
  (in-list (list comb1 comb2)))

;; ------------------------------------------------------------
;; 4. VERIFICAR ARCHIVO Y CANTIDAD DE COMBINACIONES
;; ------------------------------------------------------------

(: verificar-exportacion (-> String Natural Void))
(define (verificar-exportacion ruta cantidad-esperada)
  (unless (file-exists? ruta)
    (error 'verificar-exportacion "No se creo el archivo JSON de salida."))

  ;; string->jsexpr devuelve JSExpr (no incluye el valor EOF).
  ;; Asi se evita el error de tipos de read-json.
  (define contenido : JSExpr
    (string->jsexpr (file->string ruta)))

  (unless (list? contenido)
    (error 'verificar-exportacion "La raiz del JSON debe ser un arreglo."))

  (unless (= (length contenido) cantidad-esperada)
    (error 'verificar-exportacion
           "Cantidad incorrecta: se esperaban ~a combinaciones."
           cantidad-esperada))

  (printf "CORRECTO: JSON valido con ~a combinacion(es).\n"
          cantidad-esperada))

(: ejecutar-prueba (-> String (Sequenceof Combinacion) Natural Void))
(define (ejecutar-prueba nombre combinaciones cantidad-esperada)
  (mostrar-encabezado nombre)
  (exportar-combinaciones-json ruta-salida-json combinaciones)
  (verificar-exportacion ruta-salida-json cantidad-esperada))

;; ------------------------------------------------------------
;; 5. EJECUTAR LAS TRES PRUEBAS POR SEPARADO
;; ------------------------------------------------------------

(module+ main
  (printf "Archivo de salida: ~a\n" ruta-salida-json)

  (ejecutar-prueba "PRUEBA 1: STREAM VACIO (0 COMBINACIONES)"
                  stream-vacio 0)

  (ejecutar-prueba "PRUEBA 2: STREAM CON UNA COMBINACION"
                  stream-una-combinacion 1)

  (ejecutar-prueba "PRUEBA 3: STREAM CON DOS COMBINACIONES"
                  stream-varias-combinaciones 2)

  (mostrar-encabezado "TODAS LAS PRUEBAS FINALIZADAS")
  (displayln "Las tres pruebas terminaron sin errores.")
  (displayln "El archivo JSON final contiene DOS combinaciones."))
