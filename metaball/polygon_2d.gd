extends Polygon2D

@export var poligono:Polygon2D
@export var metaball:Node2D
@export var spectro:Node2D
@export var line:Line2D

# Configuración básica
@export var NUMERO_PUNTOS := 48
var tiempo: float = 0.0
var radio_base := 70.0
var ancho_pico := 100.0
var mitad_ancho_pico := ancho_pico / 2.0

# Cache de cálculos
var progreso_angular := TAU / NUMERO_PUNTOS
var factores_suavizados := []

# Definición de los picos del polígono
var picos = [
	{"angulo": 0.0, "amplitud": 0.0, "peso_amplitud": 0.04},
	{"angulo": 45.0, "amplitud": 0.0, "peso_amplitud": 0.05},
	{"angulo": 90.0, "amplitud": 0.0, "peso_amplitud": 0.05},
	{"angulo": 135.0, "amplitud": 0.0, "peso_amplitud": 0.05},
	{"angulo": 180.0, "amplitud": 0.0, "peso_amplitud": 0.05},
	{"angulo": 215.0, "amplitud": 0.0, "peso_amplitud": 0.05},
	{"angulo": 270.0, "amplitud": 0.0, "peso_amplitud": 0.05},
	{"angulo": 315.0, "amplitud": 0.0, "peso_amplitud": 0.01}
]

# Precálculo de ángulos en radianes
var picos_radianes := []

func _ready() -> void:
	_crear_linea()
	_actualizar_cache_picos()

func _crear_linea():
	"""Inicializa la línea con puntos vacíos"""
	line.clear_points()
	for i in NUMERO_PUNTOS:
		line.add_point(Vector2.ZERO)

func _actualizar_cache_picos():
	"""Precalcula los ángulos en radianes para evitar conversiones en tiempo real"""
	picos_radianes.clear()
	for pico in picos:
		picos_radianes.append(deg_to_rad(pico["angulo"]))

func _actualizar_linea():
	"""Actualiza las posiciones de la línea con los puntos del polígono - OPTIMIZADO"""
	var puntos_poligono = poligono.polygon
	for i in NUMERO_PUNTOS:
		line.set_point_position(i, puntos_poligono[i])

func _animar_circulo():
	"""Genera la forma del polígono basado en los picos definidos - OPTIMIZADO"""
	var puntos_poligono = PackedVector2Array()
	puntos_poligono.resize(NUMERO_PUNTOS)
	
	for i in NUMERO_PUNTOS:
		var angulo_actual = i * progreso_angular
		var amplitud_extra = _calcular_amplitud_extra(angulo_actual)
		var radio_final = radio_base + amplitud_extra
		
		puntos_poligono[i] = Vector2(cos(angulo_actual) * radio_final, sin(angulo_actual) * radio_final)
	
	poligono.polygon = puntos_poligono

func _calcular_amplitud_extra(angulo_rad: float) -> float:
	"""Calcula la amplitud extra de todos los picos en un ángulo específico"""
	var amplitud_extra := 0.0
	var angulo_grados = rad_to_deg(angulo_rad)
	
	for j in picos.size():
		var pico = picos[j]
		var distancia_angular = _calcular_distancia_angular(angulo_grados, pico["angulo"])
		
		if distancia_angular <= mitad_ancho_pico:
			var factor_influencia = 1.0 - (distancia_angular / mitad_ancho_pico)
			amplitud_extra += _aplicar_suavizado(factor_influencia) * pico["amplitud"]
	
	return amplitud_extra

func _calcular_distancia_angular(angulo_a: float, angulo_b: float) -> float:
	"""Calcula la distancia angular más corta entre dos ángulos - OPTIMIZADO"""
	var diferencia = abs(angulo_a - angulo_b)
	return min(diferencia, 360.0 - diferencia)

func _aplicar_suavizado(factor: float) -> float:
	"""Aplica interpolación suave al factor de influencia - OPTIMIZADO"""
	# smoothstep optimizado: t * t * (3.0 - 2.0 * t)
	var t = clamp(factor, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _normalizar_angulo(angulo: float) -> float:
	"""Normaliza un ángulo al rango [0, 360) grados - OPTIMIZADO"""
	var normalizado = fmod(angulo, 360.0)
	return normalizado + 360.0 if normalizado < 0 else normalizado

func _process(delta: float) -> void:
	# Animación continua
	poligono.rotation += 0.01 * DataGame.time_fixed
	tiempo += delta
	
	# Actualizar amplitudes desde el espectro - OPTIMIZADO
	_actualizar_amplitudes_desde_espectro()
	
	_animar_circulo()
	_actualizar_linea()

func _actualizar_amplitudes_desde_espectro():
	"""Actualiza las amplitudes de todos los picos desde el espectro"""
	var max_values = spectro.max_values
	for i in picos.size():
		picos[i]["amplitud"] = max_values[i + 1] * picos[i]["peso_amplitud"]

# ==== INTERFAZ PÚBLICA PARA MANIPULAR PICOS ====

func establecer_angulo_pico(indice: int, nuevo_angulo: float):
	if indice >= 0 and indice < picos.size():
		picos[indice]["angulo"] = _normalizar_angulo(nuevo_angulo)
		_actualizar_cache_picos()

func obtener_angulo_pico(indice: int) -> float:
	return picos[indice]["angulo"] if indice >= 0 and indice < picos.size() else 0.0

func mover_pico(indice: int, incremento_grados: float):
	if indice >= 0 and indice < picos.size():
		picos[indice]["angulo"] = _normalizar_angulo(picos[indice]["angulo"] + incremento_grados)
		_actualizar_cache_picos()

func establecer_amplitud_pico(indice: int, nueva_amplitud: float):
	if indice >= 0 and indice < picos.size():
		picos[indice]["amplitud"] = nueva_amplitud

func agregar_pico(angulo: float, amplitud: float, peso_amplitud: float = 0.05):
	picos.append({
		"angulo": _normalizar_angulo(angulo), 
		"amplitud": amplitud, 
		"peso_amplitud": peso_amplitud
	})
	_actualizar_cache_picos()

func eliminar_pico(indice: int):
	if indice >= 0 and indice < picos.size():
		picos.remove_at(indice)
		_actualizar_cache_picos()

func obtener_pico(indice: int) -> Dictionary:
	return picos[indice].duplicate() if indice >= 0 and indice < picos.size() else {}

func rotar_todos_los_picos(incremento_grados: float):
	for pico in picos:
		pico["angulo"] = _normalizar_angulo(pico["angulo"] + incremento_grados)
	_actualizar_cache_picos()

func establecer_ancho_picos(nuevo_ancho: float):
	ancho_pico = nuevo_ancho
	mitad_ancho_pico = nuevo_ancho / 2.0
