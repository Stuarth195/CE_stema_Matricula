#lang typed/racket

(require typed/json)
(require "Estructuras.rkt")
(require "Importar.rkt")

;; ============================================================
;; PRUEBAS DE IMPORTACION DE PREFERENCIAS DEL ESTUDIANTE
;;
;; Este archivo prueba la correcta lectura y parseo del JSON
;; de preferencias del estudiante usando las estructuras:
;; - Curso-Interes
;; - Preferencia
;;
;; Ejecutar todas:       racket PruebasPreferencias.rkt
;; Ejecutar una sola:    racket PruebasPreferencias.rkt curso-interes
;;                       racket PruebasPreferencias.rkt preferencia
;; ============================================================

;; Ruta del archivo JSON de preferencias del estudiante.
(: ruta-archivo-pref String)
(define ruta-archivo-pref  "C:/Users/shoko/OneDrive/Attachments/Documents/GitHub/CE_stema_Matricula/Racket/Inputs_Pruebas/Estudiante1.json"
  )

;; Muestra el nombre de la prueba antes de imprimir resultados.
(: mostrar-encabezado (-> String Void))
(define (mostrar-encabezado nombre)
  (newline)
  (displayln "============================================================")
  (printf "  ~a\n" nombre)
  (displayln "============================================================"))

;; Obtiene una lista asociada a una clave de un objeto JSON.
(: obtener-lista-json (-> Any Symbol (Listof Any)))
(define (obtener-lista-json objeto clave)
  (if (hash? objeto)
      (let ([valor (hash-ref objeto clave (lambda () '()))])
        (if (list? valor) valor '()))
      '()))

;; Exige un objeto JSON real: no fabrica datos de prueba si falta.
(: primer-objeto-json (-> (Listof Any) String Any))
(define (primer-objeto-json elementos descripcion)
  (cond
    [(null? elementos)
     (error 'Pruebas (format "No se encontraron ~a en el JSON de preferencias." descripcion))]
    [(hash? (car elementos)) (car elementos)]
    [else
     (error 'Pruebas
            (format "El primer elemento de ~a no es un objeto JSON." descripcion))]))

;; Lee el JSON de preferencias.
(: cargar-json-pref (-> Any))
(define (cargar-json-pref)
  (unless (file-exists? ruta-archivo-pref)
    (error 'Pruebas
           (format "No existe el archivo JSON de preferencias en la ruta:\n~a" ruta-archivo-pref)))
  (let ([datos (leer-json-intermedio ruta-archivo-pref)])
    (unless (hash? datos)
      (error 'Pruebas "La raiz del archivo JSON de preferencias debe ser un objeto."))
    datos))

;; Imprime los atributos de las preferencias para facilitar su inspeccion.
(: imprimir-preferencia (-> Preferencia Void))
(define (imprimir-preferencia pref)
  (printf "Carnet: ~a\n" (Preferencia-carnet pref))
  (printf "Créditos Min: ~a | Créditos Max: ~a\n" 
          (Preferencia-creditos-min pref) 
          (Preferencia-creditos-max pref))
  (displayln "Cursos de interés:")
  (for ([ci (Preferencia-cursos-interes pref)])
    (printf "  - Curso: ~a | Grupos: ~a\n" 
            (Curso-Interes-codigo ci) 
            (Curso-Interes-grupos ci))))

;; ------------------------------------------------------------
;; PRUEBA 1: CURSO-INTERES INDIVIDUAL
;; Extrae y parsea el primer curso de interes del JSON.
;; ------------------------------------------------------------
(: prueba-curso-interes (-> Any Void))
(define (prueba-curso-interes datos)
  (mostrar-encabezado "PRUEBA 1/2 - CURSO-INTERES (INDIVIDUAL)")
  (let* ([curso-json (primer-objeto-json (obtener-lista-json datos 'cursos_interes)
                                         "cursos_interes")]
         [curso-interes (parsear-curso-interes curso-json)])
    (displayln "Objeto Curso-Interes importado:")
    (displayln curso-interes)
    (printf "Código: ~a | Grupos preferidos: ~a\n" 
            (Curso-Interes-codigo curso-interes) 
            (Curso-Interes-grupos curso-interes))
    (displayln "--- FIN DE PRUEBA 1 ---")))

;; ------------------------------------------------------------
;; PRUEBA 2: PREFERENCIA COMPLETA DEL ESTUDIANTE
;; Importa el objeto Preferencia completo con carnet, cursos y creditos.
;; ------------------------------------------------------------
(: prueba-preferencia (-> Any Void))
(define (prueba-preferencia datos)
  (mostrar-encabezado "PRUEBA 2/2 - PREFERENCIA COMPLETA")
  (let ([preferencia (parsear-preferencia datos)])
    (displayln "Objeto Preferencia completo importado:")
    (displayln preferencia)
    (imprimir-preferencia preferencia)
    (displayln "--- FIN DE PRUEBA 2 ---")))

;; Punto de entrada: por defecto se ejecutan ambas pruebas.
(module+ main
  (define argumentos (current-command-line-arguments))

  (: seleccion String)
  (define seleccion
    (if (zero? (vector-length argumentos))
        "todas"
        (vector-ref argumentos 0)))

  (when (> (vector-length argumentos) 1)
    (error 'Pruebas "Use: racket PruebasPreferencias.rkt [curso-interes|preferencia|todas]"))
  (unless (member seleccion '("curso-interes" "preferencia" "todas"))
    (error 'Pruebas "Opcion invalida. Use curso-interes, preferencia o todas."))

  (printf "Archivo JSON Preferencias: ~a\n" ruta-archivo-pref)
  (let ([datos (cargar-json-pref)])
    (cond
      [(string=? seleccion "curso-interes") (prueba-curso-interes datos)]
      [(string=? seleccion "preferencia")   (prueba-preferencia datos)]
      [else
       (prueba-curso-interes datos)
       (prueba-preferencia datos)
       (newline)
       (displayln "=== FINALIZARON LAS PRUEBAS DE PREFERENCIAS ===")])))