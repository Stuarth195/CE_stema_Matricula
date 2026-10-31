#lang typed/racket

(require "Estructuras.rkt"
         "Filtrado.rkt"
         racket/string)

(provide (all-defined-out))

;; ============================================================
;; VALIDACIÓN DE HORARIOS Y CHOQUES (Sin mutación)
;; ============================================================

(: hora->minutos (-> String Integer))
(define (hora->minutos hora-str)
  (let* ([partes (string-split hora-str ":")]
         [h-str (if (pair? partes) (car partes) #f)]
         [m-str (and (pair? partes) (pair? (cdr partes)) (cadr partes))]
         [h (and h-str (string->number h-str))]
         [m (and m-str (string->number m-str))])
    (cast (+ (* (if (exact-integer? h) h 0) 60)
             (if (exact-integer? m) m 0))
          Integer)))

(: horario-chocan? (-> Horario-info Horario-info Boolean))
(define (horario-chocan? h1 h2)
  (let ([dia1 (Horario-info-dia h1)]
        [dia2 (Horario-info-dia h2)]
        [ini1 (Horario-info-inicio h1)]
        [fin1 (Horario-info-fin h1)]
        [ini2 (Horario-info-inicio h2)]
        [fin2 (Horario-info-fin h2)])
    (cond
      [(or (not dia1) (not dia2) (not ini1) (not fin1) (not ini2) (not fin2)) #f]
      [(and (string? dia1) (string? dia2) (string-ci=? dia1 dia2)
            (not (string=? ini1 "")) (not (string=? fin1 ""))
            (not (string=? ini2 "")) (not (string=? fin2 "")))
       (let ([m-ini1 (hora->minutos ini1)]
             [m-fin1 (hora->minutos fin1)]
             [m-ini2 (hora->minutos ini2)]
             [m-fin2 (hora->minutos fin2)])
         (< (max m-ini1 m-ini2) (min m-fin1 m-fin2)))]
      [else #f])))

(: grupo-choca? (-> Grupo Grupo Boolean))
(define (grupo-choca? g1 g2)
  (ormap (lambda ([h1 : Horario-info])
           (ormap (lambda ([h2 : Horario-info])
                    (horario-chocan? h1 h2))
                  (Grupo-Horario-Grupo g2)))
         (Grupo-Horario-Grupo g1)))

(: choca-con-seleccionados? (-> (Pairof Curso Grupo) (Listof (Pairof Curso Grupo)) Boolean))
(define (choca-con-seleccionados? candidato seleccionados)
  (let ([grupo-cand (cdr candidato)])
    (ormap (lambda ([par : (Pairof Curso Grupo)])
             (grupo-choca? grupo-cand (cdr par)))
           seleccionados)))

;; ============================================================
;; PREPARACIÓN DE OPCIONES Y ELEGIBILIDAD
;; ============================================================

(: buscar-curso-en-catalogo (-> String (Listof Curso) (U Curso #f)))
(define (buscar-curso-en-catalogo codigo catalogo)
  (let ([encontrados
         ;; Reutilización #1 de la función con polimorfismo paramétrico
         (filtrar-lista-polimorfico
          (lambda ([c : Curso])
            (and (string-ci=? (Curso-codigo c) codigo)
                 (Curso-puede-matricular c)))
          catalogo)])
    (if (null? encontrados) #f (car encontrados))))

(: preparar-opciones-cursos (-> (Listof Curso-Interes) (Listof Curso) (Listof (Listof (Pairof Curso Grupo)))))
(define (preparar-opciones-cursos intereses catalogo)
  (let loop ([restantes : (Listof Curso-Interes) intereses]
             [acum : (Listof (Listof (Pairof Curso Grupo))) '()])
    (cond
      [(null? restantes) (reverse acum)]
      [else
       (let* ([interes (car restantes)]
              [codigo (Curso-Interes-codigo interes)]
              [curso (buscar-curso-en-catalogo codigo catalogo)])
         (if (not curso)
             (begin
               (printf "[Aviso] El curso '~a' no existe en el catálogo o tiene puede_matricular=false.\n" codigo)
               (loop (cdr restantes) acum))
             (let* ([nums-interes (Curso-Interes-grupos interes)]
                    [todos-grupos (Curso-grupos curso)]
                    ;; Reutilización #2 de la función con polimorfismo paramétrico
                    [grupos-filtrados
                     (if (null? nums-interes)
                         todos-grupos
                         (filtrar-lista-polimorfico
                          (lambda ([g : Grupo])
                            (if (member (Grupo-numero g) nums-interes) #t #f))
                          todos-grupos))])
               (if (null? grupos-filtrados)
                   (begin
                     (printf "[Aviso] El curso '~a' no tiene ninguno de los grupos solicitados: ~a\n" codigo nums-interes)
                     (loop (cdr restantes) acum))
                   (let ([pares-curso (map (lambda ([g : Grupo]) (cons curso g))
                                           grupos-filtrados)])
                     (printf "[OK] Curso habilitado incluido: ~a (~a créditos, ~a grupos válidos)\n"
                             codigo (Curso-creditos curso) (length pares-curso))
                     (loop (cdr restantes) (cons pares-curso acum)))))))])))

;; ============================================================
;; GENERACIÓN PEREZOSA DE COMBINACIONES CON STREAMS
;; ============================================================

(: pares->combinacion (-> (Listof (Pairof Curso Grupo)) Combinacion))
(define (pares->combinacion pares)
  (let* ([creditos (apply + (map (lambda ([p : (Pairof Curso Grupo)])
                                   (Curso-creditos (car p)))
                                 pares))]
         [carreras (eliminar-duplicados-polimorfico
                    (map (lambda ([p : (Pairof Curso Grupo)])
                           (Curso-carrera (car p)))
                         pares))])
    (Combinacion pares creditos carreras)))

(: expandir-opciones-curso
   (-> (Listof (Pairof Curso Grupo))
       (Listof (Listof (Pairof Curso Grupo)))
       (Listof (Pairof Curso Grupo))
       (Lazy-Stream (Listof (Pairof Curso Grupo)))))
(define (expandir-opciones-curso opciones-curso resto-cursos seleccionados)
  (cond
    [(null? opciones-curso) '()]
    [else
     (let ([candidato (car opciones-curso)]
           [otras-opciones (cdr opciones-curso)])
       (if (choca-con-seleccionados? candidato seleccionados)
           (expandir-opciones-curso otras-opciones resto-cursos seleccionados)
           (concatenar-streams
            (generar-ramas-stream resto-cursos
                                  (append seleccionados (list candidato)))
            (lambda ()
              (expandir-opciones-curso otras-opciones resto-cursos seleccionados)))))]))

(: generar-ramas-stream
   (-> (Listof (Listof (Pairof Curso Grupo)))
       (Listof (Pairof Curso Grupo))
       (Lazy-Stream (Listof (Pairof Curso Grupo)))))
(define (generar-ramas-stream cursos-restantes seleccionados)
  (cond
    [(null? cursos-restantes)
     (if (null? seleccionados)
         '()
         (Stream-Cons seleccionados (lambda () '())))]
    [else
     (let ([opciones-actual (car cursos-restantes)]
           [resto (cdr cursos-restantes)])
       (concatenar-streams
        (expandir-opciones-curso opciones-actual resto seleccionados)
        (lambda ()
          (generar-ramas-stream resto seleccionados))))]))

(: generar-combinaciones-stream (-> (Listof Curso) Preferencia (Lazy-Stream Combinacion)))
(define (generar-combinaciones-stream catalogo prefs)
  (displayln "\n========== DIAGNÓSTICO DE GENERACIÓN ==========")
  (let* ([intereses (Preferencia-cursos-interes prefs)]
         [opciones (preparar-opciones-cursos intereses catalogo)]
         [stream-pares (generar-ramas-stream opciones '())])
    (printf "Total de cursos habilitados para combinar: ~a\n" (length opciones))
    (displayln "===============================================")
    (mapear-stream pares->combinacion stream-pares)))