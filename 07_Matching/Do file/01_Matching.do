/*******************************************************************************
		- Autor: Manuel Cardona
		- Propósito: Modelo de emparejamiento 
		- Datos: Mosquito bed nets programme
		- Windows
		- Stata 15.1 (Noviembre-2020)
*******************************************************************************/   	

set more off

*Globals: Estas rutas deberán ser modificadas, respecto al usuario.
 *Ej: global working "C:\Usuarios\Nombre\Dropbox\...\...\..."
 
global data "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\07_Matching\Data"
global dofile "C:\Users\Manuel Cardona Arias\Dropbox\CIDE\Lab Evaluación PP 2020\07_Matching\Do file"

		*************************************************
		**********Descripción del programa***************
		*************************************************

*Los velos para prevenir las picaduras de los mosquitos son una intervención muy
*popular para evitar la propagación de la malaria en distintos países africanos.
*En esta evaluación, pretendemos conocer el potencial efecto de los velos en una
*reducción del riesgo de contraer malaria. 

*Tenemos datos de 1,752 hogares sobre la entrega de los velos, así como algunas
*otras variables relacionadas al ambiente, a la salud de los individuos y a las 
*características del hogar.  

*Los datos NO SON EXPERIMENTALES. Los hogares tuvieron la decisión de pedir los
*velos de manera gratuita, de comprarlos y de usarlos, una vez adquiridos.

 import delimited "$data\mosquito_nets.csv", clear

*La base de datos contiene las siguientes variables:
	//malaria_risk: La probabilidad de que alguien en el hogar contraiga malaria.
	sum malaria_risk
	
	//net_num: Una variable dicotómica que indica si el hogar usó velo.
	fre net_num
	
	//eligible: Una variable dicotómica que indica si el hogar es elegible para
	//			recibir velo.
	fre eligible
	
	//income: Ingreso mensual del hogar en dólares US.
	sum income, det
	
	//temperature: La temperatura de noche del lugar donde se encuentra el hogar,
	//				medida en grados C.
	fre temperature
	
	//health: Estado de salud autorreportado por el jefe del hogar. Medido en una
	//		  escala del 0 al 100, donde mayores valores indican mejor salud.
	sum health, det
	
	//household: Número de miembros en el hogar.
	fre household
	
	//resistance: Resistencia a insecticidas de la cepa de mosquito predominante
	//			  en la zona donde se encuentra el hogar. Medido en una escala del
	//			  0 al 100, donde mayores valores indican mayor resistencia.
	sum resistance, det
	
*El objetivo es utilizar un algortimo de emparejamiento que nos permita encontrar
*clones que podamos comparar para encontrar el efecto del uso de los velos en el
*riesgo de contraer malaria en el hogar.


*Paso 1: Elaborar le probit con las variables que determinan la participación.
probit net_num income temperature health household resistance

	**Sólo incluímos las variables observables que sean significantes para D**
	global X "income temperature health household"
	probit net_num $X
	
*Paso 2: Predecir los valores de las probabilidades
predict pscore
sum pscore

*Paso 3: Restringir el soporte común
	**Por observación de distribuciones:
	histogram pscore, by(net_num)
	kdensity pscore if net_num==1, gen (x1 y1)
	kdensity pscore if net_num==0, gen (x0 y0)
	twoway (line y1 x1) (line y0 x0, lpattern(dash)), ytitle("Density") xtitle("psscore") legend(order(1 "Treatment" 2 "Control")) title("Propensity score")

	**Por mínimos y máximos:
	sum pscore if net_num==1
	scalar min_treat=r(min)
	display min_treat

	sum pscore if net_num==0
	scalar min_control=r(min)
	display min_control

	sum pscore if net_num==1
	scalar max_treat=r(max)
	display max_treat

	sum pscore if net_num==0
	scalar max_control=r(max)
	display max_control

	gen pscore_sc=pscore
	replace pscore_sc=. if pscore<min_treat
	replace pscore_sc=. if pscore>max_control

	count if pscore!=. & pscore_sc==.
	
kdensity pscore_sc if net_num==1, epanechnikov gen (x1_sc y1_sc)
kdensity pscore_sc if net_num==0, epanechnikov gen (x0_sc y0_sc)
twoway (line y1_sc x1_sc) (line y0_sc x0_sc, lpattern(dash)), ytitle("Density") xtitle("psscore") legend(order(1 "Treatment" 2 "Control")) title("Propensity score, SC")

*Paso 4: Comprobar que está bien emparejado
probit net_num pscore_sc $X

*Paso 5: Seleccionar el algoritmo de emparejamiento
	**Vecino más cercano:
	set seed 500844
	drawnorm orden
	sort orden

	psmatch2 net_num $X, outcome(malaria_risk) n(1) com

	***Sin remplazo:
	psmatch2 net_num $X, outcome(malaria_risk) n(1) com norepl

	***Con más vecinos:
	psmatch2 net_num $X, outcome(malaria_risk) n(10) com

	**Trimming:
	psmatch2 net_num $X, outcome(malaria_risk) n(1) trim(20)

	**Distancia máxima:
	psmatch2 net_num $X, outcome(malaria_risk) radius caliper(0.01) com 

	**Kernel:
	psmatch2 net_num $X, outcome(malaria_risk) kernel

	*Bootstrapping*
	bootstrap r(att): psmatch2 net_num $X, outcome(malaria_risk) com kernel
