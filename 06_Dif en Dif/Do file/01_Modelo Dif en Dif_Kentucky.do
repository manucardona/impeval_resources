/*******************************************************************************
		- Autor: Manuel Cardona
		- Propósito: Modelo de diferencias en diferencias de 
		- Datos: 
		- Windows
		- Stata 15.1 (Noviembre-2020)
*******************************************************************************/   	

set more off

*Globals: Estas rutas deberán ser modificadas, respecto al usuario.
 *Ej: global working "C:\Usuarios\Nombre\Dropbox\...\...\..."
 
global data "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\06_Dif en Dif\Data"
global dofile "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\06_Dif en Dif\Do file"

		*************************************************
		**********Descripción del programa***************
		*************************************************
		
*En 1980, el estado de Kentucky aumentó el límite superior en las ganancias semanales
*que estaban cubiertas por la compensación al trabajador; es decir, por los beneficios
*recibidos luego de un accidente en el trabajo. El objetivo de la evaluación es 
*saber si esta política provocó que los trabajadores pasaran más tiempo sin trabajar.

*Si los beneficios no son lo suficientemente generosos, los trabajadores podrían
*demandar a las empresas por lesiones en el trabajo, mientras que, si las compensaciones
*eran demasiado generosas, los beneficios podrían causar un problema de moral hazard e
*inducir a los trabajadores a ser más imprudentes en el trabajo o a afirmar que las lesiones
*que ocurrieron fuera del trabajo ocurrieron dentro del lugar de trabajo.
		
 import delimited "$data\injury.csv", clear
 
*Variables de resultados:
	//La variable de resultados es el logaritmo de la duración del tiempo (en semanas)
	//que el empleado estuvo recibiendo los beneficios de compensación.
	sum ldurat, det
	
*Variable de tratamiento:
	//La política estaba diseñada de tal manera que el incremento en la compensación
	//no afectara a los "low-earning workers", pero sí a los "high-earning workers". Por
	//ello, utilizaremos a los "low-earning workers" como grupo de control y a los
	//"high-earning workers" como grupo de tratamiento.
	
*Indicador de tiempo:
	//La variable after_1980 toma el valor de 0 para aquellas observaciones que sucedieron
	//antes de 1980 y de 1 para aquellas que sucedieron después. 
	

		*****************************************
		**********Limpieza de datos**************
		*****************************************
		
*Nos quedamos con observaciones sólo de Kentucky:
keep if ky==1

*Renombramos algunas variables:
ren (durat ldurat afchnge) (duration log_duration after_1980)

		******************************************************
		**********Análisis exploratorio de datos**************
		******************************************************
		
histogram duration, by(highearn)
	//Podemos ver que la distribución, en ambos grupos, está muy sesgada. La mayoría
	//en ambos grupos, se encuentra entre 0 y 8 semanas de duración; y algunos como más de
	//180 semanas (3.5 años!!!).

histogram log_duration, by(highearn)
	//Si utilizamos una transformación logarítmica, veremos que la distribución ya no
	//está tan sesgada.
	
histogram log_duration, by(after_1980)
	//También debemos analizar nuestra distribución de la variable de resultados en el
	//indicadore del tiempo. Si bien es cierto que se ven, aproximadamente, "normales",
	//no podemos apreciar diferencias entre los periodos antes y después de la política.
	//Para ello, utilizaremos una evaluación con un modelo Diff in Diff. 
	
	
		*******************************************
		**********Diff-in-diff a mano**************
		*******************************************
		
*Necesitamos cuatro medias:
	*A. High-earn antes de 1980
	mean log_duration if highearn==1 & after_1980==0
	
	*B. Low-earn antes de 1980
	mean log_duration if highearn==0 & after_1980==0
	
	*C. High-earn después de 1980
	mean log_duration if highearn==1 & after_1980==1
	
	*D. Low-earn después de 1980
	mean log_duration if highearn==0 & after_1980==1

*El estimador del modelo simple estará determinado por:
 *T(did)=(C-D)-(A-B)

 mata
 (1.580352 - 1.133273) - (1.382094 - 1.125615)
 end
 
 
	//El estimador diff-in-diff es de 0.1906, lo cual indica que el programa causó
	//un incremento del "reposo" de 0.19 semanas log. 
	
	//En otras palabras, la política causa un incremento del 19% en la duración de
	//los periodos de reposo de los trabajadores.
	
		*******************************************
		**********Diff-in-diff con MCO*************
		*******************************************	
		
*El mismo estimador se puede obtener, utilizando un modelo de regresión lineal:

	gen intreac=highearn*after_1980
	
reg log_duration highearn after_1980 highearn#after_1980
reg log_duration highearn after_1980 intreac

	//El estimador del impacto de la política es idéntico al que obtuvimos a mano, 
	//sólo que ahora podemos saber que el coeficiente es estadísticamente distinto
	//de 0, a un 99% de confianza.
	
	
		*******************************************
		**********Diff-in-diff con controles*******
		*******************************************
		
*Ahora, utilizaremos controles adicionales, para ayudar a aislar el efecto de la política
*sobre la duración del reposo de los trabajadores y para mejorar la eficiencia del estimador.

*Por ejemplo, puede ser que las peticiones de reposo de los trabajadores de un tipo de 
*industria tiendan a ser más largas que las de otro tipo de industria. Puede ser que las
*peticiones por lesiones en la espalda sean más largas que por lesiones en la cabeza.

*Controlaremos por las siguientes variables:
tab male
	drop if male=="NA"
	destring male, replace
tab married
	drop if married=="NA"
	destring married, replace
tab age
	drop if age=="NA"
	destring age, replace
tab hosp
tab indust
	drop if indust=="NA"
	destring indust, replace
tab injtype
tab lprewage

	//Es importante tratar las variables indust y injtype como variables categóricas y no como
	//variables continuas.
	
reg log_duration highearn after_1980 intreac male married age hosp i.indust i.injtype lprewage
	//Después de controlar por los regresores adicionales, obtenemos un estimador más
	//pequeño (0.1687), indicando que la política causó un incremento del 17% en la duración
	//del reposo de los trabajadores, luego de una lesión. El efecto es menor, poque las variables
	//adicionales explican alguna parte del cambio en la duración de los periodos de reposo.
