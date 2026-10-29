#lang typed/racket

(provide (all-defined-out))

;; 1. Estructura para los Horario-infos Horario-infos de cada grupo
(struct Horario-info ([dia : (U String #f)]
                [inicio : (U String #f)]
                [fin : (U String #f)]) #:transparent) ; #transparent permite acceders sus atributos y mostrarlos 

;; 2. Estructura para los grupos de un curso
(struct Grupo ([numero : Integer]
               [Horario-Grupo : (Listof Horario-info)]) #:transparent)

;; 3. Estructura principal para los cursos (incluye el campo 'carrera' que añadimos en C)
(struct Curso ([carrera : String]
               [codigo : String]
               [nombre : String]
               [creditos : Integer]
               [grupos : (Listof Grupo)]
               [requisitos : (Listof String)]
               [correquisito : (U String #f)]
               [choca-con-alguno : Boolean]
               [puede-matricular : Boolean]) #:transparent) 

;; 4. Estructura para las preferencias del estudiante (Fase 2 / Fase 3)
(struct Preferencia ([carnet : String]
                     [cursos-interes : (Listof String)]
                     [creditos-min : Integer]
                     [creditos-max : Integer]) #:transparent)

;; 5. Estructura para las combinaciones válidas (Fase 3)
(struct Combinacion ([pares : (Listof (Pairof Curso Grupo))]
                     [creditos-totales : Integer]
                     [carreras-origen : (Listof String)]) #:transparent)