****************************************************
*** Objetivo: Limpiar base de datos ENSANUT 2016 ***
*** Autor: Manuel Cardona                        ***
*** Última modificación: 23/Oct/2019 			 ***
*** Trabajado en STATA 15.1						 ***
****************************************************

clear all // Elimina data y etiquetas de variables de la memoria.

* Inputs
	// Los global nos permiten almacenar información en una variable dentro del 
	// "ambiente" de Stata que después podemos usar en nuestro do file.
	// La diferencia entre un global y un local: 
	global salud "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\01_Intro Stata\01 Data\01 Raw data\ENSANUT 2016\SALUD"
	global nutri "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\01_Intro Stata\01 Data\01 Raw data\ENSANUT 2016\NUTRICIÓN"
	global do "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\01_Intro Stata\02 Do"
	global output "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\01_Intro Stata\01 Data\02 Clean data"
		// Aquí almacené los path donde tengo guardadas mis bases de datos
		// o donde quiero que me guarde resultados.
		
**********************************
* Base original: Hogares ENSANUT *
**********************************

	use "$salud/Hogar_socioeconomicoprocesada.dta", clear 
	// El comando use jala la base de datos que queremos utilizar
	// La opción clear borra todos los datos y matricies que previamente estaban
	// cargados en el ambiente de Stata. 
	
	// ¿Qué pasa si no especifico "clear"?

* Deben existir 9,479 hogares
	duplicates report folio 
	// El comando duplicates nos permite conocer observaciones que esten repetidas
	// en la misma variable. 
	
	// ¿De qué otra manera podríamos encontrar información duplicada?
	isid folio
	
* Este será el nivel mínimo de observación de la asignación del tratamiento. 
* Todas las variables dependientes, de control y de tratamiento. 

* Variables que se quedarán en la base master:
	keep folio folio_viv entidad munici locali h205 h102 h501 h502 h503 h504 h505 h506 h507 h509 h510 h511 h513 h514 h519 h523 h60102 h60102_2 h60104 h60106 h60107 h60108 h60109 h60110 h60111 h60112 h60113 h60114 h60115 h60116 h60117 h60118 h60119 h60120 h60121 h60122 h60123 h60124 h60125 code_upm est_var region_h Area rural ponde_h indiceF nseF nse5F ESTUFA Agua Combustiblecocinar Piso Drenaje
	// Keep permite especificar las variables/observaciones que queremos
		// conservar en nuestra base de datos. 
		
		// ¿De qué otra manera podemos usar keep?
		
		// ¿Cuál es el antónimo de keep en Stata?
		
* Número de integrantes del hogar
	ren h205 num_int
		// El comando rename nos permite renombrar variables. 
		// rename nombre_antiguo nombre_nuevo
		
	label var num_int "Total de integrantes en el hogar"
		// Label var nos permite asignar una etiqueta a la variablen con su
		// definición. 
		
		// ¿Label nos sirve únicamente para añadir etiquetas a las variables?
		
* Número de integrantes del hogar que comparten el mismo gasto
	ren h102 num_int_gasto
	label var num_int_gasto "Número de personas en el hogar que comparten el mismo gasto"

* Material de las paredes del hogar
	ren h501 material_pared
	label var material_pared "Material de construcción de las paredes del hogar"

* Material del techo del hogar
	ren h502 material_techo
	label var material_techo "Material de construcción del techo del hogar"

* Material del piso del hogar
	ren h503 material_piso
	label var material_piso "Material de construcción del piso del hogar"

* El hogar tiene un cuarto para cocinar
	ren h504 cocina
	label var cocina "¿Tiene el hogar un cuarto para cocinar?"
	replace cocina=0 if cocina==2
		// replace es un comando que nos permite cambiar los valores de una variable
		// con base en condiciones denotadas con operadores lógicos. 
		
		// ¿Qué es un operador lógico?
		
		// ¿Qué operadores lógicos conocen?
		
	label define sino 0 "No" 1 "Si"
		// label define nos permite crear etiquetas para los posibles valores de
		// una variable. Este comando crea un global que no podemos observar, pero
		// que siempre está en el ambiente de Stata. 
		
		// ¿De qué manera puede desaparecer ese global?
		
	label values cocina sino
		// label values asigna los valores de la etiqueta que creamos a una
		// variable de la base de datos. 
		
		// label values variable etiqueta
		
		
