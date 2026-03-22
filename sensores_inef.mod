# -----------------------------
#  INICIALIZACIÓN DE LOS DATOS
# -----------------------------
# CONJUNTOS
set PATHS;
set INTERSECTIONS;

# SUBCONJUNTOS
set FIXED within INTERSECTIONS;
set PROHIBITED within INTERSECTIONS;
set path_intersections dimen 2;
set intersection_neighborhood dimen 2;

# PARÁMETROS
param path_flow {PATHS};

param obligatorio {i in INTERSECTIONS} binary = 
    if i in FIXED then 1 else 0;

param prohibido {i in INTERSECTIONS} binary = 
    if i in PROHIBITED then 1 else 0;

param pertenece {i in INTERSECTIONS, j in PATHS} binary = 
    if (j, i) in path_intersections then 1 else 0;
    #es (j, i) y no (i, j) porque viene dado como (PATHS, INTERSECTION)

param vecino {i in INTERSECTIONS, j in INTERSECTIONS} binary = 
    if (i, j) in intersection_neighborhood then 1 else 0;



# -----------------------
#  VARIABLES DE DECISIÓN 
# -----------------------
# VAR1: 1 si la intersección 'i' tiene sensor, 0 si no
var x {INTERSECTIONS} binary;

# VAR2: 1 si el camino 'p' está sensorizado (tiene al menos 2 sensores), 0 si no
var y {PATHS} binary;


# ------------------
#  FUNCIÓN OBJETIVO
# ------------------
maximize FlujoCapturado:
	# "capturamos el flujo del camino 'j' si y solo si este está sensorizado"
	sum {j in PATHS} path_flow[j] * y[j];
	

# ---------------
#  RESTRICCIONES 
# ---------------
# (r1): Como máximo 15 sensores en total.
subject to LimiteSensores: 
	sum {i in INTERSECTIONS} x[i] <= 15;


# (r2): En la solución debe contener todas las intersecciones que pertenecen a FIXED.
subject to InterseccionesObligatorias:
	sum {i in INTERSECTIONS} x[i]*obligatorio[i] = card(FIXED);



# (r3): En la solución no debe contener ninguna intersección que pertenezca a PROHIBITED.
subject to InterseccionsProhibidas:
	sum {i in INTERSECTIONS} x[i]*prohibido[i] = 0;
	


# (r4): El flujo de un camino es capturado si hay al menos dos intersecciones sensorizados .
subject to CaminoCapturado{j in PATHS}:
	# "para todas las intersecciones 'i' que pertenecen al camino 'j', hacemos el sumatorio de los sensores instalados
	#  y si la suma es mayor o igual a 2, entonces indicamos que el camino 'j' está sensorizado"
	sum {i in INTERSECTIONS} x[i]*pertenece[i,j] >= 2*y[j];



# -------------
#  APARTADO b)
# -------------
# (r5): Que la distancia entre dos sensores sea mayor o igual de 300 metros
# "ponemos la condición 'i<j' porque se puede observar que en el archivo .dat existe una simetría entre cada pareja de intersecciones.
# Es decir, existe tanto (6 5) como (5 6). Por esta razón, lo añadimos para no hacer dos comprobaciones idénticas.
subject to DistanciaSeguridad{i in INTERSECTIONS, j in INTERSECTIONS: vecino[i,j] == 1}:
	x[i] + x[j] <= 1;
	
	
	
	
	
	