extends Node2D
class_name CupiSpiral

# --------------------------------------------------------
# NODOS
# --------------------------------------------------------
@export var line: Line2D

@onready var bulletStart: Node2D = $startNote
@onready var bulletFinal: Node2D = $FinalNote
@onready var cupi: Node2D = get_tree().get_first_node_in_group("cupi")
@onready var spawner: Node2D = get_tree().get_first_node_in_group("bulletSpawner")

# --------------------------------------------------------
# VARIABLES DE CONFIGURACIÓN (TIPADAS)
# --------------------------------------------------------
@export var anguloFinal: float = 0.0
@export var ampStart: float = 0.0
@export var ampFinal: float = 0.0
@export var AngleStart: float = 0.0
@export var AngleFinal: float = 0.0
@export var calc: float = 1.0
@export var angleRef: float = 0.0
@export var progresoSpiral: float = 0.0
@export var segmentos:int = 7  # Nueva variable para controlar segmentos base
@export var minPoints:int = 24
@export var maxPoints:int = 1024

var easing_functions = [
	"linear",         # 0
	"easeInSine",     # 1
	"easeOutSine",    # 2
	"easeInOutSine",  # 3
	"easeInCubic",    # 4
	"easeOutCubic",   # 5
	"easeInOutCubic", # 6
	"easeInQuint",    # 7
	"easeOutQuint",   # 8
	"easeInOutQuint", # 9
	"easeInCirc",     # 10
	"easeOutCirc",    # 11
	"easeInOutCirc",  # 12
	"easeInElastic",  # 13
	"easeOutElastic", # 14
	"easeInOutElastic", # 15
	"easeInQuad",     # 16
	"easeOutQuad",    # 17
	"easeInOutQuad",  # 18
	"easeInBack",     # 19
	"easeOutBack",    # 20
	"easeInOutBack",  # 21
	"easeInBounce",   # 22
	"easeOutBounce",  # 23
	"easeInOutBounce" # 24
]

@export var idFuncion = 0

# --------------------------------------------------------
# PROCESS
# --------------------------------------------------------
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	ampFinal = bulletFinal.ampSpiral
	ampStart = bulletStart.ampSpiral

	createcircle()
	calcAngle()

	# condición de eliminación
	if bulletFinal.timeLerp <= 0:
		queue_free()
	#print(line.get_point_count())

# --------------------------------------------------------
# OBTENER CALC
# --------------------------------------------------------
func getCalc() -> float:
	calc = (bulletFinal.ampSpiral - bulletStart.ampSpiral)
	return calc

# --------------------------------------------------------
# CÁLCULO DE ÁNGULO GLOBAL (EASING APLICADO UNA VEZ)
# --------------------------------------------------------
func calcAngle() -> void:
	angleRef = AngleStart - AngleFinal 

	var ampStartSpiral: float = bulletStart.ampSpiral
	var ampFinalSpiral: float = bulletFinal.ampSpiral

	if calc == 0.0:
		return

	progresoSpiral = (ampFinalSpiral - ampStartSpiral) / calc
	progresoSpiral = clamp(progresoSpiral, 0.0, 1.0)

	var eased_global: float = progress(progresoSpiral, idFuncion)
	anguloFinal = angleRef * eased_global

# --------------------------------------------------------
# CALCULO DE PROGRESO
# --------------------------------------------------------
func progress(time, idFunction):
	return DataGame.call(easing_functions[idFunction], time)

# --------------------------------------------------------
# CREACIÓN DE LA CURVA DE PUNTOS CON DENSIDAD VARIABLE
# --------------------------------------------------------
func createcircle() -> void:
	var ampStartSpiral: float = bulletStart.ampSpiral
	var ampFinalSpiral: float = bulletFinal.ampSpiral

	# fase global para sincronizar easing
	var progress_global: float = (ampFinalSpiral - ampStartSpiral) / calc
	progress_global = clamp(progress_global, 0.0, 1.0)

	# PRE: evitar NaN
	if calc == 0.0:
		return

	# Limpiar puntos existentes
	line.clear_points()

	# Sistema de densidad variable adaptado
	var paso = 1.0 / segmentos
	var prevPaso: float = 0.0
	var prevY = progress(progress_global * prevPaso, idFuncion)
	
	# Punto inicial
	var initial_point = calculate_spiral_point(prevPaso, prevY)
	line.add_point(initial_point)
	
	# Generar puntos con densidad variable
	for i in segmentos:
		var pasoActual = paso * (i + 1)
		var yActual = progress(progress_global * pasoActual, idFuncion)
		var diferencia = abs(yActual - prevY)
		
		# Lógica de densidad: menos diferencia = más puntos
		minPoints = abs(int(angleRef/segmentos))
		#print(minPoints)
		var puntosUsar = min(maxPoints,max(minPoints, segmentos - int(diferencia * segmentos)))
		
		# Puntos intermedios
		for j in range(1, puntosUsar):
			var factor = float(j) / puntosUsar
			var t = prevPaso + (pasoActual - prevPaso) * factor
			var y = progress(progress_global * t, idFuncion)
			var point = calculate_spiral_point(t, y)
			line.add_point(point)
		
		# Punto final del segmento
		var final_point = calculate_spiral_point(pasoActual, yActual)
		line.add_point(final_point)
		
		prevPaso = pasoActual
		prevY = yActual

# --------------------------------------------------------
# CALCULAR PUNTO DE LA ESPIRAL
# --------------------------------------------------------
func calculate_spiral_point(t: float, eased_value: float) -> Vector2:
	# Ángulo interpolado con las oscilaciones del easing
	var angle_t: float = eased_value * angleRef
	var angle_offset_rad: float = deg_to_rad(AngleFinal)
	var actual_angle_rad: float = deg_to_rad(angle_t) + angle_offset_rad

	# Interpolación de amplitud
	var pasAmp: float = bulletStart.amp - bulletFinal.amp
	var actual_amp: float = bulletFinal.amp + pasAmp * t

	return Vector2(
		cos(actual_angle_rad) * actual_amp,
		sin(actual_angle_rad) * actual_amp
	)