* Número de dormitorios
	ren h505 num_dormitorios
	label var num_dormitorios "Número de habitaciones que se utilizan para dormir"

* Número total de habitaciones
	ren h506 num_habitaciones
	label var num_habitaciones "Cúantas habitaciones tiene la casa en total"

* Luz eléctrica
	ren h507 electricidad
	label var electricidad "Hay luz eléctrica en el hogar"
	replace electricidad=0 if electricidad==2
	label values electricidad sino

* Días con agua 
	ren h509 dias_agua
	label var dias_agua "Cuántos días a la semana les llega agua al hogar"

* Excusado
	ren h510 excusado
	label var excusado "Tiene excusado, retrete, letrina u hoyo negro el hogar"
	replace excusado=0 if excusado==2
	label values excusado sino

* Excusado compartido
	ren h511 excusado_comparte
	label var excusado_comparte "Este excusado es compartido con otro hogar"
	replace excusado_comparte=0 if excusado_comparte==2
	label values excusado_comparte sino

* Drenaje
	ren h513 drenaje
	label define drena 1 "Red pública" 2 "Fosa Séptica" 3 "Tubería a barranca" 4 "Tubería a río o lago" 5 "No tiene drenaje"
	label values drenaje drena

* Combustible para cocinar
	ren h514 combustible_cocina
	label var combustible_cocina "Combustible más usado para cocinar"

* Tipo de estufa
	ren h519 estufa_tipo
	label var estufa_tipo "Tipo de estufa utilizada en el hogar"

* Número de focos en la vivienda
	ren h523 focos
	label var focos "Número de focos en la vivienda"

* Automovil en el hogar
	ren h60102 automovil
	label var automovil "Usted o algun otro miembro tiene algun automovil"
	replace automovil=0 if automovil==2
	replace automovil=0 if automovil==9
	label values automovil sino

* Cuántos automóviles hay en el hogar
	ren h60102_2 num_autos
	replace num_autos=0 if num_autos==.
	* Borrando esta variable porque no está en la base 2012. 
	drop num_autos
	
* Motocicleta en el hogar
	ren h60104 motocicleta
	replace motocicleta=0 if motocicleta!=1
	label values motocicleta sino

* Television en el hogar
	ren h60106 TV
	replace TV=0 if TV!=1
	label values TV sino

* Servicio de TV de paga
	ren h60107 TV_paga
	replace TV_paga=0 if TV_paga!=1
	label values TV_paga sino

* Radio en el hogar
	ren h60108 radio
	replace radio=0 if radio!=1
	label values radio sino

* Modulares, consola o estéreo en el hogar
	ren h60109 estereo
	replace estereo=0 if estereo!=1
	label values estereo sino

* Plancha en el hogar
	ren h60110 plancha
	replace plancha=0 if plancha!=1
	label values plancha sino

* Licuadora en el hogar
	ren h60111 licuadora
	replace licuadora=0 if licuadora!=1
	label values licuadora sino

* Refrigerador en el hogar
	ren h60112 refrigerador
	replace refrigerador=0 if refrigerador!=1
	label values refrigerador sino

* Estufa de gas en el hogar
	ren h60113 estufa_gas
	replace estufa_gas=0 if estufa_gas!=1
	label values estufa_gas sino

* Estufa de otro combustible
	ren h60114 estufa_otro
	replace estufa_otro=0 if estufa_otro!=1
	label values estufa_otro sino

* Lavadora o secadora 
	ren h60115 lavadora_sec
	replace lavadora_sec=0 if lavadora_sec!=1
	label values lavadora_sec sino

* Calentador de agua (boiler)
	ren h60116 boiler
	replace boiler=0 if boiler!=1
	label values boiler sino

* Computadora de escritorio en el hogar
	ren h60117 computadora
	replace computadora=0 if computadora!=1
	label values computadora sino

* Servicio de internet
	ren h60118 internet
	replace internet=0 if internet!=1
	label values internet sino

* Microondas en el hogar
	ren h60119 microondas
	replace microondas=0 if microondas!=1
	label values microondas sino

*Línea telefónica fija en el hogar
	ren h60120 telefono
	replace telefono=0 if telefono!=1
	label values telefono sino

* Tinaco en el hogar
	ren h60121 tinaco
	replace tinaco=0 if tinaco!=1
	label values tinaco sino

