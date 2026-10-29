#lang typed/racket

(require typed/json)
(require "Estructuras.rkt")
(require "Importar.rkt")

;; --- PRUEBA AISLADA PARA HORARIOS ---

;; Función para imprimir en consola los detalles de una estructura Horario-info
(: imprimir-horario-info (-> Horario-info Void))
(define (imprimir-horario-info horario-a-imprimir)
  (let* ([dia-del-horario (Horario-info-dia horario-a-imprimir)]
         [hora-de-inicio (Horario-info-inicio horario-a-imprimir)]
         [hora-de-fin (Horario-info-fin horario-a-imprimir)])
    
    (printf "-> [Horario] Día: ~a | Inicio: ~a | Fin: ~a\n"
            (if dia-del-horario dia-del-horario "No asignado")
            (if hora-de-inicio hora-de-inicio "No asignado")
            (if hora-de-fin hora-de-fin "No asignado"))))

;; Ruta del archivo JSON exportado por C
(define ruta-archivo "C:/Users/shoko/OneDrive/Attachments/Documents/GitHub/CE_stema_Matricula/catalogo_salida.json")

;; 1. Leemos el JSON intermedio asegurando que sea un hash
(define json-datos 
  (let ([datos (leer-json-intermedio ruta-archivo)])
    (if (hash? datos) datos #hasheq())))

;; 2. Extracción segura y tipada de los cursos
(define lista-cursos 
  (let ([c (hash-ref json-datos 'cursos (lambda () '()))])
    (if (list? c) c '())))

(define primer-curso 
  (if (not (null? lista-cursos))
      (let ([elem (car lista-cursos)])
        (if (hash? elem) elem #hasheq()))
      #hasheq()))

;; 3. Extracción segura y tipada de los grupos
(define lista-grupos 
  (let ([g (hash-ref primer-curso 'grupos (lambda () '()))])
    (if (list? g) g '())))

(define primer-grupo 
  (if (not (null? lista-grupos))
      (let ([elem (car lista-grupos)])
        (if (hash? elem) elem #hasheq()))
      #hasheq()))

;; 4. Extracción segura y tipada de los bloques horarios
(define lista-bloques 
  (let ([b (hash-ref primer-grupo 'bloques (lambda () '()))])
    (if (list? b) b '())))

(define primer-bloque-json 
  (if (not (null? lista-bloques))
      (let ([elem (car lista-bloques)])
        (if (hash? elem) elem #hasheq((dia . "SAB") (inicio . "08:00") (fin . "11:00"))))
      #hasheq((dia . "SAB") (inicio . "08:00") (fin . "11:00"))))

;; 5. Parseamos el bloque con nuestra función de horario
(define horario-desde-json (parsear-horario-info primer-bloque-json))

;; 6. Imprimimos el resultado en consola
(displayln "Prueba con horario extraído del JSON:")
(imprimir-horario-info horario-desde-json)





;; --- PRUEBA INDEPENDIENTE: GRUPO ---
;; Imprime únicamente el objeto Grupo construido con datos reales del JSON
 
;; Ruta del archivo JSON exportado por C
(define ruta-archivo "C:/Users/shoko/OneDrive/Attachments/Documents/GitHub/CE_stema_Matricula/catalogo_salida.json")
 
;; 1. Leemos el JSON intermedio asegurando que sea un hash
(define json-datos
  (let ([datos (leer-json-intermedio ruta-archivo)])
    (if (hash? datos) datos #hasheq())))
 
;; 2. Extracción segura y tipada de los cursos
(define lista-cursos
  (let ([cursos-en-bruto (hash-ref json-datos 'cursos (lambda () '()))])
    (if (list? cursos-en-bruto) cursos-en-bruto '())))
 
(define primer-curso
  (if (not (null? lista-cursos))
      (let ([elemento-curso (car lista-cursos)])
        (if (hash? elemento-curso) elemento-curso #hasheq()))
      #hasheq()))
 
;; 3. Extracción segura y tipada de los grupos del primer curso
(define lista-grupos
  (let ([grupos-en-bruto (hash-ref primer-curso 'grupos (lambda () '()))])
    (if (list? grupos-en-bruto) grupos-en-bruto '())))
 
(define primer-grupo-json
  (if (not (null? lista-grupos))
      (car lista-grupos)
      #hasheq()))
 
;; 4. Parseamos el grupo con nuestra función de grupo
(define grupo-desde-json (parsear-grupo primer-grupo-json))
 
;; 5. Imprimimos únicamente el objeto Grupo
(displayln "Prueba de Grupo con datos reales del JSON:")
(displayln grupo-desde-json)
 

  
;; --- PRUEBA INDEPENDIENTE: CURSO (GENERAL) ---
;; Imprime el objeto Curso completo: carrera, código, nombre, créditos,
;; todos sus grupos (con sus horarios), requisitos, correquisito y banderas
 
;; Ruta del archivo JSON exportado por C
(define ruta-archivo "C:/Users/shoko/OneDrive/Attachments/Documents/GitHub/CE_stema_Matricula/catalogo_salida.json")
 
;; 1. Leemos el JSON intermedio asegurando que sea un hash
(define json-datos
  (let ([datos (leer-json-intermedio ruta-archivo)])
    (if (hash? datos) datos #hasheq())))
 
;; 2. Extracción segura y tipada de los cursos
(define lista-cursos
  (let ([cursos-en-bruto (hash-ref json-datos 'cursos (lambda () '()))])
    (if (list? cursos-en-bruto) cursos-en-bruto '())))
 
(define primer-curso-json
  (if (not (null? lista-cursos))
      (car lista-cursos)
      #hasheq()))
 
;; 3. Parseamos el curso completo con nuestra función de curso
(define curso-desde-json (parsear-curso primer-curso-json))
 
;; 4. Imprimimos el objeto Curso completo
(displayln "Prueba de Curso (general) con datos reales del JSON:")
(displayln curso-desde-json)
 