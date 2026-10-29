#lang typed/racket

(provide (all-defined-out))
(require typed/json)
(require "Estructuras.rkt")

;; Lee el archivo JSON y retorna la representación intermedia (hashes y listas)

#| -> llamada remota que devuele un string y otro dato cualquiera (descripcion / caso base)
 call-with-input-file metodo de racket que lee el archivo de entrada y lo pasa como argumento a la funcion
read-json funcion de racket lee la entrada pasada por (call-with-input-file) y lo parsea en formato hash|#

(: leer-json-intermedio (-> String Any)); Caso base

(define (leer-json-intermedio ruta) ; definicion
  (call-with-input-file ruta read-json))

;; 1. Función que parsea y crea la información de un bloque de horario individual (Horario-info)
(: parsear-horario-info (-> Any Horario-info))
(define (parsear-horario-info objeto-json-bloque)
  (let* ([objeto-horario-json (if (hash? objeto-json-bloque) objeto-json-bloque #hasheq())]
         
         ;; Extracción y validación del día
         [dia-en-bruto (hash-ref objeto-horario-json 'dia (lambda () #f))]
         [dia-extraido (if (string? dia-en-bruto) dia-en-bruto #f)]
         
         ;; Extracción y validación de la hora de inicio
         [hora-inicio-en-bruto (hash-ref objeto-horario-json 'inicio (lambda () #f))]
         [hora-inicio-extraida (if (string? hora-inicio-en-bruto) hora-inicio-en-bruto #f)]
         
         ;; Extracción y validación de la hora de fin
         [hora-fin-en-bruto (hash-ref objeto-horario-json 'fin (lambda () #f))]
         [hora-fin-extraida (if (string? hora-fin-en-bruto) hora-fin-en-bruto #f)])
    
    ;; Construcción final de la estructura tipada Horario-info
    (Horario-info dia-extraido hora-inicio-extraida hora-fin-extraida)))





