* Cisterna o aljiber en el hogar
	ren h60122 cisterna_aljiber
	replace cisterna_aljiber=0 if cisterna_aljiber!=1
	label values cisterna_aljiber sino

* Medidor de luz en el hogar
	ren h60123 medidor_luz
	replace medidor_luz=0 if medidor_luz!=1
	label values medidor_luz sino

* Teléfono celular en el hogar
	ren h60124 celular
	replace celular=0 if celular!=1
	label values celular sino

* Aire acondicionado en el hogar
	ren h60125 AC
	replace AC=0 if AC!=1
	label values AC sino
	
* Ordenamos un poco la base de datos
order folio-locali code_upm-nse5F
	// order nos permite seleccionar algunas variables que queremos que aparezcan
	// primero en la base de datos. 
	
	// ¿Qué significa el guión entre las dos variables?
	
compress
	// ¿Qué es compress? 
	
save "$output/ENSANUT_2016_master.dta", replace
	// save guarda la base de datos en algún directorio especificado. 
	
	// ¿A dónde está mandando la base de datos?
	
	// ¿Por qué replace?
	
**************************************
* Base original: Integrantes ENSANUT *
**************************************

	use "$salud/Hogar_Integrantes_procesada.dta", clear
	
* Debe haber un total de 29,795 integrantes de hogar en 9,479 hogares
	
	* int is a Stata comand, so renaming
		ren int integrante
		
	duplicates report folio_viv integrante

* Todas las variables de esta base de datos están a nivel individual, pero se
* transformarán a nivel hogar, de tal manera que sean intuitivas para poder hacer la evaluación.

* Variables que servirán para la base máster:
	keep folio folio_viv integrante edad meses dia_nac mes_nac anio_nac nac sexo intsel inth h207 h211a h211b Seguro1 Seguro2 h212 h215 h216 h217 h221 nseF nse5F h218a h218b h220
	
* Edad. Dado que el propósito del matching es encontrar hogares similares en ambos años de encuesta, 
* no hace sentido, separar por grupos de edades. Lo que haré es separar por el número de personas en 
* el hogar que nacieron en cada década comenzando desde el primer registro. Por ello, me quedaré sólo
* con la variable de año de nacimiento. 
	
	drop meses-nac

* Dado que hay muchos missing values en la variable de fecha de nacimiento, utilizaré la variable de edad, 
* para calcular el año en el que nacuieron. Es decir, año=(2016-edad).
	count if edad==.
	gen anio_nac=2016-edad
	tab anio_nac, mis

* Hay 22 observaciones que no quisieron revelar su edad. Estas observaciones serán missing values por ahora. 
	replace anio_nac=. if anio_nac==1017

* Vamos a generar variables dummy para cada una de las décadas. ¿Nació la persona en la década x?
	gen dec_1929=(anio_nac<=1929)
	gen dec_1930_1939=(anio_nac>=1930 & anio_nac<=1939)
	gen dec_1940_1949=(anio_nac>=1940 & anio_nac<=1949)
	gen dec_1950_1959=(anio_nac>=1950 & anio_nac<=1959)
	gen dec_1960_1969=(anio_nac>=1960 & anio_nac<=1969)
	gen dec_1970_1979=(anio_nac>=1970 & anio_nac<=1979)
	gen dec_1980_1989=(anio_nac>=1980 & anio_nac<=1989)
	gen dec_1990_1999=(anio_nac>=1990 & anio_nac<=1999)
	gen dec_2000_2009=(anio_nac>=2000 & anio_nac<=2009)
	gen dec_2010_2019=(anio_nac>=2010 & anio_nac<=2019)
	
	// ¿De qué otra manera pude haber creado estas variables?
	
