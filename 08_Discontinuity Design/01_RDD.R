#******************************************************************************# 
# Modelo de regresión discontinua                                              #
# Datos: Programa de tutorías                                                  #
#                                                                              # 
# Autor: - Manuel Cardona Arias <mcardona@poverty-action.org>                  # 
#******************************************************************************# 

rm(list = ls())
setwd("~/../Dropbox/CIDE/Lab Evaluación PP 2020/08_Discontinuity Design/")

library(tidyverse)  # ggplot(), %>%, mutate(), and friends
library(broom)  # Convert models to data frames
library(rdrobust)  # For robust nonparametric regression discontinuity
library(rddensity)  # For nonparametric regression discontinuity density tests
library(modelsummary)  # Create side-by-side regression tables
library(estimatr)
library(kableExtra)  # Fancy table formatting

#///////////////////////////////#
### Descripción del programa ####
#///////////////////////////////#

#El programa a evaluar consiste en que, después de tomar un examen inicial al 
#inicio del ciclo escolar, los alumnos que obtengan un puntaje de 70 o menor son
#automáticamente inscritos a un programa de tutorías gratuitas y recibien asistencia
#durante todo el ciclo.  Al finalizar el ciclo escolar, los estudiantes toman un
#examen final (máximo de 100 puntos) para medir su nivel de aprovechamienton general.

#Tenemos datos de 1,000 alumnos que iniciaron en el mismo ciclo escolar. Todos los
#alumnos tomaron un test inicial y un test final. Aquellos que obtuvieron una
#calificación de 70 o menos fueron inscritos automáticamente al programa de tutorías.

#Los datos NO SON EXPERIMENTALES.

# Cargar datos ----
tutoring <- read_csv("data/tutoring_program.csv")


#La base de datos contiene las siguientes variables:
  #id: Variable que permite identificar al alumno.
    length(unique(tutoring$id))

#entrance_exam: Resultado del examen que el alumno tomó al inicio del ciclo.
#				 La variable puede tomar valores entre 0 y 100; donde los mayores
#				 valores indican un mejor aprovechamiento.
   summary(tutoring$entrance_exam)

#exit_exam: Resultado del examen que el alumno tomó al finalizar el ciclo.
#			 La variable puede tomar valores entre 0 y 100; donde los mayores
#			 valores indican un mejor aprovechamiento. La prueba que toman
#			 al finalizar el curso mide lo mismo que la prueba inicial.
  summary(tutoring$exit_exam)

#tutoring: Esta variable dicotómica indica si el alumno fue inscrito al programa
#			de tutorías.
  table(tutoring$tutoring)
  
  
  #/////////////////#
  ### RDD nítida ####
  #/////////////////#
  
  
# Paso 1: Determinar si el programa es asignado con una regla específica.----
  #En este caso, dada la naturaleza del programa, sabemos que ningún alumno que
  #haya obtenido un puntaje mayor a 70 va a ser elegible para el programa. 
  

# Paso 2: Determinar si el diseño de discontinuidad es nítida o borrosa. ----
  #Ya sabemos que el programa tiene como criterio de elegibilidad un threshold
  #en el puntaje del alumno, sin embargo, necesitamos saber qué tan estrictamente
  #se siguió dicha regla. 
  
  ggplot(tutoring, aes(x = entrance_exam, y = tutoring, color = tutoring)) +
    geom_point(size = 0.5, alpha = 0.5, 
               position = position_jitter(width = 0, height = 0.25, seed = 1234)) + 
    geom_vline(xintercept = 70) + 
    labs(x = "Entrance exam score", y = "Participated in tutoring program") + 
    guides(color = FALSE)
  
  tutoring %>% 
    group_by(tutoring, entrance_exam <= 70) %>% 
    summarize(count = n())
  
  #Dadas las características de la entrega del programa, podemos aseverar que
  #el diseño de discontinuidad es nítido.
  
#Paso 3: Revisar la discontinuidad de la variable de tratamiento, sobre la variable continua cerca del punto de corte. ----
  
  #Algo muy relevante es analizar si no existió manipulación en la variable
  #continua, con el objetivo de que las personas recibieran el tratamiento (es
  #decir, que los profesores hayan calificado a muchos alumnos con 68, 69 o 70
  #solo para que recibieran las tutorías; o que los hayan calificado justi arriba
  #del threshold, solo para no tener que darles clases extra). 
  
  #Para realizar esto, podemos hacer un histograma de la variable continua y
  #analizar algun poible brinco repentino.
  ggplot(tutoring, aes(x = entrance_exam, fill = tutoring)) +
    geom_histogram(binwidth = 2, color = "white", boundary = 70) + 
    geom_vline(xintercept = 70) + 
    labs(x = "Entrance exam score", y = "Count", fill = "In program")
  
  #Parece que no existe un brinco repentino antes o después del 70, sin embargo,
  #parece que la frecuencia de valores mayores a 70 es mayor que la de menores a
  #70; sin embargo, parece que se sigue la misma distribución general.  
  
  
