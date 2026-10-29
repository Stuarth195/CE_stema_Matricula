#lang typed/racket

(require typed/json)
(require "Estructuras.rkt")

;; Lee el archivo JSON y retorna la representación intermedia (hashes y listas)

#| -> llamada remota que devuele un string y otro dato cualquiera (descripcion / caso base)
 call-with-input-file metodo de racket que lee el archivo de entrada y lo pasa como argumento a la funcion
read-json funcion de racket lee la entrada pasada por (call-with-input-file) y lo parsea en formato hash|#

(: leer-json-intermedio (-> String Any))
(define (leer-json-intermedio ruta)
  (call-with-input-file ruta read-json))

;; Imprime la estructura intermedia en la consola para inspeccionar su contenido (solo para debug)
(: imprimir-intermedio (-> Any Void))
(define (imprimir-intermedio datos)
  (write datos)
  (newline))

;; Ruta del archivo JSON exportado por C
(define ruta-archivo "C:/Users/shoko/OneDrive/Attachments/Documents/GitHub/CE_stema_Matricula/catalogo_salida.json")

;; 1. Obtenemos la estructura intermedia
(define json-intermedio (leer-json-intermedio ruta-archivo))

;; 2. Lo imprimimos en consola para analizarlo
(imprimir-intermedio json-intermedio)