* ¿Cuántas personas del hogar nacieron en la década x?
	// El comando bysort nos perimte agrupar las observaciones por alguna
	// variable en específico y, en este caso, el comando gen nos permitirá 
	// generar una variable que tome valores idénticos para todas las
	// observaciones que se identifiquen con un valor idéntico de la variable por
	// la cual estamos ordenando. 
	
	bysort folio_viv: gen dec_1929_num=sum(dec_1929)
		label var dec_1929_num "Numero de integrantes nacidos antes de 1929"
	bysort folio_viv: gen dec_1930_1939_num=sum(dec_1930_1939)
		label var dec_1930_1939_num "Número de integrantes nacidos entre 1930 y 1939"
	bysort folio_viv: gen dec_1940_1949_num=sum(dec_1940_1949)
		label var dec_1940_1949_num "Número de integrantes nacidos entre 1940 y 1949"
	bysort folio_viv: gen dec_1950_1959_num=sum(dec_1950_1959)
		label var dec_1950_1959_num "Número de integrantes nacidos entre 1950 y 1959"
	bysort folio_viv: gen dec_1960_1969_num=sum(dec_1960_1969)
		label var dec_1960_1969_num "Número de integrantes nacidos entre 1960 y 1969"
	bysort folio_viv: gen dec_1970_1979_num=sum(dec_1970_1979)
		label var dec_1970_1979_num "Número de integrantes nacidos entre 1970 y 1979"
	bysort folio_viv: gen dec_1980_1989_num=sum(dec_1980_1989)
		label var dec_1980_1989_num "Número de integrantes nacidos entre 1980 y 1989"
	bysort folio_viv: gen dec_1990_1999_num=sum(dec_1990_1999)
		label var dec_1990_1999_num "Número de integrantes nacidos entre 1990 y 1999"
	bysort folio_viv: gen dec_2000_2009_num=sum(dec_2000_2009)
		label var dec_2000_2009_num "Número de integrantes nacidos entre 2000 y 2009"
	bysort folio_viv: gen dec_2010_2019_num=sum(dec_2010_2019)
		label var dec_2010_2019_num "Número de integrantes nacidos entre 2010 y 2019"

		
	bysort folio_viv: egen dec_1990_1999_tot=max(dec_1990_1999_num)

* Ciertos programas tienen criterios de elegibilidad respecto a las edades de las personas:
	gen edad_18_67=(edad>=18 & edad<=67)
	gen edad_0_18=(edad>=0 & edad<=18)
	gen edad_60_mas=(edad>=60)
	gen edad_0_5=(edad<=5)
	gen edad_0_9=(edad<=9)
	gen edad_6_11=(edad>=6 & edad<=11)
	gen edad_14_26=(edad>=14 & edad<=26)
	gen edad_0_22=(edad<=22)
	gen edad_65_mas=(edad>=65)
	gen edad_0_12=(edad<=12)
	gen edad_13_15=(edad>=13 & edad<=15)
	gen edad_45_49=(edad>=45 & edad<=49)
	
* Las variables deben ser transformadas a nivel hogar: Al menos un integrante en el rubro de edad:
	bysort folio_viv: egen some_18_67=max(edad_18_67)
		label var some_18_67 "Algun miembro del hogar tiene entre 18 y 67 años"
	bysort folio_viv: egen some_0_18=max(edad_0_18)
		label var some_0_18 "Algun miembro del hogar tiene entre 0 y 18 años"
	bysort folio_viv: egen some_60_mas=max(edad_60_mas)
		label var some_60_mas "Agun miembro del hogar tiene 60 años o más"
	bysort folio_viv: egen some_0_5=max(edad_0_5)
		label var some_0_5 "Algún miembro del hogar tiene entre 0 y 5 años"
	bysort folio_viv: egen some_0_9=max(edad_0_9)
		label var some_0_9 "Algún miembro del hogar tiene entre 0 y 9 años"
	bysort folio_viv: egen some_6_11=max(edad_6_11)
		label var some_6_11 "Algún miembro del hogar tiene entre 6 y 11 años"
	bysort folio_viv: egen some_14_26=max(edad_14_26)
		label var some_14_26 "Algún miembro del hogar tiene entre 14 y 26 años"
	bysort folio_viv: egen some_0_22=max(edad_0_22)	
		label var some_0_22 "Algún miembro del hogar tiene entre 0 y 22 años"
	bysort folio_viv: egen some_65_mas=max(edad_65_mas)
		label var some_65_mas "Algún miembro del hogar tiene 65 años o más"
	bysort folio_viv: egen some_0_12=max(edad_0_12)
		label var some_0_12 "Algún miembro del hogar tiene entre 0 y 12 años"
	bysort folio_viv: egen some_13_15=max(edad_13_15)
		label var some_13_15 "Algún miembro del hogar tiene entre 13 y 15 años"
	bysort folio_viv: egen some_45_49=max(edad_45_49)
		label var some_45_49 "Algún miembro del hogar tiene entre 45 y 49 años"
		
