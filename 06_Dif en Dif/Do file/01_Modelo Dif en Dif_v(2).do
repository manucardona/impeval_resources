/*******************************************************************************
		- Autor: Manuel Cardona
		- Propósito: Modelo de diferencias en diferencias de campaña SMS 2018
		- Datos: Datos SBS Peru
		- Windows
		- Stata 15.1 (Noviembre-2020)
*******************************************************************************/


/* 		Este do file elabora diversos análisis sobre el efcto de los SMS
		en distintas variables de resultados, utilizando un modelo de
		diferencias en diferencias.			*/    	

set more off

*Globals: Estas rutas deberán ser modificadas, respecto al usuario.
 *Ej: global working "C:\Usuarios\Nombre\Dropbox\...\...\..."
 
global data "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\06_Dif en Dif\Data"
global dofile "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\06_Dif en Dif\Do file"

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
			
			//La base de datos contiene tres tipos de variables dependientes (dos de ellas
			//para múltiples periodos):	
				//1. El individuo entró al portal SBS.
				tab accessed_bline, mis //Antes del tratamiento
				tab after_interv_SMS_201810, mis //1 mes después del tratamiento
				tab after_interv_SMS_201811, mis //2 meses después del tratamiento
				tab after_interv_SMS_201812, mis //3 meses después del tratamiento

				//2. El número de veces que el individuo entró al portal SBS. 
				tab dup_aplicativo_bline, mis //Antes del tratamiento
				tab dup_aplicativo_201810, mis //1 mes después del tratamiento
				tab dup_aplicativo_201811, mis //2 meses después del tratamiento
				tab dup_aplicativo_201812, mis //3 meses después del tratamiento

				//3. El individuo NUNCA entró al portal SBS.
				tab neverLogin, mis
				
			//La base de datos contiene variables de control que fueron utilizadas
			//para estratificar la aleatorización del tratamiento; es decir, para
			//asegurar validez interna en cada uno de los estratos de sexo, terciles
			//de edad, número de veces que el individuo mostró interés de entrar al 
			//portal hasta Marzo de 2018). 
			tab sexo, mis
			tab edad3, mis
			tab dup_aplicativo, mis
			
***************************************
*********Modelo Dif en Dif*************
***************************************

ttest accessed_bline, by(treatment)
*La Ho=en ambos periodos son iguales*
*No se rechaza la hipótesis nula, la variable de resultados era igual en ambos grupos*
*A pesar de que existe aleatoriedad perfecta, puede haber diferencia en las variables de resultados
*y el modelo puede ser evaluado con diversas metodologías.


*** Modelo Dif en Dif simple (manualmente) ***

*Necesitamos cuatro medias:
	*A. Tratados en línea base
	mean accessed_bline if treatment==1
	
	*B. Controles en línea base
	mean accessed_bline if treatment==0
	
	*C. Tratados en seguimiento
	mean after_interv_SMS_201810 if treatment==1
	
	*D. Controles en seguimiento
	mean after_interv_SMS_201810 if treatment==0

*El estimador del modelo simple estará determinado por:
 *T(did)=(C-D)-(A-B)

 mata
 (.0388521 - .0301963) - (.026706 - .0236925)
 end
 
*** Modelo Dif en Dif simple (MCO) ***
gen delta_access=after_interv_SMS_201810-accessed_bline

reg delta_access treatment
*El coeficiente es el mismo*

*** Modelo Dif en Dif con regresores adicionales (MCO) ***
reg delta_access treatment sexo edad3 dup_aplicativo

*COMPARACIÓN CON EL MODELO DE DIFERENCIAS*
reg delta_access treatment sexo edad3 dup_aplicativo //Modelo Dif en Dif

reg after_interv_SMS_201810 treatment sexo edad3 dup_aplicativo //Modelo de diferencias
 *Si hacemos el modelo de diferencias, el efecto estaría sobre estimado, ///
 /// dado que, probablemente, no tenía en cuanta diferencias pre existentes*
 
 
*** Modelo Dif en Dif con datos de corte transversal repetido ***

*Para evaluae un programa con un estimador Diff in Diff con datos de corte transversal
*repetido es necesario tener la misma base de datos en dos periodos de tiempo, para
*controles y tratados. Para ello, partiremos nuestra base de datos en dos grupos aleatorios
*para poder asumir que provenían de una submuestra distinta.

set seed 82015008 //La semilla especifica el valor inicial de una secuencia de números
				 //aleatorios provenientes de una distribución como runiform() o rnormal().
				 //Para hacer esto más aleatorio, podemos utilizar semillas provenientes de sitios
				 //como www.random.org

gen rand = runiform() //Creamos una secuencia de números aleatorios provenientes de una
					  //distribución uniforme.
					  
sort treatment treat_arms, stable //Ordenamos las observaciones
														 
bysort  treatment treat_arms  (rand): gen periodo = cond( _n > .5*_N , 1 , 0 ) 

label def per 1 "Seguimiento" 0 "Base"
label values periodo per

			
save "$data/corte_transversal.dta", replace

*Imaginemos, entonces, que tenemos dos muestras de nuestra intervención de dos
*periodos distintos. 
tab periodo treatment
	//El periodo 0 representa un levantamiento en la línea base, mientras que el 
	//periodo 1 representa un periodo en la línea de seguimiento. Los individuos 
	//incluidos en cada periodo no son necesariamente los mismos; de hecho, es muy
	//poco probable que sean los mismos. 
	
	//En el periodo 0, hay 12,915 individuos del grupo de control y 13,047 del grupo de tratamiento.
	//En el periodo 1, hay 12,916 individuos del grupo de control y 13,052 del grupo de tratamiento. 
	
*Si queremos conocer el impacto del programa utilizando dos periodos distintos,
*necesitamos emplear la siguiente regresión:

*Y_i = b_0 + b_1*D_i + B_2*I[t=1] + B_3D_i*I[t=1] + u_i

*Donde:
	//Y_i es la variable de resultados del individuo i
	gen accessed=.
	replace accessed=accessed_bline if periodo==0
	replace accessed=after_interv_SMS_201810 if periodo==1
	
	//D_i es el indicador de tratamiento del individuo i
	tab treatment
	
	//I[t=1] es el indicador de que el individuo pertenece al periodo 1.
	fre periodo
	
	gen interaccion=treatment*periodo
	tab interaccion
	
reg accessed treatment periodo interaccion
	
	
	
	//En este caso, el estimador del impacto del programa estará determinado por
	//el coeficiente que acompaña a la interacción. Es decir, los individuos que
	//recibieron el tratamiento tienen una probabilidad .6 puntos porcentuales mayor
	//que los individuos que no recibieron el tratamiento, medidos en la línea de
	//seguimiento.







