#******************************************************************************# 
# Modelo de emparejamiento                                                     #
# Datos: Nets data                                               #
#                                                                              # 
# Autor: - Manuel Cardona Arias <mcardona@poverty-action.org>                  # 
#******************************************************************************# 

rm(list = ls())
setwd("~/../Dropbox/CIDE/Lab Evaluación PP 2020/07_Matching/")

library(tidyverse)  # ggplot(), %>%, mutate(), and friends
library(ggdag)  # Make DAGs
library(dagitty)  # Do DAG logic with R
library(broom)  # Convert models to data frames
library(MatchIt)  # Match things
library(modelsummary)  # Make side-by-side regression tables

set.seed(1234)   # Make all random draws reproducible

#///////////////////////////////#
### Descripción del programa ####
#///////////////////////////////#

#Los velos para prevenir las picaduras de los mosquitos son una intervención muy
#popular para evitar la propagación de la malaria en distintos países africanos.
#En esta evaluación, pretendemos conocer el potencial efecto de los velos en una
#reducción del riesgo de contraer malaria. 

#Tenemos datos de 1,752 hogares sobre la entrega de los velos, así como algunas
#otras variables relacionadas al ambiente, a la salud de los individuos y a las 
#características del hogar.  

#Los datos NO SON EXPERIMENTALES. Los hogares tuvieron la decisión de pedir los
#velos de manera gratuita, de comprarlos y de usarlos, una vez adquiridos.

# Cargar datos ----
nets <- read_csv("data/mosquito_nets.csv")

# Variable de resultado ----
  #malaria_risk: La probabilidad de que alguien en el hogar contraiga malaria.
    summary(nets$malaria_risk)

# Covariables ----
  #net_num: Una variable dicotómica que indica si el hogar usó velo.
    table(nets$net_num)

  #eligible: Una variable dicotómica que indica si el hogar es elegible para
  #			recibir velo.
    table(nets$eligible)
  
  #income: Ingreso mensual del hogar en dólares US.
    summary(nets$income)

  #temperature: La temperatura de noche del lugar donde se encuentra el hogar,
  #				medida en grados C.
    table(nets$temperature)
    
  #health: Estado de salud autorreportado por el jefe del hogar. Medido en una
  #		  escala del 0 al 100, donde mayores valores indican mejor salud.
    summary(nets$health)

  #household: Número de miembros en el hogar.
    table(nets$household)

  #resistance: Resistencia a insecticidas de la cepa de mosquito predominante
  #			  en la zona donde se encuentra el hogar. Medido en una escala del
  #			  0 al 100, donde mayores valores indican mayor resistencia.
    summary(nets$resistance)
    
#El objetivo es utilizar un algortimo de emparejamiento que nos permita encontrar
#clones que podamos comparar para encontrar el efecto del uso de los velos en el
#riesgo de contraer malaria en el hogar.
    
    
    #///////////////////////////////#
    ### Método de emparejamiento ####
    #///////////////////////////////#
    
# Paso 1: Procesamiento previo
    
    matched_data <- matchit(net ~ income + temperature + health,
                            data = nets,
                            method = "nearest",
                            distance = "mahalanobis",
                            replace = TRUE)
    summary(matched_data)
    
  #Podemos observar que todos los usuarios de redes fueron emparejados con clones
  #del grupo de no usuarios (439 de ellos). 632 individuos no fueron emparejados y
  #serán descartados del anlisis.
    
    matched_data_for_real <- match.data(matched_data)
    
  #Con el comando anterior, nos quedamos con una nueva base de datos que contempla
  #sólo a los emparejados.
    
# Paso 2: Estimación ----
    
    model_matched <- lm(malaria_risk ~ net, 
                        data = matched_data_for_real)
    tidy(model_matched)
    
    