* Mujeres en edad reproductiva (Mujeres entre 15 y 50 años)
	gen muj_rep=(sexo==2 & (edad>=15 & edad<=50))
	bysort folio_viv: egen some_muj_rep=max(muj_rep)
		label var some_muj_rep "Alguna mujer en edad reproductiva en el hogar"
		
* Eliminaré todas las variables que ya no me sirven respecto a la edad. 
	drop anio_nac dec_1929-dec_2010_2019 edad_18_67-edad_45_49 muj_rep
	
* Algún miembro del hogar habla alguna lengua indígena
	ren h212 lengua_indigena
	replace lengua_indigena=0 if lengua_indigena!=1
	label define sino 0 "No" 1 "Si"
	label values lengua_indigena sino
	bysort folio_viv: egen len_indigena=max(lengua_indigena)
	label var len_indigena "Habla alguien en el hogar alguna lengua indígena"
	drop lengua_indigena
	
* Algún miembro del hogar se considera indígena
	ren h215 considera_indigena
	replace considera_indigena=0 if considera_indigena!=1
	label values considera_indigena sino
	bysort folio_viv: egen consider_indigena=max(considera_indigena)
	label var consider_indigena "Alguien en el hogar se considera indígena"
	drop considera_indigena
	
* Sabe alguien en el hogar leer y escribir un recado
	ren h216 recado
	replace recado=0 if recado!=1
	label values recado sino
	bysort folio_viv: egen recado_hogar=max(recado)
	label var recado_hogar "Sabe alguien en el hogar leer y escribir un recado"
	drop recado
	
* Último grado de escolaridad aprobado por alguien en el hogar
	bysort folio_viv: egen max_grado=max(h218a)
	label var max_grado "Máximo grado de escolaridad aprobado por cualquier miembro del hogar"
	label define esco 0 "Ninguno" 1 "Preescolar" 2 "Primaria" 3 "Secundaria" 4 "Preparatoria o bachillerato" 5 "Normal Basica" 6 "Estudios tecnicos o comerciales con primaria terminada" 7 "Estudios tecnicos o comerciales con secundaria terminada" 8 "Estudios tecnicos o comerciales con preparatoria terminada" 9 "Normal de licenciatura" 10 "Licenciatura/Profesional" 11 "Maestria" 12 "Doctorado"
	label values max_grado esco
	tab max_grado, mis
	drop h218a h218b
	
* Afiliados a servicios de seguridad
	levelsof h211a
	gen seguro_medico=(h211a!=9 & h211a!=99 & h211a!=.)	
	bysort folio_viv: egen afiliado_medico=max(seguro_medico)
		label var afiliado_medico "El hogar se encuentra afiliado a servicios médicos"
	tab afiliado_medico, mis
	
* Afiliados a servicios del IMSS
	gen IMSS=(h211a==1)
	bysort folio_viv: egen afiliado_IMSS=max(IMSS)
		label var afiliado_IMSS "El hogar se encuentra afiliado a los servicios médicos del IMSS"
	tab afiliado_IMSS, mis
	
* Hogar con madre soltera jefa de familia
	gen madre_soltera=(sexo==2 & h207==1 & (h220==2 | h220==3))
	bysort folio_viv: egen madre_solt=max(madre_soltera)
		label var madre_solt "Hogar con madre soltera jefa de hogar"

* Jefe del hogar trabaja
	gen jefe_trab=(h207==1 & h221==1)
	bysort folio_viv: egen jefe_trabaja=max(jefe_trab)
		label var jefe_trabaja "El jefe del hogar trabajó por lo menos una hora en la semana pasada"
	
* Sexo del jefe del hogar
	gen jefe_sex=sexo
	replace jefe_sex=0 if h207!=1
		bysort folio_viv: egen jefe_sexo=max(jefe_sex)
			label var jefe_sexo "Sexo del jefe/a de hogar"
			label values jefe_sexo sexo
			
* Edad del jefe del hogar
	gen jefe_age=edad
	replace jefe_age=0 if h207!=1
		bysort folio_viv: egen jefe_edad=max(jefe_age)
			label var jefe_edad "Edad del jefe de hogar"
	
* Borrar variables irrelevantes
	drop folio integrante-h221 seguro_medico IMSS madre_soltera jefe_trab jefe_sex jefe_age
	
* Ahora tendremos que hacer un collapse para dejar las variables a nivel hogar
	collapse (max) nseF-jefe_edad, by(folio_viv)
		
	// collapse nos permite agregar, de alguna manera especificada, los valores
	// de las variables, respecto a una variable de agregación. 
	
	// collapse (manera de agregar) varlist, by(variable de agregación)
	
