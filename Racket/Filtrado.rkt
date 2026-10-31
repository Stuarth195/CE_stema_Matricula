#lang typed/racket

(require "Estructuras.rkt")

(provide (all-defined-out))

;; ============================================================
;; DEFINICIÓN DE STREAM PEREZOSO TIPADO (Inmutabilidad pura)
;; ============================================================

(struct (A) Stream-Cons ([head : A]
                         [tail : (-> (Lazy-Stream A))])
  #:transparent)

(define-type (Lazy-Stream A) (U Null (Stream-Cons A)))

;; ============================================================
;; POLIMORFISMO PARAMÉTRICO (Requisito 5 de la rúbrica - 8%)
;; ============================================================

;; 1. Filtro polimórfico perezoso sobre Streams:
(: filtrar-stream (All (A) (-> (-> A Boolean) (Lazy-Stream A) (Lazy-Stream A))))
(define (filtrar-stream pred st)
  (cond
    [(null? st) '()]
    [else
     (let ([cabeza (Stream-Cons-head st)]
           [cola-fn (Stream-Cons-tail st)])
       (if (pred cabeza)
           (Stream-Cons cabeza (lambda () (filtrar-stream pred (cola-fn))))
           (filtrar-stream pred (cola-fn))))]))

;; 2. Mapeo polimórfico perezoso sobre Streams:
(: mapear-stream (All (A B) (-> (-> A B) (Lazy-Stream A) (Lazy-Stream B))))
(define (mapear-stream fn st)
  (cond
    [(null? st) '()]
    [else
     (Stream-Cons (fn (Stream-Cons-head st))
                  (lambda () (mapear-stream fn ((Stream-Cons-tail st)))))]))

;; 3. Concatenación perezosa de dos Streams:
(: concatenar-streams (All (A) (-> (Lazy-Stream A) (-> (Lazy-Stream A)) (Lazy-Stream A))))
(define (concatenar-streams st1 cola-st2-fn)
  (cond
    [(null? st1) (cola-st2-fn)]
    [else
     (Stream-Cons (Stream-Cons-head st1)
                  (lambda () (concatenar-streams ((Stream-Cons-tail st1)) cola-st2-fn)))]))

;; 4. Filtro polimórfico para listas (reutilizable para cursos, grupos, etc.):
(: filtrar-lista-polimorfico (All (A) (-> (-> A Boolean) (Listof A) (Listof A))))
(define (filtrar-lista-polimorfico pred lst)
  (cond
    [(null? lst) '()]
    [(pred (car lst)) (cons (car lst) (filtrar-lista-polimorfico pred (cdr lst)))]
    [else (filtrar-lista-polimorfico pred (cdr lst))]))

;; 5. Eliminación polimórfica de duplicados manteniendo el orden original:
(: eliminar-duplicados-polimorfico (All (A) (-> (Listof A) (Listof A))))
(define (eliminar-duplicados-polimorfico lst)
  (let loop ([restantes : (Listof A) lst]
             [vistos : (Listof A) '()])
    (cond
      [(null? restantes) (reverse vistos)]
      [(member (car restantes) vistos) (loop (cdr restantes) vistos)]
      [else (loop (cdr restantes) (cons (car restantes) vistos))])))

;; 6. Adaptador de (Lazy-Stream A) a (Sequenceof A) nativo para Output.rkt:
(: stream->secuencia (All (A) (-> (Lazy-Stream A) (Sequenceof A))))
(define (stream->secuencia st-inicial)
  (make-do-sequence
   (lambda ()
     (values
      (lambda ([s : (Lazy-Stream A)])
        (if (null? s)
            (error 'stream->secuencia "Stream vacío")
            (Stream-Cons-head s)))
      (lambda ([s : (Lazy-Stream A)])
        (if (null? s)
            '()
            ((Stream-Cons-tail s))))
      st-inicial
      (lambda ([s : (Lazy-Stream A)]) (not (null? s)))
      (lambda ([v : A]) #t)
      (lambda ([s : (Lazy-Stream A)] [v : A]) #t)))))

;; ============================================================
;; APLICACIÓN AL FILTRADO POR RANGO DE CRÉDITOS
;; ============================================================

(: filtrar-por-creditos (-> (Lazy-Stream Combinacion) Integer Integer (Lazy-Stream Combinacion)))
(define (filtrar-por-creditos st-combinaciones min-c max-c)
  (filtrar-stream
   (lambda ([comb : Combinacion])
     (let ([cred (Combinacion-creditos-totales comb)])
       (and (>= cred min-c) (<= cred max-c))))
   st-combinaciones))