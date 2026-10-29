#lang typed/racket

(require typed/json)
(require "Estructuras.rkt")
(require "Importar.rkt")

;; ============================================================
;; PRUEBAS DE IMPORTACION DESDE EL JSON REAL GENERADO POR C
;;
;; Este archivo no modifica el JSON ni los modulos importados.
;; Pruebas disponibles: Horario-info, Grupo y Curso (general).
;;
;; Ejecutar todas:       racket Pruebas.rkt
;; Ejecutar una sola:    racket Pruebas.rkt horario
;;                       racket Pruebas.rkt grupo
;;                       racket Pruebas.rkt curso
;; ============================================================

;; Ruta original del archivo JSON exportado por el programa en C.
(: ruta-archivo String)
(define ruta-archivo
  "C:/Users/shoko/OneDrive/Attachments/Documents/GitHub/CE_stema_Matricula/catalogo_salida.json")

;; Muestra el nombre de la prueba antes de imprimir resultados.
(: mostrar-encabezado (-> String Void))
(define (mostrar-encabezado nombre)
  (newline)
  (displayln "============================================================")
  (printf "  ~a\n" nombre)
  (displayln "============================================================"))

;; Obtiene una lista asociada a una clave de un objeto JSON.
;; Si la clave falta o no contiene una lista, devuelve una lista vacia.
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
     (error 'Pruebas (format "No se encontraron ~a en el JSON." descripcion))]
    [(hash? (car elementos)) (car elementos)]
    [else
     (error 'Pruebas
            (format "El primer elemento de ~a no es un objeto JSON." descripcion))]))

;; Lee el JSON una sola vez para las tres pruebas.
(: cargar-json (-> Any))
(define (cargar-json)
  (unless (file-exists? ruta-archivo)
    (error 'Pruebas
           (format "No existe el archivo JSON en la ruta:\n~a" ruta-archivo)))
  (let ([datos (leer-json-intermedio ruta-archivo)])
    (unless (hash? datos)
      (error 'Pruebas "La raiz del archivo JSON debe ser un objeto."))
    datos))

;; Imprime los atributos del horario para facilitar su inspeccion.
(: imprimir-horario-info (-> Horario-info Void))
(define (imprimir-horario-info horario)
  (printf "Dia: ~a | Inicio: ~a | Fin: ~a\n"
          (or (Horario-info-dia horario) "No asignado")
          (or (Horario-info-inicio horario) "No asignado")
          (or (Horario-info-fin horario) "No asignado")))

;; ------------------------------------------------------------
;; PRUEBA 1: HORARIO-INFO INDIVIDUAL
;; Extrae el primer bloque del primer grupo del primer curso.
;; ------------------------------------------------------------
(: prueba-horario (-> Any Void))
(define (prueba-horario datos)
  (mostrar-encabezado "PRUEBA 1/3 - HORARIO-INFO (INDIVIDUAL)")
  (let* ([curso-json (primer-objeto-json (obtener-lista-json datos 'cursos)
                                         "cursos")]
         [grupo-json (primer-objeto-json (obtener-lista-json curso-json 'grupos)
                                         "grupos del primer curso")]
         [bloque-json (primer-objeto-json (obtener-lista-json grupo-json 'bloques)
                                          "bloques del primer grupo")]
         [horario (parsear-horario-info bloque-json)])
    (displayln "Objeto Horario-info importado:")
    (displayln horario)
    (imprimir-horario-info horario)
    (displayln "--- FIN DE PRUEBA 1 ---")))

;; ------------------------------------------------------------
;; PRUEBA 2: GRUPO INDIVIDUAL
;; Imprime solo el objeto Grupo (incluidos todos sus horarios).
;; ------------------------------------------------------------
(: prueba-grupo (-> Any Void))
(define (prueba-grupo datos)
  (mostrar-encabezado "PRUEBA 2/3 - GRUPO (INDIVIDUAL)")
  (let* ([curso-json (primer-objeto-json (obtener-lista-json datos 'cursos)
                                         "cursos")]
         [grupo-json (primer-objeto-json (obtener-lista-json curso-json 'grupos)
                                         "grupos del primer curso")]
         [grupo (parsear-grupo grupo-json)])
    (displayln "Objeto Grupo importado:")
    (displayln grupo)
    (displayln "--- FIN DE PRUEBA 2 ---")))

;; ------------------------------------------------------------
;; PRUEBA 3: CURSO GENERAL
;; Imprime el objeto Curso con sus grupos, horarios y demas datos.
;; ------------------------------------------------------------
(: prueba-curso (-> Any Void))
(define (prueba-curso datos)
  (mostrar-encabezado "PRUEBA 3/3 - CURSO (GENERAL)")
  (let* ([curso-json (primer-objeto-json (obtener-lista-json datos 'cursos)
                                         "cursos")]
         [curso (parsear-curso curso-json)])
    (displayln "Objeto Curso completo importado:")
    (displayln curso)
    (displayln "--- FIN DE PRUEBA 3 ---")))

;; Punto de entrada: por defecto se ejecutan las tres pruebas.
;; Opcionalmente se puede elegir una desde la terminal.
(module+ main
  (define argumentos (current-command-line-arguments))

  (: seleccion String)
  (define seleccion
    (if (zero? (vector-length argumentos))
        "todas"
        (vector-ref argumentos 0)))

  (when (> (vector-length argumentos) 1)
    (error 'Pruebas "Use: racket Pruebas.rkt [horario|grupo|curso|todas]"))
  (unless (member seleccion '("horario" "grupo" "curso" "todas"))
    (error 'Pruebas "Opcion invalida. Use horario, grupo, curso o todas."))

  (printf "Archivo JSON: ~a\n" ruta-archivo)
  (let ([datos (cargar-json)])
    (cond
      [(string=? seleccion "horario") (prueba-horario datos)]
      [(string=? seleccion "grupo")   (prueba-grupo datos)]
      [(string=? seleccion "curso")   (prueba-curso datos)]
      [else
       (prueba-horario datos)
       (prueba-grupo datos)
       (prueba-curso datos)
       (newline)
       (displayln "=== FINALIZARON LAS TRES PRUEBAS ===")])))
