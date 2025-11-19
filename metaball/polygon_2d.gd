extends Polygon2D

@onready var poligono = $"."
var numeroPuntos = 64
var time: float = 0.0
var amp_base = 70
@onready var metaball = get_parent()
@onready var spectro = get_tree().get_first_node_in_group("spectro")
@onready var line = $Line2D
var picos = [
	{"angulo": 0.0, "amplitud": 0.0},
	{"angulo": 45.0, "amplitud": 0.0},
	{"angulo": 90.0, "amplitud": 0.0},
	{"angulo": 135.0, "amplitud": 0.0},
	{"angulo": 180.0, "amplitud": 0.0},
	{"angulo": 215.0, "amplitud": 0.0},
	{"angulo": 270.0, "amplitud": 0.0},
	{"angulo": 315.0, "amplitud": 0.0}
]
var ancho_pico = 100.0
var tipo_suavizado = 2

func createLine():
	for i in range(numeroPuntos):
		line.add_point(Vector2.ONE,-1)

func move_line():
	for i in range(numeroPuntos):
		line.set_point_position(i,poligono.polygon[i])

func _ready() -> void:
	createLine()

func _animateCircle():
	var puntos = PackedVector2Array()
	var progress = TAU / numeroPuntos
	
	for i in range(numeroPuntos):
		var angulo = i * progress
		var angulo_grados = rad_to_deg(angulo)
		var amplitud_extra = 0.0
		
		for pico in picos:
			var pos_grados = pico["angulo"]
			var amplitud = pico["amplitud"]
			
			# CORRECCIÓN: Cálculo mejorado de distancia angular
			var distancia = _calcularDistanciaAngular(angulo_grados, pos_grados)
			
			if distancia <= ancho_pico / 2.0:
				var factor = 1.0 - (distancia / (ancho_pico / 2.0))
				amplitud_extra += _aplicarSuavizado(factor) * amplitud
		
		var radio = amp_base + amplitud_extra
		puntos.append(Vector2(cos(angulo) * radio, sin(angulo) * radio))
	
	poligono.polygon = puntos

# NUEVA FUNCIÓN: Cálculo robusto de distancia angular
func _calcularDistanciaAngular(a: float, b: float) -> float:
	var diff = abs(a - b)
	return min(diff, 360.0 - diff)

func _aplicarSuavizado(factor: float) -> float:
	match tipo_suavizado:
		1: return sin(factor * PI * 0.5)
		2: return smoothstep(0.0, 1.0, factor)
		3: return factor * factor
		4: return 1.0 - pow(1.0 - factor, 3.0)
		5: 
			if factor < 0.5:
				return 4.0 * factor * factor * factor
			else:
				return 1.0 - pow(-2.0 * factor + 2.0, 3.0) / 2.0
		_: return factor

func smoothstep(edge0: float, edge1: float, x: float) -> float:
	var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _process(delta: float) -> void:
	metaball.rotation += 0.01 * DataGame.time_fixed
	time += delta
	_animateCircle()
	setAmplitudPico(0, spectro.max_values[1]*0.04)
	setAmplitudPico(1, spectro.max_values[2]*0.05)
	setAmplitudPico(2, spectro.max_values[3]*0.05)
	setAmplitudPico(3, spectro.max_values[4]*0.05)
	setAmplitudPico(4, spectro.max_values[5]*0.05)
	setAmplitudPico(5, spectro.max_values[6]*0.05)
	setAmplitudPico(6, spectro.max_values[7]*0.05)
	setAmplitudPico(7, spectro.max_values[8]*0.1)
	move_line()
	
# ===== FUNCIONES PARA MODIFICAR ÁNGULOS DE PICOS =====

func setAnguloPico(indice: int, nuevo_angulo: float):
	if indice >= 0 and indice < picos.size():
		picos[indice]["angulo"] = _normalizarAngulo(nuevo_angulo)

func getAnguloPico(indice: int) -> float:
	if indice >= 0 and indice < picos.size():
		return picos[indice]["angulo"]
	return 0.0

func moverPico(indice: int, incremento_grados: float):
	if indice >= 0 and indice < picos.size():
		picos[indice]["angulo"] = _normalizarAngulo(picos[indice]["angulo"] + incremento_grados)

func setAmplitudPico(indice: int, nueva_amplitud: float):
	if indice >= 0 and indice < picos.size():
		picos[indice]["amplitud"] = nueva_amplitud

func agregarPico(angulo: float, amplitud: float):
	picos.append({"angulo": _normalizarAngulo(angulo), "amplitud": amplitud})

func eliminarPico(indice: int):
	if indice >= 0 and indice < picos.size():
		picos.remove_at(indice)

func getPico(indice: int) -> Dictionary:
	if indice >= 0 and indice < picos.size():
		return picos[indice].duplicate()
	return {}

func rotarTodosLosPicos(incremento_grados: float):
	for pico in picos:
		pico["angulo"] = _normalizarAngulo(pico["angulo"] + incremento_grados)

func setAnchoPicos(nuevo_ancho: float):
	ancho_pico = nuevo_ancho

func setTipoSuavizado(tipo: int):
	tipo_suavizado = tipo

# NUEVA FUNCIÓN: Normalizar ángulo a rango [0, 360)
func _normalizarAngulo(angulo: float) -> float:
	var normalizado = fmod(angulo, 360.0)
	if normalizado < 0:
		normalizado += 360.0
	return normalizado
