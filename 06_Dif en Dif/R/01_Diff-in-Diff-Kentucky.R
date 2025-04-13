#******************************************************************************# 
# Modelo de diferencias en diferencias                                         #
# Datos: Kentucky Injuries Law                                                 #
#                                                                              # 
# Autor: - Manuel Cardona Arias <mcardona@poverty-action.org>                  # 
#******************************************************************************# 

rm(list = ls())

library(tidyverse)  # ggplot(), %>%, mutate(), and friends
library(broom)  # Convert models to data frames
library(scales)  # Format numbers with functions like comma(), percent(), and dollar()
library(modelsummary)  # Create side-by-side regression tables

#///////////////////////////////#
### Descripción del programa ####
#///////////////////////////////#

#En 1980, el estado de Kentucky aumentó el límite superior en las ganancias semanales
#que estaban cubiertas por la compensación al trabajador; es decir, por los beneficios
#recibidos luego de un accidente en el trabajo. El objetivo de la evaluación es 
#saber si esta política provocó que los trabajadores pasaran más tiempo sin trabajar.

#Si los beneficios no son lo suficientemente generosos, los trabajadores podrían
#demandar a las empresas por lesiones en el trabajo, mientras que, si las compensaciones
#eran demasiado generosas, los beneficios podrían causar un problema de moral hazard e
#inducir a los trabajadores a ser más imprudentes en el trabajo o a afirmar que las lesiones
#que ocurrieron fuera del trabajo ocurrieron dentro del lugar de trabajo.

# Cargar datos ----
injury_raw <- read_csv("../Data/injury.csv")


# Variable de resultado ----
  #La variable de resultados es el logaritmo de la duración del tiempo (en semanas)
  #que el empleado estuvo recibiendo los beneficios de compensación.
    summary(injury_raw$ldurat)

#Variable de tratamiento:
  #La política estaba diseñada de tal manera que el incremento en la compensación
  #no afectara a los "low-earning workers", pero sí a los "high-earning workers". Por
  #ello, utilizaremos a los "low-earning workers" como grupo de control y a los
  ##"high-earning workers" como grupo de tratamiento.

#Indicador de tiempo:
  #La variable after_1980 toma el valor de 0 para aquellas observaciones que sucedieron
  #antes de 1980 y de 1 para aquellas que sucedieron después. 

#Limpieza de datos ----
  
injury <- injury_raw %>% 
  #Nos quedamos con observaciones sólo de Kentucky:
  filter(ky == 1) %>% 
  #Renombramos algunas variables:
  rename(duration = durat, log_duration = ldurat,
         after_1980 = afchnge)


#////////////////////////////#
### Análisis exploratorio ####
#////////////////////////////#

ggplot(data = injury, aes(x = duration)) +
  geom_histogram(binwidth = 8, color = "white", boundary = 0) +
  facet_wrap(vars(highearn))
    #Podemos ver que la distribución, en ambos grupos, está muy sesgada. La mayoría
    #en ambos grupos, se encuentra entre 0 y 8 semanas de duración; y algunos como más de
    #180 semanas (3.5 años!!!).

ggplot(data = injury, mapping = aes(x = log_duration)) +
geom_histogram(binwidth = 0.5, color = "white", boundary = 0) + 
facet_wrap(vars(highearn))
    #Si utilizamos una transformación logarítmica, veremos que la distribución ya no
    #está tan sesgada.

ggplot(data = injury, mapping = aes(x = log_duration)) +
  geom_histogram(binwidth = 0.5, color = "white", boundary = 0) + 
  facet_wrap(vars(after_1980))
    #También debemos analizar nuestra distribución de la variable de resultados en el
    #indicadore del tiempo. Si bien es cierto que se ven, aproximadamente, "normales",
    #no podemos apreciar diferencias entre los periodos antes y después de la política.
    #Para ello, utilizaremos una evaluación con un modelo Diff in Diff. 


#///////////////////////////////#
### Diff-in-diff manualmente ####
#///////////////////////////////#

#Necesitamos cuatro medias:
  #A. High-earn antes de 1980
  #B. Low-earn antes de 1980
  #C. High-earn después de 1980
  #D. Low-earn después de 1980

#El estimador del modelo simple estará determinado por:
  #T(did)=(C-D)-(A-B)

diffs <- injury %>% 
  group_by(after_1980, highearn) %>% 
  summarize(mean_duration = mean(log_duration),
            # Calculate average with regular duration too, just for fun
            mean_duration_for_humans = mean(duration))
diffs

#Otro método:
before_treatment <- diffs %>% 
  filter(after_1980 == 0, highearn == 1) %>% 
  pull(mean_duration)

before_control <- diffs %>% 
  filter(after_1980 == 0, highearn == 0) %>% 
  pull(mean_duration)

after_treatment <- diffs %>% 
  filter(after_1980 == 1, highearn == 1) %>% 
  pull(mean_duration)

after_control <- diffs %>% 
  filter(after_1980 == 1, highearn == 0) %>% 
  pull(mean_duration)

diff_treatment_before_after <- after_treatment - before_treatment
diff_treatment_before_after

diff_control_before_after <- after_control - before_control
diff_control_before_after

diff_diff <- diff_treatment_before_after - diff_control_before_after
diff_diff

  #El estimador diff-in-diff es de 0.1906, lo cual indica que el programa causó
  #un incremento del "reposo" de 0.19 semanas log. 

  #En otras palabras, la política causa un incremento del 19% en la duración de
  #los periodos de reposo de los trabajadores.

ggplot(diffs, aes(x = as.factor(after_1980), 
                  y = mean_duration, 
                  color = as.factor(highearn))) + 
  geom_point() +
  geom_line(aes(group = as.factor(highearn))) +
  annotate(geom = "segment", x = "0", xend = "1",
           y = before_treatment, yend = after_treatment - diff_diff,
           linetype = "dashed", color = "grey50") +
  annotate(geom = "segment", x = "1", xend = "1",
           y = after_treatment, yend = after_treatment - diff_diff,
           linetype = "dotted", color = "blue") +
  annotate(geom = "label", x = "1", y = after_treatment - (diff_diff / 2), 
           label = "Program effect", size = 3)

#///////////////////////////#
### Diff-in-diff con OLS ####
#///////////////////////////#

#El mismo estimador se puede obtener, utilizando un modelo de regresión lineal:
  
model_small <- lm(log_duration ~ highearn + after_1980 + highearn * after_1980,
                  data = injury)
tidy(model_small)

#El estimador del impacto de la política es idéntico al que obtuvimos a mano, 
#sólo que ahora podemos saber que el coeficiente es estadísticamente distinto
#de 0, a un 99% de confianza.


#/////////////////////////////////#
### Diff-in-diff con controles ####
#/////////////////////////////////#

#Ahora, utilizaremos controles adicionales, para ayudar a aislar el efecto de la política
#sobre la duración del reposo de los trabajadores y para mejorar la eficiencia del estimador.

#Por ejemplo, puede ser que las peticiones de reposo de los trabajadores de un tipo de 
#industria tiendan a ser más largas que las de otro tipo de industria. Puede ser que las
#peticiones por lesiones en la espalda sean más largas que por lesiones en la cabeza.

injury_fixed <- injury %>% 
  mutate(indust = as.factor(indust),
         injtype = as.factor(injtype))

model_big <- lm(log_duration ~ highearn + after_1980 + highearn * after_1980 + 
                  male + married + age + hosp + indust + injtype + lprewage,
                data = injury_fixed)
summary(model_big)

#Es importante tratar las variables indust y injtype como variables categóricas y no como
#variables continuas.
