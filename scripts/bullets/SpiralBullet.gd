extends Node2D

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
	angleRef = AngleStart-AngleFinal 

	var ampStartSpiral: float = bulletStart.ampSpiral
	var ampFinalSpiral: float = bulletFinal.ampSpiral

	if calc == 0.0:
		return

	progresoSpiral = (ampFinalSpiral - ampStartSpiral) / calc
	progresoSpiral = clamp(progresoSpiral, 0.0, 1.0)

	# easing global
	#var eased_global: float = DataGame._easeOutElastic(progresoSpiral)
	var eased_global:float = progress(progresoSpiral,idFuncion)
	anguloFinal = angleRef * eased_global

# --------------------------------------------------------
# CALCULO DE PROGRESO
# --------------------------------------------------------
func progress(time,idFunction):
	return DataGame.call(easing_functions[idFunction], time)

# --------------------------------------------------------
# CREACIÓN DE LA CURVA DE PUNTOS
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

	# cantidad de puntos
	var number_points: int = 1 + abs(int(anguloFinal)) + int(calc /256)
	#print(number_points)
	var needed_points: int = number_points + 1
	var current_points: int = line.get_point_count()

	# ajustar número de puntos solo si cambia
	if needed_points != current_points:
		if needed_points > current_points:
			for i in range(needed_points - current_points):
				line.add_point(Vector2.ZERO)
		else:
			for i in range(current_points - needed_points):
				line.remove_point(line.get_point_count() - 1)

	# precálculos
	var pasAmp: float = bulletStart.amp - bulletFinal.amp
	var angle_offset_rad: float = deg_to_rad(AngleFinal)

	# LOOP PRINCIPAL
	for i in range(needed_points):
		var t: float = float(i) / number_points

		# easing local sincronizado con la fase global
		#var eased_local: float = DataGame._easeOutElastic(progress_global * t)
		var eased_local:float = progress(progress_global*t,idFuncion)
		# ángulo interpolado con las oscilaciones del easing
		var angle_t: float = eased_local * angleRef
		var actual_angle_rad: float = deg_to_rad(angle_t) + angle_offset_rad

		# interpolación de amplitud
		var actual_amp: float = bulletFinal.amp + pasAmp * t

		# actualizar punto
		line.set_point_position(
			i,
			Vector2(
				cos(actual_angle_rad) * actual_amp,
				sin(actual_angle_rad) * actual_amp
			)
		)
