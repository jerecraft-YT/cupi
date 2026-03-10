extends Polygon2D
class_name MetaballVisualizer

@export var poligono: Polygon2D
@export var metaball: Node2D
@export var spectro: Node2D
@export var line: Line2D
@export var distorsion: Line2D

# Configuración optimizada
@export_range(8, 64) var NUMERO_PUNTOS := 32  # Reducido por defecto
@export_range(1, 60) var TARGET_FPS := 30     # Limitar FPS

var update_accumulator := 0.0
var radio_base := 70.0
var ancho_pico := 100.0
var mitad_ancho_pico := 50.0

# Cache avanzado
var progreso_angular: float
var angulos_precalculados := []
var cos_precalculados := []
var sin_precalculados := []

# Picos optimizados - usar arrays simples en lugar de diccionarios
var picos_angulos := []    # En radianes directamente
var picos_amplitudes := []
var picos_pesos := []
var picos_mitad_ancho_rad: float

func _ready() -> void:
	_procesar_configuracion()
	_crear_linea()
	_inicializar_picos_predefinidos()

func _procesar_configuracion():
	"""Precalcula todo lo posible"""
	progreso_angular = TAU / NUMERO_PUNTOS
	picos_mitad_ancho_rad = deg_to_rad(mitad_ancho_pico)
	
	# Precalcular trigonometría
	angulos_precalculados.resize(NUMERO_PUNTOS)
	cos_precalculados.resize(NUMERO_PUNTOS)
	sin_precalculados.resize(NUMERO_PUNTOS)
	
	for i in NUMERO_PUNTOS:
		var angulo = i * progreso_angular
		angulos_precalculados[i] = angulo
		cos_precalculados[i] = cos(angulo)
		sin_precalculados[i] = sin(angulo)

func _inicializar_picos_predefinidos():
	"""Inicializa picos con datos predefinidos - en radianes directamente"""
	var picos_grados = [0.0, 45.0, 90.0, 135.0, 180.0, 215.0, 270.0, 315.0]
	var pesos = [0.04, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.01]
	
	for i in picos_grados.size():
		agregar_pico(picos_grados[i], 0.0, pesos[i])

func _crear_linea():
	"""Inicializa las líneas con capacidad predefinida"""
	line.clear_points()
	distorsion.clear_points()
	
	for i in NUMERO_PUNTOS:
		line.add_point(Vector2.ZERO)
		distorsion.add_point(Vector2.ZERO)

func _process(delta: float) -> void:
	# Limitar FPS para Android
	update_accumulator += delta
	if update_accumulator < (1.0 / TARGET_FPS):
		return
	
	update_accumulator = 0.0
	
	# Animación básica
	#poligono.rotation += 0.01 * DataGame.time_fixed
	
	# Actualizar y renderizar
	_actualizar_amplitudes_desde_espectro()
	_animar_circulo()
	_actualizar_linea()

func _animar_circulo():
	"""Versión ALTAMENTE optimizada usando cache completo"""
	var puntos_poligono = PackedVector2Array()
	puntos_poligono.resize(NUMERO_PUNTOS)
	
	for i in NUMERO_PUNTOS:
		var amplitud_extra = _calcular_amplitud_extra_optimizada(i)
		var radio_final = radio_base + amplitud_extra
		
		puntos_poligono[i] = Vector2(
			cos_precalculados[i] * radio_final, 
			sin_precalculados[i] * radio_final
		)
	
	poligono.polygon = puntos_poligono

func _calcular_amplitud_extra_optimizada(indice_punto: int) -> float:
	"""Versión ultra-optimizada usando ángulos precalculados"""
	var amplitud_extra := 0.0
	var angulo_actual = angulos_precalculados[indice_punto]
	
	for j in picos_angulos.size():
		var distancia_angular = _calcular_distancia_angular_rad(angulo_actual, picos_angulos[j])
		
		if distancia_angular <= picos_mitad_ancho_rad:
			var factor_influencia = 1.0 - (distancia_angular / picos_mitad_ancho_rad)
			amplitud_extra += _aplicar_suavizado(factor_influencia) * picos_amplitudes[j] * picos_pesos[j]
	
	return amplitud_extra

func _calcular_distancia_angular_rad(angulo_a: float, angulo_b: float) -> float:
	"""Calcula distancia angular en radianes - MÁS RÁPIDO"""
	var diferencia = abs(angulo_a - angulo_b)
	return min(diferencia, TAU - diferencia)

func _aplicar_suavizado(factor: float) -> float:
	"""smoothstep optimizado - sin clamp si sabemos que está en rango"""
	return factor * factor * (3.0 - 2.0 * factor)

func _actualizar_amplitudes_desde_espectro():
	"""Actualización optimizada sin comprobaciones redundantes"""
	var max_values = spectro.max_values
	var num_picos = picos_angulos.size()
	
	for i in num_picos:
		if i + 1 < max_values.size():
			picos_amplitudes[i] = max_values[i + 1]

func _actualizar_linea():
	"""Actualización directa sin bucles redundantes"""
	var puntos_poligono = poligono.polygon
	
	for i in NUMERO_PUNTOS:
		line.set_point_position(i, puntos_poligono[i])
		distorsion.set_point_position(i, puntos_poligono[i])

# ==== INTERFAZ PÚBLICA OPTIMIZADA ====

func agregar_pico(angulo_grados: float, amplitud: float, peso_amplitud: float = 0.05):
	picos_angulos.append(deg_to_rad(angulo_grados))
	picos_amplitudes.append(amplitud)
	picos_pesos.append(peso_amplitud)

func establecer_angulo_pico(indice: int, nuevo_angulo_grados: float):
	if indice < picos_angulos.size():
		picos_angulos[indice] = deg_to_rad(nuevo_angulo_grados)

func obtener_angulo_pico(indice: int) -> float:
	return rad_to_deg(picos_angulos[indice]) if indice < picos_angulos.size() else 0.0

# ... resto de funciones similares optimizadas
