@tool
class_name textDraw extends Node2D
var variablesElement:Array

@export_group("General")
@export var textToDraw:String:
	set(v):
		if textToDraw == v:
			return
		textToDraw = v
		longitudText = textToDraw.length()
		stringSize = fuente.get_string_size(textToDraw,HORIZONTAL_ALIGNMENT_LEFT,-1,fontSize)
		updateChartsDataPacked()
		recalcChartsData()
	get:
		return textToDraw
		
@export var BaseColor:Color = Color(1.0, 1.0, 1.0, 1.0) ##Activo cuando el efecto RGB no lo esta
@export var fuente:Font = load("res://testeos/font.tres")
@export var fontSize:int = 32:
	set(v):
		if fontSize == v:
			return
		fontSize = v
		recalcChartsData()
	get:
		return fontSize
		
@export var TextSeparation:float
@export var RotationChart:float
enum AnchorText {LEFT,CENTER,RIGHT}
@export_enum("LEFT","CENTER","RIGHT") var anchorText:int
@export_range(0.0,5.0) var chartScales:PackedFloat32Array:
	set(v):
		if chartScales == v:
			return
		chartScales = v
		recalcChartsData()
	get:
		return chartScales
@export var chartsOffset:PackedVector2Array

@export_group("Efectos")

@export_subgroup("Tornado")
@export var TornadoActive:bool = false
@export var amp:float = 10.0
@export var multiplierTime:float = 6.0
@export var offsetRotationPerChart:float = 5.0 ##
@export var rotationPerChartActive:bool = true ## RPC = Rotation per Chart
@export_range(-90.0,90.0) var FactorRPC:float = 5.0
@export var startTornado:int = 0
@export var finalTornado:int = 0
@export var lockX:bool = false
@export var lockY:bool = false
var timeTornado:float
var rotationPerChart:float
var chartsTornadoPosition:PackedVector2Array
var rotationCharts:PackedFloat32Array

@export_subgroup("Rainbow")
@export var RGBActive:bool = false
@export var velocityRGB:float = 1.0
@export var separationRGB:float = 0.03
@export var saturation:float = 0.5
@export var mixColor:bool = true ##Recomendable si quieres degradados de un solor color o mas suaves
@export var ColorMix:Color = Color(1.0, 1.0, 1.0, 1.0)
@export_range(0.0,1.0) var CoeficienteMix:float = 0.3
@export var startRGB:int = 0 ##Mientras mayor sea el numero menos caracteres agarrara desde el inicio
@export var finalRGB:int = 0 ##Mientras mayor sea el numero menos caracteres agarrara desde el final
var timeRGB:float

@export_subgroup("Shake")
@export var shakeActive:bool = false
@export var connected:bool = false ##si esta activo todas las letras vibraran de la misma manera
@export var shakeRate:float = 0.1
@export var shakeAmp:float = 5
@export var startShake:int = 0 ##Mientras mayor sea el numero menos caracteres agarrara desde el inicio
@export var finalShake:int = 0 ##Mientras mayor sea el numero menos caracteres agarrara desde el final
@export_range(0.0,1.0) var frequency:float = 0.25
var shakeTime:float
var chartShakePosition:PackedVector2Array
var chartShakeObjective:PackedVector2Array

@export_subgroup("Shadow")
@export var shadowActive:bool = false
@export var shadowPosition:Vector2 = Vector2(5,5)
@export var shadowColor:Color = Color(0.0, 0.0, 0.0, 0.502)
@export var startShadow:int = 0 ##Mientras mayor sea el numero menos caracteres agarrara desde el inicio
@export var finalShadow:int = 0 ##Mientras mayor sea el numero menos caracteres agarrara desde el final


@export_category("DEBUG")
@export var DebugActive:bool = false

#para poder dibujar las letras sin problemas
var longitudText:int
var timeFixed:float
var prevPosx:float
var chartsPosition:PackedVector2Array
var chartsSize:PackedVector2Array
var chartFontSize:PackedInt32Array
var centerSizeCharts:PackedFloat32Array
var posicionTextoFinal:Vector2
const luminosidad:Vector3 = Vector3(0.299, 0.587, 0.114)
var stringSize:Vector2


func _ready() -> void:
	variablesElement = get_exported_vars_from_script()

