#lang typed/racket

(require typed/json)
(require "Estructuras.rkt")

(provide (all-defined-out))

;; 1. Convierte un Horario-info a JSExpr
(: horario->jsexpr (-> Horario-info JSExpr))
(define (horario->jsexpr h)
  (hasheq 'dia (or (Horario-info-dia h) #f)
          'inicio (or (Horario-info-inicio h) #f)
          'fin (or (Horario-info-fin h) #f)))

;; 2. Convierte un Grupo a JSExpr
(: grupo->jsexpr (-> Grupo JSExpr))
(define (grupo->jsexpr g)
  (hasheq 'numero (Grupo-numero g)
          'bloques (map horario->jsexpr (Grupo-Horario-Grupo g))))

;; 3. Convierte un Curso a JSExpr
(: curso->jsexpr (-> Curso JSExpr))
(define (curso->jsexpr c)
  (hasheq 'carrera (Curso-carrera c)
          'codigo (Curso-codigo c)
          'nombre (Curso-nombre c)
          'creditos (Curso-creditos c)
          'grupos (map grupo->jsexpr (Curso-grupos c))
          'requisitos (Curso-requisitos c)
          'correquisito (or (Curso-correquisito c) #f)
          'choca_con_alguno (Curso-choca-con-alguno c)
          'puede_matricular (Curso-puede-matricular c)))

;; 4. Convierte un par (Curso . Grupo) a JSExpr
(: par->jsexpr (-> (Pairof Curso Grupo) JSExpr))
(define (par->jsexpr par)
  (let ([curso (car par)]
        [grupo (cdr par)])
    (hasheq 'curso (curso->jsexpr curso)
            'grupo (grupo->jsexpr grupo))))

;; 5. Convierte una Combinacion a JSExpr
(: combinacion->jsexpr (-> Combinacion JSExpr))
(define (combinacion->jsexpr comb)
  (hasheq 'pares (map par->jsexpr (Combinacion-pares comb))
          'creditos_totales (Combinacion-creditos-totales comb)
          'carreras_origen (Combinacion-carreras-origen comb)))

;; Función auxiliar recursiva para escribir el JSON con indentación y booleanos como 1 y 0
(: escribir-json-bonito (-> JSExpr Output-Port Integer Void))
(define (escribir-json-bonito val port nivel)
  (cond
    [(hash? val)
     (display "{\n" port)
     (let* ([keys (hash-keys val)]
            [len (length keys)])
       (for ([k keys] [i (in-naturals)])
         ;; Imprimir indentación actual
         (for ([_ (in-range (+ nivel 1))]) (display "  " port))
         ;; Imprimir clave como string JSON
         (write (symbol->string k) port)
         (display ": " port)
         ;; Imprimir valor recursivamente
         (escribir-json-bonito (hash-ref val k) port (+ nivel 1))
         ;; Coma si no es el último elemento
         (unless (= i (sub1 len))
           (display "," port))
         (display "\n" port)))
     (for ([_ (in-range nivel)]) (display "  " port))
     (display "}" port)]
    [(list? val)
     (display "[\n" port)
     (let ([len (length val)])
       (for ([elem val] [i (in-naturals)])
         (for ([_ (in-range (+ nivel 1))]) (display "  " port))
         (escribir-json-bonito elem port (+ nivel 1))
         (unless (= i (sub1 len))
           (display "," port))
         (display "\n" port)))
     (for ([_ (in-range nivel)]) (display "  " port))
     (display "]" port)]
    [else
     ;; Conversión de booleanos de Racket a 1 (verdadero) y 0 (falso)
     (cond
       [(eq? val #t) (display "1" port)]
       [(eq? val #f) (display "0" port)]
       [else (write val port)])]))

;; 6. Función principal para exportar la lista de combinaciones a un archivo JSON estructurado
(: exportar-combinaciones-json (-> String (Listof Combinacion) Void))
(define (exportar-combinaciones-json ruta combinaciones)
  (let* ([jsexpr-lista : JSExpr (map combinacion->jsexpr combinaciones)]
         [out-port (open-output-file ruta #:exists 'replace)])
    (escribir-json-bonito jsexpr-lista out-port 0)
    (close-output-port out-port)))