# Paso 4: Revisar discontinuidad en la variable de resultados, sobre la variable continua. -----
  
  #Hacemos una visualización de las calificaciones del examen final, sobre las
  #calificaciones del examen inicial, por la variable de tratamiento.4
  
  ggplot(tutoring, aes(x = entrance_exam, y = exit_exam, color = tutoring)) +
    geom_point(size = 0.5, alpha = 0.5) + 
    geom_smooth(data = filter(tutoring, entrance_exam <= 70), method = "lm") +
    geom_smooth(data = filter(tutoring, entrance_exam > 70), method = "lm") +
    geom_vline(xintercept = 70) +
    labs(x = "Entrance exam score", y = "Exit exam score", color = "Used tutoring")
  
  #Con base en la gráfica, podemos ver que hay una discuntinuidad muy clara.
  #Parece ser que la participación en el programa potencia los resultados en el
  #examen final.
  
# Paso 5: Cuantificar el efecto de la intervención ----
  
  #Estimación paramétrica: Queremos conocer si las calificaciones finales son
  #afectadas por la participación en el programa de tutorías. Podemos elaborar
  #la siguiente regresión lineal:
    
    #   exit_exam = b_0 + b_1(entrance_exam_standard) + b_2(tutoring) + e
  
  #Para volver más fácil la interpretación de los coeficientes, estandarizaremos
  #la variable del entrance_exam, para que en lugar de que muestre la calificación, 
  #muestre qué tan cerca se encuentra del threshold de 70.  
  
  
  tutoring_centered <- tutoring %>% 
    mutate(entrance_centered = entrance_exam - 70)
  
  model_simple <- lm(exit_exam ~ entrance_centered + tutoring,
                     data = tutoring_centered)
  tidy(model_simple)
  
#Paso 6: Interpretar coeficientes ----
  
  #b_0: Intercepto. Dado que la variable del entrance_exam está centrada, la
  #	   constante muestra el promedio de las calificaciones del examen final
  #	   en el threshold de 70.00001 puntos. La gente que obtuvo 70 puntos en 
  #	   el examen inicial, tuvo, en promedio, una calificación de 59.41 en el
  #	   examen final.
  
  #b_1: Es el efecto adicional por cada punto sobre 70 en el examen inicial. 
  #	   Este coeficiente no nos interesa tanto, dado que no queremos conocer
  #	   la relación entre los resultados de ambos exámenes; sólo lo utilizamos
  #	   como variable de control, porque esperamos que los alumnos con mejor
  #	   calificación al entrar, también tengan mejor calificación al salir.
  
  #b_2: Es el efecto del programa de tutorías. Este es el cambio en el intercepto,
  #	   cuando los alumnos reciben el programa de tutorías. Ser participante
  #	   del programa tiene un efecto de 10.8 puntos en la calificación del 
  #	   examen final.
  
  
#Paso 7: Restringir la muestra a una población "similar" ----
  
  #Hasta el momento, ajustamos el modelo para toda la muestra; sin embargo, 
  #lo que más nos interesa es el efecto para las observaciones que se encuentran
  #cerca del threshold.  Las calificaciones que son super bajas o super altas 
  #pueden afectar el tamaño del efecto del programa.
  
  #A continuación, ajustamos el modelo, restringiendo la muestra a los que se
  #encuentran en un rango de -10,+10 puntos respecto al threshold.
  
  model_bw_10 <- lm(exit_exam ~ entrance_centered + tutoring,
                    data = filter(tutoring_centered,
                                  entrance_centered >= -10 & 
                                    entrance_centered <= 10))
  tidy(model_bw_10)
  
  model_bw_5 <- lm(exit_exam ~ entrance_centered + tutoring,
                   data = filter(tutoring_centered,
                                 entrance_centered >= -5 & 
                                   entrance_centered <= 5))
  tidy(model_bw_5)
  
  #Cuando filtramos las observaciones a las que se encuentren más cerca del
  #threshold, obtenemos un coeficiente aun signifivcativo pero menor en tamaño.
  #El efecto del programa de tutorías es de 9.27 puntos en la calificación del
  #examen final. 
  
  #Entre más restrinjamos nuestra muestra, más pequeño el es el coeficiente.
  
  
  #//////////////////#
  ### RDD borrosa ####
  #//////////////////#
  
