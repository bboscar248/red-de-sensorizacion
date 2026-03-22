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

# PARÁMETRO NUMÉRICO
param path_flow {PATHS};


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
	# "capturamos el flujo del camino 'p' si y solo si este está sensorizado"
	sum {p in PATHS} path_flow[p] * y[p];
	

# ---------------
#  RESTRICCIONES 
# ---------------
# (r1): Como máximo 15 sensores en total.
subject to LimiteSensores: 
	sum {i in INTERSECTIONS} x[i] <= 15;


# (r2): En la solución debe contener todas las intersecciones que pertenecen a FIXED.
subject to InterseccionesObligatorias {i in FIXED}:
	x[i] = 1;
	


# (r3): En la solución no debe contener ninguna intersección que pertenezca a PROHIBITED.
subject to InterseccionesProhibidas{i in PROHIBITED}:
	x[i] = 0;	


# (r4): El flujo de un camino es capturado si hay al menos dos intersecciones sensorizadas.
subject to CaminoCapturado {p in PATHS}:
	# "buscamos en el conjunto 2D 'path_intersections' todos los pares que empiecen 
	#  por la ruta 'p'. Para esos pares, sumamos el valor del sensor en la intersección 'i'."
	sum {(p, i) in path_intersections} x[i] >= 2 * y[p];


# -------------
#  APARTADO b)
# -------------
# (r5): Que la distancia entre dos sensores sea mayor o igual de 300 metros
# "ponemos la condición 'i<j' porque se puede observar que en el archivo .dat existe una simetría entre cada pareja de intersecciones.
# Es decir, existe tanto (6 5) como (5 6). Por esta razón, lo añadimos para no hacer dos comprobaciones idénticas.
subject to DistanciaSeguridad{(i,j) in intersection_neighborhood: i < j}:
	x[i] + x[j] <= 1;




