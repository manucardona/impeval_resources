/*******************************************************************************
		- Autor: Manuel Cardona
		- Propósito: Modelo de regresión discontinua
		- Datos: Programa de tutorías gratuitas por resultado en examen
		- Windows
		- Stata 15.1 (Noviembre-2020)
*******************************************************************************/   	

set more off

*Globals: Estas rutas deberán ser modificadas, respecto al usuario.
 *Ej: global working "C:\Usuarios\Nombre\Dropbox\...\...\..."
 
global data "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\08_Discontinuity Design\Data"
global dofile "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\08_Discontinuity Design\Do file"

		*************************************************
		**********Descripción del programa***************
		*************************************************

*El programa a evaluar consiste en que, después de tomar un examen inicial al 
*inicio del ciclo escolar, los alumnos que obtengan un puntaje de 70 o menor son
*automáticamente inscritos a un programa de tutorías gratuitas y recibien asistencia
*durante todo el ciclo.  Al finalizar el ciclo escolar, los estudiantes toman un
*examen final (máximo de 100 puntos) para medir su nivel de aprovechamienton general.

*Tenemos datos de 1,000 alumnos que iniciaron en el mismo ciclo escolar. Todos los
*alumnos tomaron un test inicial y un test final. Aquellos que obtuvieron una
*calificación de 70 o menos fueron inscritos automáticamente al programa de tutorías.

*Los datos NO SON EXPERIMENTALES.

 import delimited "$data\tutoring_program.csv", clear	

*La base de datos contiene las siguientes variables:
	//id: Variable que permite identificar al alumno.
	isid id
	
	//entrance_exam: Resultado del examen que el alumno tomó al inicio del ciclo.
	//				 La variable puede tomar valores entre 0 y 100; donde los mayores
	//				 valores indican un mejor aprovechamiento.
	sum entrance_exam, det
	
	//exit_exam: Resultado del examen que el alumno tomó al finalizar el ciclo.
	//			 La variable puede tomar valores entre 0 y 100; donde los mayores
	//			 valores indican un mejor aprovechamiento. La prueba que toman
	//			 al finalizar el curso mide lo mismo que la prueba inicial.
	sum exit_exam, det
	
	//tutoring: Esta variable dicotómica indica si el alumno fue inscrito al programa
	//			de tutorías.
	tab tutoring, mis
	

*Paso 1: Determinar si el programa es asignado con una regla específica.
	//En este caso, dada la naturaleza del programa, sabemos que ningún alumno que
	//haya obtenido un puntaje mayor a 70 va a ser elegible para el programa. 
	
*Paso 2: Determinar si el diseño de discontinuidad es nítida o borrosa. 
	//Ya sabemos que el programa tiene como criterio de elegibilidad un threshold
	//en el puntaje del alumno, sin embargo, necesitamos saber qué tan estrictamente
	//se siguió dicha regla. 
	tab entrance_exam tutoring, mis
	gen tutoring_2=(tutoring=="TRUE")
	label define tut 0 "Didn't receive tutoring" 1 "Received tutoring"
	label values tutoring_2 tut
	
	twoway (scatter tutoring_2 entrance_exam, sort) //No tan bonita, pero sirve
	
	//Dadas las características de la entrega del programa, podemos aseverar que
	//el diseño de discontinuidad es nítido.
	
*Paso 3: Revisar la discontinuidad de la variable de tratamiento, sobre la variable
*		 continua cerca del punto de corte.

	//Algo muy relevante es analizar si no existió manipulación en la variable
	//continua, con el objetivo de que las personas recibieran el tratamiento (es
	//decir, que los profesores hayan calificado a muchos alumnos con 68, 69 o 70
	//solo para que recibieran las tutorías; o que los hayan calificado justi arriba
	//del threshold, solo para no tener que darles clases extra). 
	
	//Para realizar esto, podemos hacer un histograma de la variable continua y
	//analizar algun poible brinco repentino.
	histogram entrance_exam, bin(50) frequency
	
	//Parece que no existe un brinco repentino antes o después del 70, sin embargo,
	//parece que la frecuencia de valores mayores a 70 es mayor que la de menores a
	//70; sin embargo, parece que se sigue la misma distribución general. 
	