# Paso 8: Regresión discontinua borrosa ----
  
  #En el ejemplo anterior, medir el efecto del programa fue sencillo, dado que
  #era un diseño nítido y el programa tuvo aceptación perfecta (perfect compliance).
  #En la siguiente base, tenemos el mismo programa, pero en un contexto donde
  #no hubo aceptación perfecta (hubo controles que tomaron el programa y tratados
                                 #que no lo tomaron).
  
  tutoring <- read_csv("data/tutoring_program_fuzzy.csv")
  
  #En la siguiente gráfica y tabla podemos ver cómo personas con score menor
  #que 70 reportan no haber recibido tutorías y personas con score mayor a 70
  #reportan sí haber recibido tutorías.
  
  ggplot(tutoring, aes(x = entrance_exam, y = tutoring_text, color = entrance_exam <= 70)) +
    geom_point(size = 1.5, alpha = 0.5, 
               position = position_jitter(width = 0, height = 0.25, seed = 1234)) + 
    geom_vline(xintercept = 70) + 
    labs(x = "Entrance exam score", y = "Participated in tutoring program") + 
    guides(color = FALSE)
  
  tutoring %>% 
    group_by(tutoring, entrance_exam <= 70) %>% 
    summarize(count = n()) %>% 
    group_by(tutoring) %>% 
    mutate(prop = count / sum(count))
  

# Paso 9: Revisar discontinuidad en la variable de resultados, sobre la variable continua. ----
  
  #Hacemos una visualización de las calificaciones del examen final, sobre las
  #calificaciones del examen inicial, por la variable de tratamiento. 
  
  ggplot(tutoring, aes(x = entrance_exam, y = exit_exam, color = tutoring)) +
    geom_point(size = 1, alpha = 0.5) + 
    geom_smooth(data = filter(tutoring, entrance_exam <= 70), method = "lm") +
    geom_smooth(data = filter(tutoring, entrance_exam > 70), method = "lm") +
    geom_vline(xintercept = 70) +
    labs(x = "Entrance exam score", y = "Exit exam score", color = "Used tutoring")
  
  #La línea verde representa los valores ajustados para las personas que
  #EFECTIVAMENTE NO recibieron tutorías, mientras la línea roja representa los
  #valores ajustados para los que EFECTIVAMENTE SÍ recibieron tutorías.
  
  #Aun hay una discontinuidad visible en el 70, pero hay personas que reciberon
  #y que no recibieron tutorías en ambos lados del threshold. 
  
  tutoring_with_bins <- tutoring %>% 
    mutate(exam_binned = cut(entrance_exam, breaks = seq(0, 100, 5))) %>% 
    group_by(exam_binned, tutoring) %>% 
    summarize(n = n()) %>% 
    pivot_wider(names_from = "tutoring", values_from = "n", values_fill = 0) %>% 
    rename(tutor_yes = `TRUE`, tutor_no = `FALSE`) %>% 
    mutate(prob_tutoring = tutor_yes / (tutor_yes + tutor_no))
  
  ggplot(tutoring_with_bins, aes(x = exam_binned, y = prob_tutoring)) +
    geom_col() +
    geom_vline(xintercept = 8.5) +
    labs(x = "Entrance exam score", y = "Proportion of people participating in program")
  
# Paso 10: Medir la discontinuidad borrosa ----
  
  #En este caso, es posible utilizar un Método de Variables Instrumentales
  #para medir el ITT del programa. Creamos una variable que indique si el
  #individuo es "elegible" o "digno de tratar". Nuestro instrumento es válido
  #dado que se cumplen las siguientes tres condiciones:
    
  #Relevancia: El threshold garantiza acceso al programa (Z afecta a X)
  
  #Exclusión: El threshold tiene un efecto sobre las calificaciones del examen
  #			final, sólo a través del acceso al programa de tutorías (Corr(Z,Y|X)=0)
  
  #Exogeneidad: Los factores no observables entre el programa de tutorías y
  #			  las calificaciones finales no están relacionadas con el threshold.
  
  tutoring_centered <- tutoring %>% 
    mutate(entrance_centered = entrance_exam - 70,
           below_cutoff = entrance_exam <= 70)
  tutoring_centered
  
  model_sans_instrument <- lm(exit_exam ~ entrance_centered + tutoring,
                              data = filter(tutoring_centered,
                                            entrance_centered >= -10 & 
                                              entrance_centered <= 10))
  tidy(model_sans_instrument)
  
  #Obtendríamos un efecto de 11.36 puntos en la calificación del examen final
  #atribuible al programa de tutorías. Sin embargo, este estimador es incorrecto.
  
  #Lo que haremos es correr un modelo 2SLS, dentro de un rango de -10,+10
  #respecto al threshold de 70, donde estimemos las siguientes ecuaciones: 
  
  model_fuzzy <- iv_robust(
    exit_exam ~ entrance_centered + tutoring | entrance_centered + below_cutoff,
    data = filter(tutoring_centered, entrance_centered >= -10 & entrance_centered <= 10)
  )
  tidy(model_fuzzy)
  
  #Al obtener nuestro estimador de variables instrumentales, obtenemos un efecto
  #atribuible al programa de 9.74 puntos en la calificación del examen final, 
  #para los compliers dentro del rango cercano al threshold de 70.