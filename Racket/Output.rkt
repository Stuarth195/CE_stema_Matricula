#lang typed/racket

(require typed/json
         "Estructuras.rkt")

(provide (all-defined-out))

;; 1. Convierte un Horario-info a JSExpr.
;; Un campo opcional ausente se representa como null en JSON.
(: horario->jsexpr (-> Horario-info JSExpr))
(define (horario->jsexpr h)
  (hasheq 'dia (or (Horario-info-dia h) 'null)
          'inicio (or (Horario-info-inicio h) 'null)
          'fin (or (Horario-info-fin h) 'null)))

;; 2. Convierte un Grupo a JSExpr.
(: grupo->jsexpr (-> Grupo JSExpr))
(define (grupo->jsexpr g)
  (hasheq 'numero (Grupo-numero g)
          'bloques (map horario->jsexpr (Grupo-Horario-Grupo g))))

;; 3. Convierte un Curso a JSExpr.
(: curso->jsexpr (-> Curso JSExpr))
(define (curso->jsexpr c)
  (hasheq 'carrera (Curso-carrera c)
          'codigo (Curso-codigo c)
          'nombre (Curso-nombre c)
          'creditos (Curso-creditos c)
          'grupos (map grupo->jsexpr (Curso-grupos c))
          'requisitos (Curso-requisitos c)
          'correquisito (or (Curso-correquisito c) 'null)
          'choca_con_alguno (Curso-choca-con-alguno c)
          'puede_matricular (Curso-puede-matricular c)))

;; 4. Convierte un par (Curso . Grupo) a JSExpr.
(: par->jsexpr (-> (Pairof Curso Grupo) JSExpr))
(define (par->jsexpr par)
  (let ([curso (car par)]
        [grupo (cdr par)])
    (hasheq 'curso (curso->jsexpr curso)
            'grupo (grupo->jsexpr grupo))))

;; 5. Convierte una Combinacion a JSExpr.
;; Los pares de UNA combinacion siguen siendo una lista finita.
(: combinacion->jsexpr (-> Combinacion JSExpr))
(define (combinacion->jsexpr comb)
  (hasheq 'pares (map par->jsexpr (Combinacion-pares comb))
          'creditos_totales (Combinacion-creditos-totales comb)
          'carreras_origen (Combinacion-carreras-origen comb)))

;; Escribe un JSExpr como JSON indentado.
;; Se conserva la convencion original: #t -> 1 y #f -> 0.
;; 'null se exporta como el valor JSON null, no como 0.
(: escribir-json-bonito (-> JSExpr Output-Port Integer Void))
(define (escribir-json-bonito val port nivel)
  (cond
    [(hash? val)
     (display "{\n" port)
     (let* ([keys (hash-keys val)]
            [len (length keys)])
       (for ([k keys] [i (in-naturals)])
         (for ([_ (in-range (+ nivel 1))])
           (display "  " port))
         ;; write-json garantiza el escapado correcto de las claves.
         (write-json (symbol->string k) port)
         (display ": " port)
         (escribir-json-bonito (hash-ref val k) port (+ nivel 1))
         (unless (= i (sub1 len))
           (display "," port))
         (display "\n" port)))
     (for ([_ (in-range nivel)])
       (display "  " port))
     (display "}" port)]

    [(list? val)
     (display "[\n" port)
     (let ([len (length val)])
       (for ([elem val] [i (in-naturals)])
         (for ([_ (in-range (+ nivel 1))])
           (display "  " port))
         (escribir-json-bonito elem port (+ nivel 1))
         (unless (= i (sub1 len))
           (display "," port))
         (display "\n" port)))
     (for ([_ (in-range nivel)])
       (display "  " port))
     (display "]" port)]

    [else
     (cond
       [(eq? val #t) (display "1" port)]
       [(eq? val #f) (display "0" port)]
       [else (write-json val port) (void)])]))

;; 6. Recorre una secuencia de combinaciones sin materializarla.
;; Los streams de Racket son secuencias, por lo que pueden
;; pasarse directamente.
;; Se mantienen las comas correctas sin usar set!.
(: escribir-combinaciones-stream
   (-> (Sequenceof Combinacion) Output-Port Void))
(define (escribir-combinaciones-stream combinaciones port)
  (for ([comb : Combinacion combinaciones]
        [indice : Natural (in-naturals)])
    (unless (zero? indice) (display ",\n" port))
    (display "  " port)
    (escribir-json-bonito (combinacion->jsexpr comb) port 1)))

;; 7. Exporta un stream u otra secuencia sin construir
;; una lista completa.
(: exportar-combinaciones-json
   (-> String (Sequenceof Combinacion) Void))
(define (exportar-combinaciones-json ruta combinaciones)
  (call-with-output-file ruta
    (lambda ([out-port : Output-Port])
      (display "[\n" out-port)
      (escribir-combinaciones-stream combinaciones out-port)
      (display "\n]" out-port))
    #:exists 'replace))