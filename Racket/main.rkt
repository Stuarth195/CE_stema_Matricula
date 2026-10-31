#lang typed/racket

(require "Estructuras.rkt"
         "Importar.rkt"
         "Output.rkt"
         racket/string)

;; ============================================================
;; AUXILIARES DE HORARIOS Y CHOQUES (Inmutabilidad pura)
;; ============================================================

(: hora->minutos (-> String Integer))
(define (hora->minutos hora-str)
  (let* ([partes (string-split hora-str ":")]
         [h-str (if (pair? partes) (car partes) #f)]
         [m-str (and (pair? partes) (pair? (cdr partes)) (cadr partes))]
         [h (and h-str (string->number h-str))]
         [m (and m-str (string->number m-str))])
    (cast (+ (* (if (integer? h) h 0) 60) (if (integer? m) m 0)) Integer)))

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
      [(and (string? dia1) (string? dia2) (string=? dia1 dia2)
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

(: pares-chocan? (-> (Listof (Pairof Curso Grupo)) Boolean))
(define (pares-chocan? pares)
  (let loop ([ls : (Listof (Pairof Curso Grupo)) pares])
    (cond
      [(null? ls) #f]
      [else
       (let ([g (cdr (car ls))]
             [resto (cdr ls)])
         (if (ormap (lambda ([p : (Pairof Curso Grupo)])
                      (grupo-choca? g (cdr p)))
                    resto)
             #t
             (loop resto)))])))

;; ============================================================
;; GENERACIÓN DE COMBINACIONES (Inmutable basada en Listas/Secuencias)
;; ============================================================

(: find-curso (-> String (Listof Curso) (U Curso #f)))
(define (find-curso codigo catalogo)
  (let loop ([cat : (Listof Curso) catalogo])
    (cond
      [(null? cat) #f]
      [(string=? (Curso-codigo (car cat)) codigo) (car cat)]
      [else (loop (cdr cat))])))

(: preparar-opciones-cursos (-> (Listof Curso-Interes) (Listof Curso) (Listof (Listof (Pairof Curso Grupo)))))
(define (preparar-opciones-cursos intereses catalogo)
  (filter-map
   (lambda ([interes : Curso-Interes])
     (let ([curso (find-curso (Curso-Interes-codigo interes) catalogo)])
       (if curso
           (let* ([g-interes (Curso-Interes-grupos interes)]
                  [todos-grupos (Curso-grupos curso)]
                  [grupos-filtrados
                   (if (null? g-interes)
                       todos-grupos
                       (filter (lambda ([g : Grupo])
                                 (member (Grupo-numero g) g-interes))
                               todos-grupos))])
             (if (null? grupos-filtrados)
                 #f
                 (map (lambda ([g : Grupo]) (cons curso g)) grupos-filtrados)))
           #f)))
   intereses))

(: cartesian-product (All (a) (-> (Listof (Listof a)) (Listof (Listof a)))))
(define (cartesian-product lists)
  (cond
    [(null? lists) '(())]
    [else
     (let ([first-list (car lists)]
           [rest-prod (cartesian-product (cdr lists))])
       (foldr (lambda ([item : a] [acc : (Listof (Listof a))])
                (append
                 (map (lambda ([comb : (Listof a)])
                        (cons item comb))
                      rest-prod)
                 acc))
              '()
              first-list))]))

(: eliminar-duplicados (-> (Listof String) (Listof String)))
(define (eliminar-duplicados lst)
  (let loop ([l : (Listof String) lst] [seen : (Listof String) '()])
    (cond
      [(null? l) (reverse seen)]
      [(member (car l) seen) (loop (cdr l) seen)]
      [else (loop (cdr l) (cons (car l) seen))])))

(: pares->combinacion (-> (Listof (Pairof Curso Grupo)) Combinacion))
(define (pares->combinacion pares)
  (let* ([creditos (apply + (map (lambda ([p : (Pairof Curso Grupo)])
                                   (Curso-creditos (car p)))
                                 pares))]
         [carreras (eliminar-duplicados
                    (map (lambda ([p : (Pairof Curso Grupo)])
                           (Curso-carrera (car p)))
                         pares))])
    (Combinacion pares creditos carreras)))

(: generar-combinaciones (-> (Listof Curso) Preferencia (Listof Combinacion)))
(define (generar-combinaciones catalogo prefs)
  (let* ([intereses (Preferencia-cursos-interes prefs)]
         [opciones (preparar-opciones-cursos intereses catalogo)]
         [raw-combos (cartesian-product opciones)]
         [valid-combos (filter (lambda ([pares : (Listof (Pairof Curso Grupo))])
                                 (not (pares-chocan? pares)))
                               raw-combos)])
    (map pares->combinacion valid-combos)))

(: filtrar-por-creditos (-> (Listof Combinacion) Integer Integer (Listof Combinacion)))
(define (filtrar-por-creditos combinaciones min-c max-c)
  (filter (lambda ([c : Combinacion])
            (let ([cred (Combinacion-creditos-totales c)])
              (and (>= cred min-c) (<= cred max-c))))
          combinaciones))

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

    (let* ([combinaciones-generadas (generar-combinaciones lista-cursos preferencias)]
           [combinaciones-filtradas (filtrar-por-creditos
                                     combinaciones-generadas
                                     (Preferencia-creditos-min preferencias)
                                     (Preferencia-creditos-max preferencias))])

      (guardar-combinaciones "combinaciones_salida.json" combinaciones-filtradas))

    (displayln "\nCombinaciones generadas, filtradas y exportadas con éxito.")
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
          (eprintf "Ejemplo: main.exe Estudiante1.json catalogo_salida.json\n")
          (exit 1)))))