func updateChartsDataPacked():
	var diference:int = textToDraw.length() - chartScales.size()
	if diference > 0:
		for i in range(diference):
			chartsPosition.append(Vector2.ZERO)
			chartsOffset.append(Vector2.ZERO)
			chartShakeObjective.append(Vector2.ZERO)
			chartsTornadoPosition.append(Vector2.ZERO)
			chartShakePosition.append(Vector2.ZERO)
			chartScales.append(1.0)
			rotationCharts.append(0.0)
			chartFontSize.append(0)
			chartsSize.append(Vector2.ZERO)
	
	elif diference < 0:
		chartScales.resize(longitudText)
		chartsPosition.resize(longitudText)
		chartsOffset.resize(longitudText)
		rotationCharts.resize(longitudText)
		chartShakeObjective.resize(longitudText)
		chartsTornadoPosition.resize(longitudText)
		chartShakePosition.resize(longitudText)
		chartsSize.resize(longitudText)
		chartFontSize.resize(longitudText)
	
func recalcChartsData():
	for i in range(longitudText):
		chartFontSize[i] = int(fontSize * chartScales[i])
		var char_code = textToDraw.unicode_at(i)
		chartsSize[i] = fuente.get_char_size(char_code,chartFontSize[i])

func get_exported_vars_from_script() -> Array:
	var exported_vars: Array = []
	var script = get_script()
	
	# Aseguramos que el script exista (siempre debería ser así)
	if script:
		var script_properties = script.get_script_property_list()
		var actualGroup:int = -1
		var actualSubGroup:int = -1
		for property in script_properties:
			if property.usage & PROPERTY_USAGE_EDITOR:
				var tipoVariable:String = type_string(property.type)
				var nombreVariable:String = property.name
				var datosVariables:Dictionary = {"tipo":tipoVariable,"nombre":nombreVariable}
				if actualGroup != -1:
					if actualSubGroup != -1:
						exported_vars[actualGroup][actualSubGroup].append(datosVariables)
					else:
						exported_vars[actualGroup].append(datosVariables)
				else:
					exported_vars.append(datosVariables)
			elif property.usage & PROPERTY_USAGE_GROUP:
				exported_vars.append([property.name])
				actualGroup = exported_vars.size()-1
				actualSubGroup = -1
			elif property.usage & PROPERTY_USAGE_SUBGROUP:
				exported_vars[actualGroup].append([property.name])
				actualSubGroup = exported_vars[actualGroup].size()-1
				
	return exported_vars
	
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	match anchorText:
		AnchorText.LEFT:
			posicionTextoFinal = Vector2(0,0)
		AnchorText.CENTER:
			posicionTextoFinal = Vector2(-stringSize.x/2.0,0)
		AnchorText.RIGHT:
			posicionTextoFinal = Vector2(-stringSize.x,0)
	
	timeFixed = delta * 60.0
	
	timeTornado = fmod(timeTornado + (timeFixed * multiplierTime),360) if TornadoActive else 0.0
	timeRGB = fmod(timeRGB + (delta * velocityRGB), 1.0) if RGBActive else 0.0
	shakeTime = shakeTime + delta if shakeActive else 0.0
	queue_redraw()
	
func _draw() -> void:
	prevPosx = 0
			
	for count:int in range(longitudText):
		var chart:String = textToDraw[count]
		var angleChart = GetAngleChart(timeTornado,count)
		var centerSizeChart = -chartsSize[count].x/2.0
		var basePosX:float = prevPosx + chartsSize[count].x/2.0
		var positionChart:Vector2 = Vector2(basePosX,0.0)
		var colorChart:Color = getColorChart(count)
		GetPositionChart(angleChart,count)
		draw_set_transform( posicionTextoFinal + chartsPosition[count] + chartsTornadoPosition[count] + chartShakePosition[count] + chartsOffset[count] + positionChart,deg_to_rad(RotationChart+rotationCharts[count]),Vector2(1,1))
		
		if shadowActive:
			if not (count < startShadow or count > longitudText- finalShadow-1):
				draw_char(fuente,Vector2(centerSizeChart,0) + shadowPosition,chart, chartFontSize[count],shadowColor)
		
		draw_char(fuente,Vector2(centerSizeChart,0),chart, chartFontSize[count],colorChart)
		
		#crear cuadro de chart debug
		if DebugActive:
			draw_rect(Rect2(Vector2(centerSizeChart,0),Vector2(chartsSize[count].x , -chartsSize[count].y)),Color(1.0, 1.0, 1.0, 0.561),false)
			draw_rect(Rect2(Vector2(centerSizeChart,0),Vector2(chartsSize[count].x , -chartsSize[count].y/2.0)),Color(0.0, 0.783, 1.0, 0.58),false)
			
		prevPosx += chartsSize[count].x + TextSeparation
			
	#resetea transform para dibujar longitud DEBUG de texto
	draw_set_transform(posicionTextoFinal,0.0,Vector2(1,1))
	
	if DebugActive:
		draw_string(fuente,Vector2(0,-100),str(longitudText))
		draw_rect(Rect2(Vector2.ZERO,Vector2(stringSize.x , -stringSize.y)),Color(0.781, 0.085, 0.085, 1.0),false)
	
