/*******************************************************************************
		- Autor: Manuel Cardona
		- Propósito: Modelo de diferencias de campaña SMS 2018
		- Datos: Datos SBS Peru
		- Windows
		- Stata 15.1 (Octubre-2020)
*******************************************************************************/


/* 		Este do file elabora diversos análisis sobre el efcto de los SMS
		en distintas variables de resultados, utilizando un modelo de
		diferencias.			*/    	

set more off

*Globals: Estas rutas deberán ser modificadas, respecto al usuario.
 *Ej: global working "C:\Usuarios\Nombre\Dropbox\...\...\..."
 
global data "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\04_RCT\Data"
global dofile "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\04_RCT\Do file"

		*************************************************
		*********Variables sobre portal SBS**************
		*************************************************
		
		use "$data/ua_sms_201807_201903.dta", clear
		
			*Variables de tratamiento*
			
			//El experimento tiene en cuenta dos tipos de variables de tratamiento:
				//1. Dicotómica: Toma el valor de 1, si el individuo recibió mensajes
				//de texto con información sobre su situación crediticia, sin importar
				// el contenido del mensaje.
				tab treatment, mis
				//2. Categórica: Puede tomar 15 valores distintos. Cada valor indica un
				//tipo de mensaje distinto, basado en una teoría de sesgos conductuales.
				//Esta variable se encuentra también desglosada en 15 variables dicotómicas
				//(una por cada brazo de tratamiento).
				tab treat_arms, mis
				
			*Variables de resultados*
			
			//La base de datos contiene tres tipos de variables dependientes:	
				//1. El individuo entró al portal SBS.
				tab after_interv_SMS_201809, mis
				tab after_interv_SMS_201810, mis
				tab after_interv_SMS_201811, mis
				tab after_interv_SMS_201812, mis

				//2. El número de veces que el individuo entró al portal SBS. 
				tab dup_aplicativo_201809, mis
				tab dup_aplicativo_201810, mis
				tab dup_aplicativo_201811, mis
				tab dup_aplicativo_201812, mis

				//3. El individuo NUNCA entró al portal SBS.
				tab neverLogin, mis
			
			//Las primeras dos variables se recolectaron con una periodicidad mensual, 
			//de septiembre a diciembre de 2018, mientras que la tercera variable
			//cubre todo el periodo de análisis. 
			
			*Variables de control*
			
			//La base de datos contiene variables de control que fueron utilizadas
			//para estratificar la aleatorización del tratamiento; es decir, para
			//asegurar validez interna en cada uno de los estratos de sexo, terciles
			//de edad, número de veces que el individuo mostró interés de entrar al 
			//portal hasta Marzo de 2018). 
			tab sexo, mis
			tab edad3, mis
			tab dup_aplicativo, mis
			
			
		***************************************
		*********Prueba de medias**************
		***************************************
		
		ttest after_interv_SMS_201809, by(treatment)
			//Una prueba de medias (ttest) nos permite saber si existe una diferencia
			//estadísticamente significativa entre Tratados y Controles, ceteris paribus.
			
			//La tabla arroja:
				//Para Controles y Tratados:
				//1. Número de observaciones por grupo.
				//2. Media de la variable de resultados por grupo.
				//3. Error estándar y desviación estándar de la media de la 
				//   variable de resultados por grupo.
				//4. Intervalos de confianza al 95%, para la media por grupo.
				
				//En conjunto:
				//1. Número de observaciones.
				//2. Media de la variable de resultados.
				//3. Error estándar y desviación estándar de la media de la 
				//   variable de resultados.
				//4. Intervalos de confianza al 95%, para la media.
				
				//Sobre la diferencia:
				//1. Media de la diferencia entre Controles y Tratados.
				//2. Error estándar de la media de la diferencia entre Controles y Tratados.
				//3. Intervalos de confianza al 95%.
				
				//En este caso la hipótesis nula a probar es 
					// mean(Control)-mean(Treatment)==0
					
				//La hipótesis alternativa que se encuentra en el centro es:
					//mean(Control)-mean(Treatment)!=0
				//Dado que el valor absoluto del estadístico t es 2.1905 y, por tanto, 
				//mayor que 1.96, pero menor que 2.32, es posible rechazar la Ho de que
				//no existe una diferencia entre tratados y controles al 95% de confianza.
				
				//Dado que de las dos Ha restantes, la que es significativa es:
					//mean(Control)-mean(Treatment)<0
				//Es posible afirmar que el valor de la diferencia es negativo y que, 
				//por tanto, el grupo de control tiene un valor promedio menor que el 
				//grupo de tratamiento.
				
				//Es decir, los individuos del grupo de control entran al portal,
				//en promedio, menos veces que los individuos del grupo de tratamiento.
				
		ttest dup_aplicativo_201809, by(treatment)
				//No existe una diferencia significativa en el número de veces que
				//acceden al portal entre tratados y controles.
				
		ttest neverLogin, by(treatment)
				//En promedio, los individuos del grupo de control son más probables
				//a nunca acceder al portal que los individuos que recibieron el 
				//mensaje de texto.
		
		***************************************
		*********Regresión lineal**************
		***************************************	
		
			//La misma prueba puede realizaerse empleando un modelo de regresión
			//lineal simple. 
			
		reg after_interv_SMS_201809 treatment
			//Como es posible observar, el estimador del impacto del tratamiento
			//es significativo, positivo y con valor de B==0.0030135. Este valor 
			//es idéntico al que obtuvimos en la diferencia de medias del primer
			//t-test que calculamos. 
			
		reg dup_aplicativo_201809 treatment
				//No existe una diferencia significativa en el número de veces que
				//acceden al portal entre tratados y controles.
				
		reg neverLogin treatment
				//La probabilidad de que un individuo del grupo de tratamiento 
				//NUNCA acceda al portal es 0.0169 puntos porcentuales menor, en 
				//comparación con un individuo del grupo de control (significativo
				//al 99.9999% de confianza).
				
				
			//Si queremos saber si existe un efecto sobre las variables de resultados
			//pero por el tipo de mensaje que recibieron, podemos elaborar una regresión
			//lineal utilizando los diferentes brazos de tratamiento.
			
		reg after_interv_SMS_201809 t1-t15
			//Dado que la categoría que está excluida en la regrsión es el grupo de
			//control, todos los coeficientes deberán ser interpretados como efectos
			//marginales respecto al grupo de control.
			
			//Por ejemplo, el los individuos que recibieron T1 tienen una probabilidad
			//de 0.006 puntos porcentuales mayor de acceder al portal, respecto al grupo de
			//control (significativo al 90% de confianza, t==1.68).
			
		reg after_interv_SMS_201809 i.treat_arms
			//También podemos emplear el operador de efectos fijos, usando la variable
			//categórica y obtendríamos los mismos resultados. 
			

		******************************************************************
		*********Regresión lineal con regresores adicionales**************
		******************************************************************
		
			//Es probable que necesitemos utilizar regresores adicionales (variables
			//de control), para mejorar la eficiencia de nuestros B o para asegurarnos
			//de obtener estimadores insesgados. 
			
			//Si corremos, de nuevo, el modelo simple:
					reg after_interv_SMS_201809 treatment
			//Si lo corremos con variables de control:
					reg after_interv_SMS_201809 treatment sexo edad3 dup_aplicativo

			//El efecto del tratamiento sigue siendo significativo, pero esta vez
			//al 90% de confianza (antes al 95%). Otra diferecia a reslatar, es que el
			//estimador de la segunda regresión presenta una menor varinza (mayor
			//eficiencia).