* Debemos tener ahora solo 9,479 observaciones.
	duplicates report folio_viv
	
* Volvemos a etiquetar algunas variables	
		label var nseF "Terciles"
		label var nse5F "Quintiles"
		
		label var dec_1929_num "Numero de integrantes nacidos antes de 1929"
		label var dec_1930_1939_num "Número de integrantes nacidos entre 1930 y 1939"
		label var dec_1940_1949_num "Número de integrantes nacidos entre 1940 y 1949"
		label var dec_1950_1959_num "Número de integrantes nacidos entre 1950 y 1959"
		label var dec_1960_1969_num "Número de integrantes nacidos entre 1960 y 1969"
		label var dec_1970_1979_num "Número de integrantes nacidos entre 1970 y 1979"
		label var dec_1980_1989_num "Número de integrantes nacidos entre 1980 y 1989"
		label var dec_1990_1999_num "Número de integrantes nacidos entre 1990 y 1999"
		label var dec_2000_2009_num "Número de integrantes nacidos entre 2000 y 2009"
		label var dec_2010_2019_num "Número de integrantes nacidos entre 2010 y 2019"
	
		label var some_18_67 "Algun miembro del hogar tiene entre 18 y 67 años"
		label var some_0_18 "Algun miembro del hogar tiene entre 0 y 18 años"
		label var some_60_mas "Agun miembro del hogar tiene 60 años o más"
		label var some_0_5 "Algún miembro del hogar tiene entre 0 y 5 años"
		label var some_0_9 "Algún miembro del hogar tiene entre 0 y 9 años"
		label var some_6_11 "Algún miembro del hogar tiene entre 6 y 11 años"
		label var some_14_26 "Algún miembro del hogar tiene entre 14 y 26 años"
		label var some_0_22 "Algún miembro del hogar tiene entre 0 y 22 años"
		label var some_65_mas "Algún miembro del hogar tiene 65 años o más"
		label var some_0_12 "Algún miembro del hogar tiene entre 0 y 12 años"
		label var some_13_15 "Algún miembro del hogar tiene entre 13 y 15 años"
		label var some_45_49 "Algún miembro del hogar tiene entre 45 y 49 años"
		
		label var some_muj_rep "Alguna mujer en edad reproductiva en el hogar"
		label values some_muj_rep sino
		
		label var len_indigena "Habla alguien en el hogar alguna lengua indígena"
		label values len_indigena sino
	
		label var consider_indigena "Alguien en el hogar se considera indígena"
		label values consider_indigena sino
		
		*label var recado_hogar "Sabe alguien en el hogar leer y escribir un recado"
		*label values recado_hogar sino
		
		label var max_grado "Máximo grado de escolaridad aprobado por cualquier miembro del hogar"
		label values max_grado esco
		
		label var afiliado_medico "Está el hogar afiliado a algún sistema de servicios médicos"
		label values afiliado_medico sino
		
		label var afiliado_IMSS "Está el hogar afiliado al IMSS"
		label values afiliado_IMSS sino
		
		label var madre_solt "Hogar con jefatura femenina soltera"
		label values madre_solt sino
		
		label var jefe_trabaja "El jefe de hogar trabajó por lo menos una hora en la semana pasada"
		label values jefe_trabaja sino
		
		label var jefe_sexo "Sexo del jefe del hogar"
		label values jefe_sexo sexo
		
		label var jefe_edad "Edad del jefe del hogar"
		e
		

recast str2045 folio_viv, force
	// recast nos perimte cambiar el tipo de variable, para asegurarnos que tiene
	// alguna forma que necesitamos.
	
	// recast tipo_variable variable, force
	
* Merge con master db
	merge 1:1 folio_viv using "$output/ENSANUT_2016_master.dta"
	
	// merge es uno de los comandos más bonitos de Stata! <3
	// Nos permite unir dos bases de datos, con base en una(s) variable(s) que
	// tengan en comun. 
	
	// merge relación variable_comun using path
	
	// ¿1:1? ¿1:m? ¿m:1? ¿m:m?
	
* Vamos a hacer nuestra base un poco más bonita
	order folio_viv folio entidad-indiceF nseF nse5F num_int-Drenaje dec_1929_num-jefe_edad
	drop _merge
	compress
	save "$output/ENSANUT_2016_master.dta", replace
	
