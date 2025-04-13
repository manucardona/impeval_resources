/*******************************************************************************
		- Autor: Manuel Cardona
		- Propósito: Modelo de variables instrumentales
		- Datos: El efecto de un año extra de educación en los salarios
		- Windows
		- Stata 15.1 (Noviembre-2020)
*******************************************************************************/   	

set more off

*Globals: Estas rutas deberán ser modificadas, respecto al usuario.
 *Ej: global working "C:\Usuarios\Nombre\Dropbox\...\...\..."
 
global data "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\09_Instrumental Variables\Data"
global dofile "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\09_Instrumental Variables\Do file"

		*************************************************
		**********Descripción del evento*****************
		*************************************************
		
*Esta vez, no vamos a evaluar un programa! Vamos a analizar el efcto de un año
*extra de educación en el salario. 

 import delimited "$data\father_education.csv", clear	
 
 *La base de datos contiene las siguientes variables:
	//wage: Salario semanal del individuo.
	sum wage, det
	
	//educ: Años de educación del individuo.
	sum educ, det
	
	//ability: Una variable mágica que mide la habilidad innata que tiene el 
	//		   individuo, tanto para trabajar como para estudiar (esta será la
	//		   variable omitida!!!).
	sum ability, det
	
	//fatheredcuc: Años de educación del padre del individuo.
	sum fathereduc, det
	
*Paso 1: El problema de endogeneidad

*Sin pensar mucho, podríamos pensar que los salarios son una función de la educación
*y la habilidad innata; por tanto, estimaríamos el modelo de la siguiente manera:
	reg wage educ ability
	
*Sin embargo, nosotros no podemos conocer "ability" en la vida real y estimaríamos:
	reg wage educ
	
*En el segundo modelo, el efecto de la educación en los salarios estaría sobreestimado,
*dado que la variable de educación tiene un problema de endogeneidad (hay cosas, como
*la habilidad) incluidas en el término de error que están correlacionadas con ella.



*Paso 2: Identificar el instrumento

*Para resolver el problema de endogeneidad, entonces, necesitamos un instrumento. 
*En este caso, usaremos la educación del padre como instrumento de la educación
*del individuo.

*Para ser un instrumento adecuado, necesitamos que se cumplan las siguientes condiciones:
	//Relevancia: La educación del padre esté correlacionada con la educación del hijo.
	twoway (scatter educ fathereduc, mcolor(*.6)) (lfit educ fathereduc)
	corr educ fathereduc
	reg educ fathereduc
	
	
	//Exclusión: La educación del padre está correlacionada con el salario del individuo,
	//			 solo a través de la educación del individuo.
	twoway (scatter wage fathereduc, mcolor(*.6)) (lfit wage fathereduc)
	reg wage fathereduc
		//Podemos observar una relación entre el salario del hijo y la educación
		//del padre. Esto es de esperarse, pero tenemos que encontrar una razón
		//teórica, para aseverar que el único canal a través del cual la educación
		//del padre afecta el salario del hijo es la educación del hijo.
	
	
	//Exogeneidad: La educación del padre no está correlacionada con algo más del modelo.
		//En realidad, no existe un test perfecto para conocer si existe exogeneidad
		//en el instrumento.  Dado que nosotros tenemos una columna mágica llamada 
		//"ability" sí podemos probarlo.
	twoway (scatter fathereduc ability, mcolor(*.6)) (lfit fathereduc ability)
		//En este caso, las variables no están correlacionadas, lo cual significa
		//que se cumple el supuesto. 
		
		
*Paso 3: Modelo 2SLS "manualmente"

*El primer paso es predecir la primera etapa del modelo. En este caso, el efecto¨
*de la educación del padre en la educación del hijo.
	reg educ fathereduc
		
*Calculamos los valores ajustados:
	predict double educ_adjusted
	
*El segundo paso es predecir la variable de resultados, usando los valores predichos
*por el instrumento.
	reg wage educ_adjusted
		//En este caso, el estimador del efecto de la educación en el salario es 
		//un poco más acertado, dado que corregimos el sesgo generado por las variables
		//no observables. De hecho, el estimador es muy parecido al que habíamos
		//obtenido en el modelo que incluye la variable "ability".
		