func GetPositionChart(angleChart,count:int):
	if TornadoActive:
		if !rotationPerChartActive:
			rotationCharts[count] = lerp(rotationCharts[count],0.0,0.1*timeFixed)
			
		if not (count < startTornado or count > longitudText- finalTornado-1):
			chartsTornadoPosition[count] = GetTornadoPosition(angleChart,count)
		else:
			rotationCharts[count] = lerp(rotationCharts[count],0.0,0.1*timeFixed)
			chartsTornadoPosition[count] = lerp(chartsTornadoPosition[count],Vector2.ZERO,0.1*timeFixed)
	else:
		chartsTornadoPosition[count] = lerp(chartsTornadoPosition[count],Vector2.ZERO,0.1)
		rotationCharts[count] = lerp(rotationCharts[count],0.0,0.1*timeFixed)
		
	if shakeActive:
		GetShakePosition(count)
		if not (count < startShake or count > longitudText- finalShake-1):
			if connected:
				if count == startShake:
					chartShakePosition[count] = lerp(chartShakePosition[count],chartShakeObjective[count],frequency * timeFixed)
				else:
					chartShakePosition[count] = chartShakePosition[startShake]
			else:
				chartShakePosition[count] = lerp(chartShakePosition[count],chartShakeObjective[count],frequency * timeFixed)
		else:
			chartShakePosition[count] = lerp(chartShakePosition[count],Vector2.ZERO,0.1*timeFixed)
	else:
		chartShakePosition[count] = lerp(chartShakePosition[count],Vector2.ZERO,0.1*timeFixed)

func GetShakePosition(count:int):
	if shakeTime >= shakeRate:
		chartShakeObjective[count] = Vector2(randf_range(-shakeAmp,shakeAmp),randf_range(-shakeAmp,shakeAmp))
	
	if shakeTime >= shakeRate and count == longitudText - finalShake -1 :
		shakeTime = 0
		
func GetTornadoPosition(angleChart:float,count:int) -> Vector2:
	var rotacionX:float
	var rotacionY:float
		
	var rotacionHorizontal:float = cos(angleChart)
	var rotacionVertical:float = sin(angleChart)
	
	rotacionX = rotacionHorizontal * amp if !lockX else 0.0
	
	rotacionY = rotacionVertical * amp if !lockY else 0.0
		
	if rotationPerChartActive:
		rotationCharts[count] = rotacionHorizontal * FactorRPC
		rotationPerChart = rotacionHorizontal * FactorRPC

	return Vector2(rotacionX , rotacionY)

func GetAngleChart(convertedTime,count) -> float:
	return deg_to_rad(convertedTime + (offsetRotationPerChart * count))

func getColorChart(count:int) -> Color:
	if RGBActive:
		if count < startRGB or count > longitudText- finalRGB -1:
			return BaseColor
			
		var colorBase:Color = Color.from_hsv(timeRGB + separationRGB * count, 1.0,1.0)
		
		if saturation == 1.0:
			return colorBase
			
		var valorEscalar:float = Vector3(colorBase.r,colorBase.g,colorBase.b).dot(luminosidad)
		var colorMixed:Vector3 = lerp( Vector3(valorEscalar,valorEscalar,valorEscalar), Vector3(colorBase.r,colorBase.g,colorBase.b),saturation)
		
		var colorMixedConverted:Color = Color(colorMixed.x,colorMixed.y,colorMixed.z,1.0)
		
		if mixColor:
			return colorMixedConverted.lerp(ColorMix,CoeficienteMix)
		else:
			return colorMixedConverted
	return BaseColor