************************************************
* Base original: Seguridad Alimentaria ENSANUT *
************************************************

	use "$nutri/nutri_segalim_procesada_14112016.dta", clear
	
* Variables relevantes: ELCSA
	keep folio sum_total niv_seg
	
* Niveles de la Escala Latinoamericana y Caribeña de la Seguridad Alimentaria
	tab sum_total, mis
	tab niv_seg, mis
	
* Merge con master db
	merge 1:m folio using "$output/ENSANUT_2016_master.dta"
	
* Hay 460 hogares que no tienen respuesta para sus valores de ELCSA.
	tab niv_seg, mis
	
* Vamos a hacer nuestra base un poco más bonita
	order folio_viv folio entidad-max_grado sum_total niv_seg
	drop _merge
	compress
	save "$output/ENSANUT_2016_master.dta", replace
	
	
************************************
* Base original: Programas ENSANUT *
************************************

	use "$nutri/Programas_Hogar_2016.dta", clear
	
* Me quedaré con las variables que me servirán.
	keep folio nd102_hog nd103_hog nd104_hog nd105_hog nd107_hog nd109_hog nd110_hog nd111_hog nd113_hog nd118_hog nd116_hog nd126_hog nd131_hog nd142_hog total_prog_nuevo prog_recod cat_Programas

* Alimentos del programa DIF
	ren nd102_hog alimentos_DIF
	replace alimentos_DIF=0 if alimentos_DIF==.
	label define sino 0 "No" 1 "Si"
	label values alimentos_DIF sino
	
* Cocinas o desayunadores comunitarios del DIF
	ren nd103_hog cocinas_DIF
	replace cocinas_DIF=0 if cocinas_DIF==.
	label values cocinas_DIF sino
	
* Desayunos escolares (fríos o calientes) del DIF
	ren nd104_hog desayunos_DIF
		* Gran cantidad de missing values, así que borraré. 
		drop desayunos_DIF
		
* Suplementos de Hierro
	ren nd105_hog sup_hierro
	replace sup_hierro=0 if sup_hierro==.
	label values sup_hierro sino
	
* Suplementos de Ácido Fólico
	ren nd107_hog sup_folico
	replace sup_folico=0 if sup_folico==.
	label values sup_folico sino
	
* Apoyos monetarios del Programa de Apoyo Alimentario (PAL)
	ren nd109_hog PAL
	replace PAL=0 if PAL==.
	label values PAL sino
	
* Apoyo alimentario de albergues y/o comedores escolares indígenas
	ren nd110_hog comedores_indigenas
	replace comedores_indigenas=0 if comedores_indigenas==.
	label values comedores_indigenas sino
	
* Suplementos de vitamina A
	ren nd111_hog sup_A
	replace sup_A=0 if sup_A==.
	label values sup_A sino
	
* Apoyo de ONG's
	ren nd113_hog ONG
	replace ONG=0 if ONG==.
	label values ONG sino
	
* Programa de Desarrollo Humano Oportunidades
	ren nd118_hog oportunidades
	replace oportunidades=0 if oportunidades==.
	label values oportunidades sino
	
* Apoyos monetarios a adultos mayores
	ren nd116_hog monetario_mayores
	replace monetario_mayores=0 if monetario_mayores==.
	label values monetario_mayores sino
	
* Becas escolares
	ren nd126_hog becas
	tab becas, mis
	replace becas=0 if becas==.
	label values becas sino
	
* Suplemento alimenticio para niños
	ren nd131_hog suplemento_ninos
	replace suplemento_ninos=0 if suplemento_ninos==.
	label values suplemento_ninos sino
	
* Suplemento LICONSA
	ren nd142_hog liconsa
	replace liconsa=0 if liconsa==.
	label values liconsa sino

* Merge con master db.
	merge 1:1 folio using "$output/ENSANUT_2016_master.dta" 

* Arreglando missing values. Si no estaban en la base de programas es porque no reciben algun programa
	foreach var of varlist alimentos_DIF-liconsa{
		replace `var'=0 if `var'==.
		}
		
* Vamos a hacer nuestra base un poco más bonita
	order folio_viv folio entidad-jefe_edad alimentos_DIF-cat_Programas
	drop _merge
	compress
	save "$output/ENSANUT_2016_master.dta", replace