*Paso 4: Revisar discontinuidad en la variable de resultados, sobre la variable
*		 continua.

	//Hacemos una visualización de las calificaciones del examen final, sobre las
	//calificaciones del examen inicial, por la variable de tratamiento.
	gen tutoring_3=tutoring_2
	replace tutoring_3=2 if tutoring_3==0
	label define tuto 1 "Received tutoring" 2 "Didn't receive tutoring"
	label values tutoring_3 tuto
	
	replace tutoring="Received tutoring" if tutoring=="TRUE"
	replace tutoring="Didn't receive tutoring" if tutoring=="FALSE"
	
	twoway (scatter exit_exam entrance_exam, mcolor(*.6) by(tutoring_3)) (lfit exit_exam entrance_exam, by(tutoring_3))
	
	//Con base en la gráfica, podemos ver que hay una discuntinuidad muy clara.
	//Parece ser que la participación en el programa potencia los resultados en el
	//examen final.
	
*Paso 5: Cuantificar el efecto de la intervención

	//Estimación paramétrica: Queremos conocer si las calificaciones finales son
	//afectadas por la participación en el programa de tutorías. Podemos elaborar
	//la siguiente regresión lineal:
		
		//   exit_exam = b_0 + b_1(entrance_exam_standard) + b_2(tutoring) + e
		
	//Para volver más fácil la interpretación de los coeficientes, estandarizaremos
	//la variable del entrance_exam, para que en lugar de que muestre la calificación, 
	//muestre qué tan cerca se encuentra del threshold de 70. 
	
	gen entrance_centered=entrance_exam-70
	
	reg exit_exam entrance_centered tutoring_2
	
*Paso 6: Interpretar coeficientes
	
	//b_0: Intercepto. Dado que la variable del entrance_exam está centrada, la
	//	   constante muestra el promedio de las calificaciones del examen final
	//	   en el threshold de 70.00001 puntos. La gente que obtuvo 70 puntos en 
	//	   el examen inicial, tuvo, en promedio, una calificación de 59.41 en el
	//	   examen final.
	
	//b_1: Es el efecto adicional por cada punto sobre 70 en el examen inicial. 
	//	   Este coeficiente no nos interesa tanto, dado que no queremos conocer
	//	   la relación entre los resultados de ambos exámenes; sólo lo utilizamos
	//	   como variable de control, porque esperamos que los alumnos con mejor
	//	   calificación al entrar, también tengan mejor calificación al salir.
	
	//b_2: Es el efecto del programa de tutorías. Este es el cambio en el intercepto,
	//	   cuando los alumnos reciben el programa de tutorías. Ser participante
	//	   del programa tiene un efecto de 10.8 puntos en la calificación del 
	//	   examen final.
	
*Paso 7: Restringir la muestra a una población "similar"
	
	//Hasta el momento, ajustamos el modelo para toda la muestra; sin embargo, 
	//lo que más nos interesa es el efecto para las observaciones que se encuentran
	//cerca del threshold.  Las calificaciones que son super bajas o super altas 
	//pueden afectar el tamaño del efecto del programa.
	
	//A continuación, ajustamos el modelo, restringiendo la muestra a los que se
	//encuentran en un rango de -10,+10 puntos respecto al threshold.
	preserve
	keep if entrance_centered>=-10 & entrance_centered<=10
	reg exit_exam entrance_centered tutoring_2
	restore
	
	//Cuando filtramos las observaciones a las que se encuentren más cerca del
	//threshold, obtenemos un coeficiente aun signifivcativo pero menor en tamaño.
	//El efecto del programa de tutorías es de 9.27 puntos en la calificación del
	//examen final. 
	
	//Entre más restrinjamos nuestra muestra, más pequeño el es el coeficiente:
	preserve
	keep if entrance_centered>=-5 & entrance_centered<=5
	reg exit_exam entrance_centered tutoring_2
	restore	
	
	