*Paso 4: Modelo IV en un solo paso!

*El comando ivregress nos permite hacer la estimación en dos etapas en un solo paso.
	ivregress 2sls wage (educ = fathereduc)
		//Los resultados de ambos modelos son idénticos.
		
*Paso 5: Utilizar múltiples instrumentos

*En este caso, la pregunta de investigación sigue siendo la misma, solo que ahora 
*no tenemos datos falsos (Ooops!). 

import delimited "$data/wage2.csv", clear

*La base de datos contiene las siguientes variables que son de nuestro interés:
	keep wage educ feduc meduc
	
	*Borramos algunos missing values:
		drop if feduc=="NA"
		drop if meduc=="NA"
	*Hacemos numéricas las variables:
		destring feduc, replace
		destring meduc, replace
		
	//wage: Salario mensual del individuo en dólares de 1980
	sum wage, det
	
	//educ: Años de educación del individuo
	sum educ, det
	
	//feduc: Años de educación del padre del individuo
	sum feduc, det
	
	//meduc: Años de educación de la madre del individuo
	sum meduc, det
	
*Paso 6: Estimar el modelo con problemas de endogeneidad
	reg wage educ 
		//Este modelo tiene un problema de endogeneidad, dado que ambas variables
		//son función de elementos en el término de error, como la habilidad innata
		//en el modelo pasado.
		
*Paso 7: Identificación de los instrumentos
*Para ser un instrumento adecuado, necesitamos que se cumplan las siguientes condiciones:
	//Relevancia: La educación del padre esté correlacionada con la educación del hijo.
		*Educación del padre:
		twoway (scatter educ feduc, mcolor(*.6)) (lfit educ feduc)
		corr educ feduc
		reg educ feduc
		
		*Educación de la madre:
		twoway (scatter educ meduc, mcolor(*.6)) (lfit educ meduc)
		corr educ meduc
		reg educ meduc
	
	
	//Exclusión: La educación del padre/madre está correlacionada con el salario del individuo,
	//			 solo a través de la educación del individuo.
	twoway (scatter wage feduc, mcolor(*.6)) (lfit wage feduc)
		//Podemos observar una relación entre el salario del hijo y la educación
		//del padre. Esto es de esperarse, pero tenemos que encontrar una razón
		//teórica, para aseverar que el único canal a través del cual la educación
		//del padre afecta el salario del hijo es la educación del hijo.
	twoway (scatter wage meduc, mcolor(*.6)) (lfit wage meduc)
	
*Paso 8: Estimar el modelo IV
*El comando ivregress nos permite hacer la estimación en dos etapas en un solo paso.
	ivregress 2sls wage (educ = feduc)
	ivregress 2sls wage (educ = meduc)
	ivregress 2sls wage (educ = feduc meduc)


*Paso 9: Añadir regresores adicionales
*En este último ejemplo, analizaremos el efecto de la educación en los salario,
*utilizando la proximidad geográfica a una universidad como instrumento. Estos 
*datos también son reales:

	import delimited "$data/card.csv", clear

	
	//lwage: Logaritmo del salario anual
	sum lwage, det
	
	//educ: Años de educación del individuo
	sum educ, det
	
	//nearc4: Variable dicotómica que identifica si el individuo vive cerca de una
	//		  universidad (==1) o lejos (==0)
	tab nearc4, mis
	
	//smsa: Variable dicotómica que identifica si el individuo vive en una zona
	//		metropolitana (==1) o no (==0).
	tab smsa, mis
	
	//exper: Años de experiencia que tiene el individuo
	sum exper, det
	sum expersq, det
	
	//black: Variable dicotómica que identifica si el individuo es de raza negra
	//		 (==1) o no (==0).
	tab black, mis
	
	//south: Variable dicotómica que identifica si el individuo vive en el sur
	//		 (==1) o no (==0).
	tab south, mis
	
*Paso 10: Estimar el modelo con problema de endogeneidad
	reg lwage educ smsa exper black south
	
*Paso 11: Estimar el modelo a través de IV
	ivregress 2sls lwage smsa exper black south (educ = nearc4) 
	