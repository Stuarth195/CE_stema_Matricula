#lang typed/racket

(require "Estructuras.rkt"
         "Importar.rkt"
         "Generacion.rkt"
         "Filtrado.rkt"
         "Output.rkt")

;; ============================================================
;; MAIN - CEmestre 
;; ============================================================

(: cargar-lista-cursos (-> String (Listof Curso)))
(define (cargar-lista-cursos ruta-catalogo)
  (let ([datos (leer-json-intermedio ruta-catalogo)])
    (if (hash? datos)
        (let ([cursos-json (hash-ref datos 'cursos (lambda () #f))])
          (if (list? cursos-json)
              (map parsear-curso cursos-json)
              (error 'cargar-lista-cursos
                     "El campo 'cursos' no existe o no es una lista.")))
        (error 'cargar-lista-cursos
               "La raiz del catalogo JSON debe ser un objeto."))))

(: imprimir-preferencias (-> Preferencia Void))
(define (imprimir-preferencias preferencias)
  (displayln "\n========== PREFERENCIAS DEL ESTUDIANTE ==========")
  (writeln preferencias)
  (displayln "================================================="))

(: imprimir-lista-cursos (-> (Listof Curso) Void))
(define (imprimir-lista-cursos lista-cursos)
  (displayln "\n=============== CATALOGO DE CURSOS ===============")
  (printf "Total de cursos cargados: ~a\n" (length lista-cursos))
  (for ([curso (in-list lista-cursos)]
        [numero (in-naturals 1)])
    (printf "\n[~a] ~a - ~a\n"
            numero (Curso-codigo curso) (Curso-nombre curso))
    (writeln curso))
  (displayln "\n================ FIN DEL CATALOGO ================"))

(: guardar-combinaciones (-> String (Sequenceof Combinacion) Void))
(define (guardar-combinaciones ruta-salida combinaciones)
  (exportar-combinaciones-json ruta-salida combinaciones))

(: ejecutar-main (-> String String Void))
(define (ejecutar-main ruta-preferencias ruta-catalogo)
  (let* ([preferencias : Preferencia
                        (leer-preferencias-estudiante ruta-preferencias)]
         [lista-cursos : (Listof Curso)
                       (cargar-lista-cursos ruta-catalogo)])

    (imprimir-preferencias preferencias)
    (imprimir-lista-cursos lista-cursos)

    ;; Pipeline 100% perezoso basado en Streams:
    (let* ([stream-generado (generar-combinaciones-stream lista-cursos preferencias)]
           [stream-filtrado (filtrar-por-creditos
                             stream-generado
                             (Preferencia-creditos-min preferencias)
                             (Preferencia-creditos-max preferencias))]
           [secuencia-salida (stream->secuencia stream-filtrado)])

      (guardar-combinaciones "combinaciones_salida.json" secuencia-salida))

    (displayln "\nCombinaciones generadas mediante streams, filtradas y exportadas con éxito.")
    (void)))

(module+ main
  (let ([argumentos (current-command-line-arguments)])
    (if (= (vector-length argumentos) 2)
        (with-handlers
            ([exn:fail?
              (lambda ([e : exn:fail])
                (eprintf "ERROR: ~a\n" (exn-message e))
                (exit 1))])
          (ejecutar-main (vector-ref argumentos 0)
                         (vector-ref argumentos 1)))
        (begin
          (eprintf "Uso: main.exe <preferencias.json> <catalogo.json>\n")
          (eprintf "Ejemplo: main.exe .\\Inputs_Pruebas\\Estudiante1.json ..\\catalogo_salida.json\n")
          (exit 1)))))