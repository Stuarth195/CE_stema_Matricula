#lang typed/racket

(provide (all-defined-out))
(require typed/json)
(require "Estructuras.rkt")

;; Lee el archivo JSON y retorna la representación intermedia (hashes y listas)

#| 
-> llamada remota que devuele un string y otro dato cualquiera (descripcion / caso base)
 call-with-input-file metodo de racket que lee el archivo de entrada y lo pasa como argumento a la funcion
read-json funcion de racket lee la entrada pasada por (call-with-input-file) y lo parsea en formato hash
|#

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

;; 2. Función que parsea y crea la información de un grupo (Grupo)
;; Usa parsear-horario-info para convertir cada bloque del JSON en un Horario-info
(: parsear-grupo (-> Any Grupo))
(define (parsear-grupo objeto-json-grupo)
  (let* ([objeto-grupo-json (if (hash? objeto-json-grupo) objeto-json-grupo #hasheq())]

         ;; Extracción y validación del número de grupo
         [numero-en-bruto (hash-ref objeto-grupo-json 'numero (lambda () #f))]
         [numero-extraido (if (exact-integer? numero-en-bruto) numero-en-bruto 0)]

         ;; Extracción y validación de la lista de bloques horarios
         [bloques-en-bruto (hash-ref objeto-grupo-json 'bloques (lambda () '()))]
         [lista-bloques-json (if (list? bloques-en-bruto) bloques-en-bruto '())]

         ;; Cada bloque del JSON se convierte en un Horario-info
         [lista-horarios-del-grupo (map parsear-horario-info lista-bloques-json)])

    ;; Construcción final de la estructura tipada Grupo
    (Grupo numero-extraido lista-horarios-del-grupo)))


;; 3. Función que parsea y crea la información de un curso (Curso)
;; Usa parsear-grupo para convertir cada grupo del JSON en un Grupo
(: parsear-curso (-> Any Curso))
(define (parsear-curso objeto-json-curso)
  (let* ([objeto-curso-json (if (hash? objeto-json-curso) objeto-json-curso #hasheq())]

         ;; Extracción y validación de la carrera
         [carrera-en-bruto (hash-ref objeto-curso-json 'carrera (lambda () #f))]
         [carrera-extraida (if (string? carrera-en-bruto) carrera-en-bruto "")]

         ;; Extracción y validación del código
         [codigo-en-bruto (hash-ref objeto-curso-json 'codigo (lambda () #f))]
         [codigo-extraido (if (string? codigo-en-bruto) codigo-en-bruto "")]

         ;; Extracción y validación del nombre
         [nombre-en-bruto (hash-ref objeto-curso-json 'nombre (lambda () #f))]
         [nombre-extraido (if (string? nombre-en-bruto) nombre-en-bruto "")]

         ;; Extracción y validación de los créditos
         [creditos-en-bruto (hash-ref objeto-curso-json 'creditos (lambda () #f))]
         [creditos-extraidos (if (exact-integer? creditos-en-bruto) creditos-en-bruto 0)]

         ;; Extracción de los grupos: cada elemento pasa por parsear-grupo
         [grupos-en-bruto (hash-ref objeto-curso-json 'grupos (lambda () '()))]
         [lista-grupos-json (if (list? grupos-en-bruto) grupos-en-bruto '())]
         [lista-grupos-del-curso (map parsear-grupo lista-grupos-json)]

         ;; Extracción de los requisitos: solo se conservan los elementos que sean String
         [requisitos-en-bruto (hash-ref objeto-curso-json 'requisitos (lambda () '()))]
         [lista-requisitos-json (if (list? requisitos-en-bruto) requisitos-en-bruto '())]
         [lista-requisitos-extraidos (filter string? lista-requisitos-json)]

         ;; Extracción del correquisito (String o #f cuando el JSON trae null)
         [correquisito-en-bruto (hash-ref objeto-curso-json 'correquisito (lambda () #f))]
         [correquisito-extraido (if (string? correquisito-en-bruto) correquisito-en-bruto #f)]

         ;; Banderas calculadas por el módulo de C (las llaves del JSON usan guion bajo)
         [choca-en-bruto (hash-ref objeto-curso-json 'choca_con_alguno (lambda () #f))]
         [choca-extraido (eq? choca-en-bruto #t)]

         [puede-matricular-en-bruto (hash-ref objeto-curso-json 'puede_matricular (lambda () #f))]
         [puede-matricular-extraido (eq? puede-matricular-en-bruto #t)])

    ;; Construcción final de la estructura tipada Curso(Lo arma)
    (Curso carrera-extraida
           codigo-extraido
           nombre-extraido
           creditos-extraidos
           lista-grupos-del-curso
           lista-requisitos-extraidos
           correquisito-extraido
           choca-extraido
           puede-matricular-extraido)))

;; 4. Función que parsea un curso de interés individual
(: parsear-curso-interes (-> Any Curso-Interes))
(define (parsear-curso-interes objeto-json-curso-interes)
  (let* ([objeto-ci-json (if (hash? objeto-json-curso-interes) objeto-json-curso-interes #hasheq())]
         
         ;; Extracción y validación del código del curso
         [codigo-en-bruto (hash-ref objeto-ci-json 'codigo (lambda () ""))]
         [codigo-extraido (if (string? codigo-en-bruto) codigo-en-bruto "")]
         
         ;; Extracción de la lista de grupos de interés (validando enteros)
         [grupos-en-bruto (hash-ref objeto-ci-json 'grupos (lambda () '()))]
         [lista-grupos-json (if (list? grupos-en-bruto) grupos-en-bruto '())]
         [lista-grupos-extraidos (filter exact-integer? lista-grupos-json)])
    
    ;; Construcción final de la estructura tipada Curso-Interes
    (Curso-Interes codigo-extraido lista-grupos-extraidos)))

;; 5. Función que parsea la preferencia completa del estudiante
(: parsear-preferencia (-> Any Preferencia))
(define (parsear-preferencia objeto-json-preferencia)
  (let* ([objeto-pref-json (if (hash? objeto-json-preferencia) objeto-json-preferencia #hasheq())]
         
         ;; Extracción y validación del carnet
         [carnet-en-bruto (hash-ref objeto-pref-json 'carnet (lambda () ""))]
         [carnet-extraido (if (string? carnet-en-bruto) carnet-en-bruto "")]
         
         ;; Extracción de los cursos de interés
         [cursos-en-bruto (hash-ref objeto-pref-json 'cursos_interes (lambda () '()))]
         [lista-cursos-json (if (list? cursos-en-bruto) cursos-en-bruto '())]
         [cursos-interes-extraidos (map parsear-curso-interes lista-cursos-json)]
         
         ;; Extracción de créditos mínimos
         [cmin-en-bruto (hash-ref objeto-pref-json 'creditos_min (lambda () 0))]
         [creditos-min-extraidos (if (exact-integer? cmin-en-bruto) cmin-en-bruto 0)]
         
         ;; Extracción de créditos máximos
         [cmax-en-bruto (hash-ref objeto-pref-json 'creditos_max (lambda () 0))]
         [creditos-max-extraidos (if (exact-integer? cmax-en-bruto) cmax-en-bruto 0)])
    
    ;; Construcción final de la estructura tipada Preferencia
    (Preferencia carnet-extraido
                 cursos-interes-extraidos
                 creditos-min-extraidos
                 creditos-max-extraidos)))

;; 6. Función pública para leer el archivo JSON de preferencias del estudiante
(: leer-preferencias-estudiante (-> String Preferencia))
(define (leer-preferencias-estudiante ruta-archivo)
  (parsear-preferencia (leer-json-intermedio ruta-archivo)))



