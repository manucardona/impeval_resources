#******************************************************************************# 
# Modelo de diferencias de la campaña SMS 2018                                 #
# Datos: Datos SBS Peru                                                        #
#                                                                              # 
# Autor: - Manuel Cardona Arias <mcardona@poverty-action.org>                  # 
#******************************************************************************# 

# Este do file elabora diversos análisis sobre el efcto de los SMS
# en distintas variables de resultados, utilizando un modelo de
# diferencias.

library(tidyverse)
library(dplyr)
library(ggplot2)
library(foreign)

setwd("~/../Dropbox/CIDE/Lab Evaluación PP 2020/04_RCT/")

# *****************************************************************************
#### 01 Variables sobre el portal SBS ####
# *****************************************************************************

data_sbs <- read.dta("Data/ua_sms_201807_201903_ver12.dta")

# Variables de tratamiento*
  
  # El experimento tiene en cuenta dos tipos de variables de tratamiento:

  # 1. Dicotómica: Toma el valor de 1, si el individuo recibió mensajes
  # de texto con información sobre su situación crediticia, sin importar
  # el contenido del mensaje.
  table(data_sbs$treatment)
  
  # 2. Categórica: Puede tomar 15 valores distintos. Cada valor indica un
  # tipo de mensaje distinto, basado en una teoría de sesgos conductuales.
  # Esta variable se encuentra también desglosada en 15 variables dicotómicas
  # (una por cada brazo de tratamiento).
  table(data_sbs$treat_arms)

# Variables de resultados
    
    # La base de datos contiene tres tipos de variables dependientes:	
  
    # 1. El individuo entró al portal SBS.
    table(data_sbs$after_interv_SMS_201809) 
    table(data_sbs$after_interv_SMS_201810) 
    table(data_sbs$after_interv_SMS_201811) 
    table(data_sbs$after_interv_SMS_201812) 
    
  
     # 2. El número de veces que el individuo entró al portal SBS. 
     summary(data_sbs$dup_aplicativo_201809)
     summary(data_sbs$dup_aplicativo_201810)
     summary(data_sbs$dup_aplicativo_201811)
     summary(data_sbs$dup_aplicativo_201812)
     
     # 3. El individuo NUNCA entró al portal SBS.
     table(data_sbs$neverLogin)
     
     # Las primeras dos variables se recolectaron con una periodicidad mensual, 
     # de septiembre a diciembre de 2018, mientras que la tercera variable
     # cubre todo el periodo de análisis. 
     
# Variables de control
       
     # La base de datos contiene variables de control que fueron utilizadas
     # para estratificar la aleatorización del tratamiento; es decir, para
     # asegurar validez interna en cada uno de los estratos de sexo, terciles
     # de edad, número de veces que el individuo mostró interés de entrar al 
     # portal hasta Marzo de 2018).
     
     table(data_sbs$sexo)
     table(data_sbs$edad3)
     table(data_sbs$dup_aplicativo)
     
# *****************************************************************************
#### 02 Prueba de medias ####
# *****************************************************************************
     t.test(after_interv_SMS_201809 ~ treatment, data = data_sbs)
     