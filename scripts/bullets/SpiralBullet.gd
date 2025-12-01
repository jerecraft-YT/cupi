extends Node2D
class_name CupiSpiral

# NODOS
@export var line: Line2D
@onready var bulletStart: Node2D = $startNote
@onready var bulletFinal: Node2D = $FinalNote
@onready var cupi: Node2D = get_tree().get_first_node_in_group("cupi")
@onready var spawner: Node2D = get_tree().get_first_node_in_group("bulletSpawner")

# CONFIG
@export var anguloFinal: float = 0.0
@export var ampStart: float = 0.0
@export var ampFinal: float = 0.0
@export var AngleStart: float = 0.0
@export var AngleFinal: float = 0.0
@export var calc: float = 1.0
@export var angleRef: float = 0.0
@export var progresoSpiral: float = 0.0

# Control de resolución / densidad
@export var segmentos:int = 5
@export var minPoints:int = 8
@export var maxPoints:int = 32  # valor por defecto más conservador
@export var update_interval: float = 0.020  # segundos entre actualizaciones (throttle)

# Easing: nombres (se asume que DataGame es un singleton con esas funciones)
var easing_functions = [
	"linear","easeInSine","easeOutSine","easeInOutSine","easeInCubic","easeOutCubic",
	"easeInOutCubic","easeInQuint","easeOutQuint","easeInOutQuint","easeInCirc","easeOutCirc",
	"easeInOutCirc","easeInElastic","easeOutElastic","easeInOutElastic","easeInQuad","easeOutQuad",
	"easeInOutQuad","easeInBack","easeOutBack","easeInOutBack","easeInBounce","easeOutBounce",
	"easeInOutBounce"
]
@export var idFuncion = 0

# Estado interno
var _time_accum: float = 0.0
var _easing_callables: Array = []

func _ready() -> void:
	# Crear callables para evitar call() por string dentro de bucles
	_easing_callables.clear()
	for nameFunc in easing_functions:
		# Si DataGame está presente como Autoload, esto crea el Callable; si no, guarda null
		if Engine.has_singleton("DataGame") or has_node("/root/DataGame"):
			_easing_callables.append(Callable(DataGame, nameFunc))
		else:
			_easing_callables.append(null)

func _process(delta: float) -> void:
	ampFinal = bulletFinal.ampSpiral
	ampStart = bulletStart.ampSpiral

	_time_accum += delta
	if _time_accum >= update_interval:
		_time_accum = 0.0
		createcircle()
		calcAngle()

	# condición de eliminación
	if bulletFinal.timeLerp <= 0:
		queue_free()

# Llamada a easing de forma segura y rápida
func _easing_eval(t: float, idFunc: int) -> float:
	if idFunc < 0 or idFunc >= _easing_callables.size():
		return t
	var c = _easing_callables[idFunc]
	if c and c.is_valid():
		return c.call(t)
	# Fallback simple si no existe DataGame
	return t

func getCalc() -> float:
	calc = (bulletFinal.ampSpiral - bulletStart.ampSpiral)
	return calc

func calcAngle() -> void:
	angleRef = AngleStart - AngleFinal

	var ampStartSpiral: float = bulletStart.ampSpiral
	var ampFinalSpiral: float = bulletFinal.ampSpiral

	if calc == 0.0:
		return

	progresoSpiral = (ampFinalSpiral - ampStartSpiral) / calc
	progresoSpiral = clamp(progresoSpiral, 0.0, 1.0)

	var eased_global: float = _easing_eval(progresoSpiral, idFuncion)
	anguloFinal = angleRef * eased_global

func createcircle() -> void:
	var ampStartSpiral: float = bulletStart.ampSpiral
	var ampFinalSpiral: float = bulletFinal.ampSpiral

	if calc == 0.0:
		return

	# Preparar array de puntos y usar una sola asignación al Line2D
	var points := PackedVector2Array()
	points.resize(0)

	# sistema de densidad variable adaptado
	var paso = 1.0 / float(segmentos)
	var prevPaso: float = 0.0
	var progress_global: float = (ampFinalSpiral - ampStartSpiral) / calc
	progress_global = clamp(progress_global, 0.0, 1.0)
	var prevY = _easing_eval(progress_global * prevPaso, idFuncion)

	# punto inicial
	points.append(calculate_spiral_point(prevPaso, prevY))

	# generar segmentos
	var local_angleRef = angleRef

	for i in range(segmentos):
		var pasoActual = paso * float(i + 1)
		var yActual = _easing_eval(progress_global * pasoActual, idFuncion)
		var diferencia = abs(yActual - prevY)

		# Lógica de densidad: menor diferencia => más puntos (suavizada)
		var estimated_min = max(3, int(abs(local_angleRef) / max(1, segmentos)))
		var puntosUsar = clamp(int(lerp(float(estimated_min), float(maxPoints), 1.0 - diferencia)), estimated_min, maxPoints)

		# Limitar puntos efectivamente para no saturar móvil
		@warning_ignore("integer_division")
		puntosUsar = min(puntosUsar, max(4, int(maxPoints / 2)))

		# puntos intermedios
		for j in range(1, puntosUsar):
			var factor = float(j) / float(puntosUsar)
			var t = prevPaso + (pasoActual - prevPaso) * factor
			var y = _easing_eval(progress_global * t, idFuncion)
			points.append(calculate_spiral_point(t, y))

		# punto final del segmento
		points.append(calculate_spiral_point(pasoActual, yActual))

		prevPaso = pasoActual
		prevY = yActual

	# asignar todo de golpe
	line.points = points

func calculate_spiral_point(t: float, eased_value: float) -> Vector2:
	var angle_t: float = eased_value * angleRef
	var actual_angle_rad: float = deg_to_rad(angle_t) + deg_to_rad(AngleFinal)

	var pasAmp: float = bulletStart.amp - bulletFinal.amp
	var actual_amp: float = bulletFinal.amp + pasAmp * t

	return Vector2(cos(actual_angle_rad) * actual_amp, sin(actual_angle_rad) * actual_amp)
