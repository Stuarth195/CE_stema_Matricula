#lang typed/racket

(require "Estructuras.rkt"
         "Importar.rkt"
         "Output.rkt")

;; ============================================================
;; MAIN - CEmestre
;;
;; Uso:
;;   racket main.rkt <preferencias.json> <catalogo.json>
;;
;; Entradas:
;;   1. Archivo JSON de preferencias del estudiante.
;;   2. Archivo JSON con el catalogo completo de cursos.
;;
;; Este main construye los datos tipados que utilizaran los
;; modulos de filtrado y generacion de combinaciones.
;; No filtra ni modifica los cursos importados.
;; ============================================================

;; Convierte todos los cursos del catalogo JSON a estructuras Curso.
;; Cada Curso incluye sus estructuras Grupo y Horario-info.
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

;; Muestra el objeto Preferencia real, sin volver a leer el JSON.
(: imprimir-preferencias (-> Preferencia Void))
(define (imprimir-preferencias preferencias)
  (displayln "\n========== PREFERENCIAS DEL ESTUDIANTE ==========")
  (writeln preferencias)
  (displayln "================================================="))

;; Muestra TODOS los cursos, incluidos sus grupos y horarios.
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

;; Orquesta la importacion y deja los datos para los companeros.
(: ejecutar-main (-> String String Void))
(define (ejecutar-main ruta-preferencias ruta-catalogo)
  (let* ([preferencias : Preferencia
                        (leer-preferencias-estudiante ruta-preferencias)]
         [lista-cursos : (Listof Curso)
                       (cargar-lista-cursos ruta-catalogo)])

    ;; ========================================================
    ;; ZONA DE INTEGRACION PARA La logica de filtrado 
    ;;
    ;; Valores disponibles EN ESTE BLOQUE:
    ;;   preferencias : Preferencia
    ;;   lista-cursos : (Listof Curso)
    ;;
    ;; Definir aqui el filtrado y las combinaciones, ANTES de
    ;; las instrucciones de impresion. Los nombres de funciones
    ;; siguientes son ejemplos: todavia no estan implementadas.
    ;;
    ;; (define lista-cursos-filtrados : (Listof Curso)
    ;;   (filtrar-cursos lista-cursos preferencias))
    ;;
    ;; (define lista-combinaciones : (Listof Combinacion)
    ;;   (generar-combinaciones lista-cursos-filtrados preferencias))
    ;; ========================================================

    ;; Pruebas visuales en consola.
    (imprimir-preferencias preferencias)
    (imprimir-lista-cursos lista-cursos)

    ;; Cuando exista lista-combinaciones, descomentar la llamada:
    ;; (exportar-combinaciones-json
    ;;   "combinaciones_salida.json"
    ;;   lista-combinaciones)

    (displayln "\nDatos importados. Listos para el filtrado.")
    (void)))

;; Se ejecuta al iniciar main.rkt o el futuro main.exe.
;; Orden obligatorio: preferencias primero, catalogo despues.
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
          (eprintf "Ejemplo: main.exe Estudiante1.json catalogo_salida.json\n")
          (exit 1)))))