*Paso 8: Regresión discontinua borrosa

	//En el ejemplo anterior, medir el efecto del programa fue sencillo, dado que
	//era un diseño nítido y el programa tuvo aceptación perfecta (perfect compliance).
	//En la siguiente base, tenemos el mismo programa, pero en un contexto donde
	//no hubo aceptación perfecta (hubo controles que tomaron el programa y tratados
	//que no lo tomaron). 
	
	 import delimited "$data\tutoring_program_fuzzy.csv", clear	
	 
	//En la siguiente gráfica y tabla podemos ver cómo personas con score menor
	//que 70 reportan no haber recibido tutorías y personas con score mayor a 70
	//reportan sí haber recibido tutorías.
	tab entrance_exam tutoring, mis
	gen tutoring_2=(tutoring=="TRUE")
	label define tut 0 "Didn't receive tutoring" 1 "Received tutoring"
	label values tutoring_2 tut
 	twoway (scatter tutoring_2 entrance_exam, sort) //No tan bonita, pero sirve
	
*Paso 9: Revisar discontinuidad en la variable de resultados, sobre la variable
*		 continua.

	//Hacemos una visualización de las calificaciones del examen final, sobre las
	//calificaciones del examen inicial, por la variable de tratamiento.
	gen tutoring_3=tutoring_2
	replace tutoring_3=2 if tutoring_3==0
	label define tuto 1 "Received tutoring" 2 "Didn't receive tutoring"
	label values tutoring_3 tuto
	
	replace tutoring="Received tutoring" if tutoring=="TRUE"
	replace tutoring="Didn't receive tutoring" if tutoring=="FALSE"
	
	twoway (scatter exit_exam entrance_exam, mcolor(*.6) by(tutoring)) (lfit exit_exam entrance_exam if entrance_exam<=70, by(tutoring) mcolor(*.2)) (lfit exit_exam entrance_exam if entrance_exam>70, by(tutoring) mcolor(*.8))
	
	//La línea verde representa los valores ajustados para las personas que
	//EFECTIVAMENTE NO recibieron tutorías, mientras la línea roja representa los
	//valores ajustados para los que EFECTIVAMENTE SÍ recibieron tutorías.
	
	//Aun hay una discontinuidad visible en el 70, pero hay personas que reciberon
	//y que no recibieron tutorías en ambos lados del threshold.
	
*Paso 10: Medir la discontinuidad borrosa

	//En este caso, es posible utilizar un Método de Variables Instrumentales
	//para medir el Intent To Treat (ITT) del programa. Creamos una variable que indique si el
	//individuo es "elegible" o "digno de tratar". Nuestro instrumento es válido
	//dado que se cumplen las siguientes tres condiciones:
	
		*Relevancia: El threshold garantiza acceso al programa (Z afecta a X)
		
		*Exclusión: El threshold tiene un efecto sobre las calificaciones del examen
		*			final, sólo a través del acceso al programa de tutorías (Corr(Z,Y|X)=0)
		
		*Exogeneidad: Los factores no observables entre el programa de tutorías y
		*			  las calificaciones finales no están relacionadas con el threshold.
		
*Paso 11: Estimación paramétrica borrosa

	//Primero, volvemos a centrar nuestra variable continua.
	gen entrance_centered=entrance_exam-70
	
	//Creamos nuestro instrumento:
	gen below_cutoff=(entrance_exam<=70)
	
	//Si tratamos de estimar la misma ecuación que en la regresión nítida:
	
	//   exit_exam = b_0 + b_1(entrance_exam_standard) + b_2(tutoring) + e
		
		reg exit_exam entrance_centered tutoring_2

	//Obtendríamos un efecto de 11.36 puntos en la calificación del examen final
	//atribuible al programa de tutorías. Sin embargo, este estimador es incorrecto.
	
	//Lo que haremos es correr un modelo 2SLS, dentro de un rango de -10,+10
	//respecto al threshold de 70, donde estimemos las siguientes ecuaciones:
		preserve 
		keep if entrance_centered>=-10 & entrance_centered<=10
		
		*Primera etapa:
			
			//   tutoring = b_0 + b_1(entrance_centered) + b_2(below_cutoff) + w
			reg tutoring_2 entrance_centered below_cutoff
			predict double tutoring_adjusted
			
		*Segunda etapa:
		
			//   exit_exam = b_0 + b_1(entrance_centered) + b_2(tutoring_adjusted) + e
			reg exit_exam entrance_centered tutoring_adjusted
			
		restore
	
	//Al obtener nuestro estimador de variables instrumentales, obtenemos un efecto
	//atribuible al programa de 9.74 puntos en la calificación del examen final, 
	//para los compliers dentro del rango cercano al threshold de 70.
	
