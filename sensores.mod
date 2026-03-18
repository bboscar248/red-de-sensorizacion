# CONJUNTOS
set PATHS;
set INTERSECTIONS;

# SUBCONJUNTOS
set FIXED within INTERSECTIONS;
set PROHIBITED within INTERSECTIONS;

# Le indicamos a AMPL que estos conjuntos tienen 2 columnas (dimensión 2)
set path_intersections dimen 2;
set intersection_neighborhood dimen 2;


# PARÁMETROS
# parámetro numérico 
param path_flow {PATHS};

param obligatorio {i in INTERSECTIONS} binary = 
    if i in FIXED then 1 else 0;

param prohibido {i in INTERSECTIONS} binary = 
    if i in PROHIBITED then 1 else 0;

param pertenece {i in INTERSECTIONS, j in PATHS} binary = 
    if (j, i) in path_intersections then 1 else 0;
    #es (j, i) y no (i, j) porque viene dado como (PATHS, INTERSECTION)

#param vecino {i in INTERSECTIONS, j in INTERSECTIONS} binary = 
#    if (i, j) in intersection_neighborhood then 1 else 0;



#variables de decisión
# var1: 1 si la intersección 'i' tiene sensor, 0 si no
var x {INTERSECTIONS} binary;

# var2: 1 si el camino 'j' está sensorizado (tiene al menos 2 sensores), 0 si no
var y {PATHS} binary;


#función objetivo
maximize FlujoCapturado:
sum {j in PATHS} path_flow[j] * y[j];



#restricciones
#(r1) Como máximo 15 sensores en total.
subject to LimiteSensores: 
	sum {i in INTERSECTIONS} x[i] <= 15;


#(r2) En la solución debe contener todas las intersecciones que pertenecen a fixed.
subject to InterseccionesObligatorias:
	sum {i in INTERSECTIONS} x[i]*obligatorio[i] = card(FIXED);


#(r3) En la solución no debe contener ninguna intersección que pertenezca a prohibited.
subject to InterseccionsProhibidas:
	sum {i in INTERSECTIONS} x[i]*prohibido[i] = 0;


#(r4) El flujo de un camino es capturado si dos de sus intersecciones tiene sensor.
subject to CaminoCapturado{j in PATHS}:
	sum {i in INTERSECTIONS} x[i]*pertenece[i,j] >= 2*y[j];


#para el apartado b)
#(r5) Que la distancia entre dos sensores sea mayor o igual de 300 metros
#subject to DistanciaSeguridad{(i,j) in intersection_neighbourhood}:
#	x[i] + x[j] <= 1;