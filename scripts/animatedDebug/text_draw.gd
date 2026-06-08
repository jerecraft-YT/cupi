@tool
class_name textDraw extends Node2D


enum AnchorText {
	LEFT,CENTER,RIGHT
	}
enum EasingType {
	linear,##0
	easeInSine,##1
	easeOutSine,##2
	easeInOutSine,##3
	easeInCubic,##4
	easeOutCubic,##5
	easeInOutCubic,##6
	easeInQuint,##7
	easeOutQuint,##8
	easeInOutQuint,##9
	easeInCirc,##10
	easeOutCirc,##11
	easeInOutCirc,##12
	easeInElastic,##13
	easeOutElastic,##14
	easeInOutElastic,##15
	easeInQuad,##16
	easeOutQuad,##17
	easeInOutQuad,##18
	easeInBack,##19
	easeOutBack,##20
	easeInOutBack,##21
	easeInBounce,##22
	easeOutBounce,##23
	easeInOutBounce##24
	}

#para poder dibujar las letras sin problemas
const luminosidad:Vector3 = Vector3(0.299, 0.587, 0.114)
var longitudText:int
var timeFixed:float
var prevPosx:float
var chartsPosition:PackedVector2Array
var chartsSize:PackedVector2Array
var chartFontSize:PackedInt32Array
var centerSizeCharts:PackedFloat32Array
var posicionTextoFinal:Vector2
var stringSize:Vector2
@export var DataText:Array = []

var variablesElement:Array

@export var simulate:bool = false

#region General
@export_group("General")

var time:float = 0.0
@export var timeMultiplier:float = 1.0
@export var textToDraw:String:
	set(v):
		if textToDraw == v:
			return
		textToDraw = v
		textClean = GetCleanText(textToDraw)
		longitudText = textClean.length()
		stringSize = fuente.get_string_size(textClean,HORIZONTAL_ALIGNMENT_LEFT,-1,fontSize)
		updateChartsDataPacked()
		recalcChartsData()
	get:
		return textToDraw
		
@export var textClean:String

@export var anchorText:AnchorText:
	set(v):
		if anchorText == v:
			return
		anchorText = v
		match anchorText:
			AnchorText.LEFT:
				posicionTextoFinal = Vector2(0,0)
			AnchorText.CENTER:
				posicionTextoFinal = Vector2(-stringSize.x/2.0,0)
			AnchorText.RIGHT:
				posicionTextoFinal = Vector2(-stringSize.x,0)
	get:
		return anchorText
@export var BaseColor:Color = Color(1.0, 1.0, 1.0, 1.0) ##Activo cuando el efecto RGB no lo esta
@export var BaseScale:Vector2 = Vector2.ONE
@export var BasePosition:Vector2 = Vector2.ZERO
@export var fuente:Font = load("res://testeos/gGroovyCow.ttf")
@export var fontSize:int = 32:
	set(v):
		if fontSize == v:
			return
		fontSize = v
		recalcChartsData()
	get:
		return fontSize
@export var TextSeparation:float
@export var BaseRotation:float
@export_range(0.0,5.0) var chartsScales:PackedFloat32Array:
	set(v):
		if chartsScales == v:
			return
		chartsScales = v
		recalcChartsData()
	get:
		return chartsScales
@export var chartsOffset:PackedVector2Array
#endregion

#region Efectos
@export_group("Efectos")

#region Efecto Tornado
@export_subgroup("Tornado")
@export var TornadoActive:bool = false
@export var amp:float = 10.0
@export var TornadoMultiplierTime:float = 6.0
@export var offsetRotationPerChart:float = 5.0 ##
@export var rotationPerChartActive:bool = true ## RPC = Rotation per Chart
@export_range(-90.0,90.0) var FactorRPC:float = 5.0
@export var lockX:bool = false
@export var lockY:bool = false
var timeTornado:float
var rotationPerChart:float
var chartsTornadoPosition:PackedVector2Array
var rotationCharts:PackedFloat32Array
#endregion

#region Efecto Rainbow
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
#endregion

#region Efecto Shake
@export_subgroup("Shake")
@export var shakeActive:bool = false
@export var connected:bool = false ##si esta activo todas las letras vibraran de la misma manera
@export var shakeRate:float = 0.1
@export var shakeAmp:float = 5
@export_range(0.0,1.0) var frequency:float = 0.25
var startShake:int = -1
var shakeTime:float
@export var chartShakePosition:PackedVector2Array
@export var chartShakeObjective:PackedVector2Array
#endregion

#region Efecto Shadow
@export_subgroup("Shadow")
@export var shadowActive:bool = false
@export var shadowPosition:Vector2 = Vector2(5,5)
@export var shadowColor:Color = Color(0.0, 0.0, 0.0, 0.502)
@export var startShadow:int = 0 ##Mientras mayor sea el numero menos caracteres agarrara desde el inicio
@export var finalShadow:int = 0 ##Mientras mayor sea el numero menos caracteres agarrara desde el final
#endregion
#endregion

#region Transiciones
@export_group("transiciones")

#region Transiciones Entrada
@export_subgroup("entrada")
@export var EntradaActiva:bool = false
@export var OpacidadEntrada:float = 0.0
@export var EscalaEntrada:Vector2 = Vector2(1.5,1.5)
@export var SuavizadoEscala:EasingType = EasingType.linear
@export var PosicionEntrada:Vector2 = Vector2.ZERO
@export var SuavizadoPosicion:EasingType = EasingType.linear
@export var DuracionEntrada:float = 1.0 ##Duracion en segundos
var ProgresoIntro:float
#endregion

#region Transiciones Salida
#endregion
@export_subgroup("salida")
@export var SalidaActiva:bool = false
#endregion


@export_category("DEBUG")
@export var DebugActive:bool = false

func GetCleanText(text:String) -> String:
	var efectos:Array = []
	var i := 0
	var actualEffects:Array = []
	var clearText:String = ""
	while i < text.length():
		if text[i] == "[":
			var end = text.find("]",i)
			if end != -1:
				var actualEffect:String = text.substr(i+1,end-i-1).to_lower()
				#print(actualEffect)
				if actualEffect.begins_with("/"):
					actualEffects.erase(actualEffect.substr(1))
					i = end + 1
					continue
				else:
					actualEffects.append(actualEffect)
					i = end + 1
					continue
		efectos.append(actualEffects.duplicate())
		clearText += text[i]
		i += 1
	DataText = efectos.duplicate()
	return clearText

func updateChartsDataPacked() -> void:
	var diference:int = textClean.length() - chartsScales.size()
	if diference > 0:
		for i in range(diference):
			chartsPosition.append(Vector2.ZERO)
			chartsOffset.append(Vector2.ZERO)
			chartShakeObjective.append(Vector2.ZERO)
			chartsTornadoPosition.append(Vector2.ZERO)
			chartShakePosition.append(Vector2.ZERO)
			chartsScales.append(1.0)
			rotationCharts.append(0.0)
			chartFontSize.append(0)
			chartsSize.append(Vector2.ZERO)
	
	elif diference < 0:
		chartsScales.resize(longitudText)
		chartsPosition.resize(longitudText)
		chartsOffset.resize(longitudText)
		rotationCharts.resize(longitudText)
		chartShakeObjective.resize(longitudText)
		chartsTornadoPosition.resize(longitudText)
		chartShakePosition.resize(longitudText)
		chartsSize.resize(longitudText)
		chartFontSize.resize(longitudText)
	
func recalcChartsData() -> void:
	for i in range(longitudText):
		chartFontSize[i] = int(fontSize * chartsScales[i])
		var char_code = textClean.unicode_at(i)
		chartsSize[i] = fuente.get_char_size(char_code,chartFontSize[i])
	
func _process(delta: float) -> void:
	timeFixed = delta * 60.0
	
	time = max(0,time + (delta*timeMultiplier)) if simulate else 0.0
	ProgresoIntro = min(inverse_lerp(0.0,DuracionEntrada,time),1.0)
	
	timeTornado = fmod(timeTornado + (timeFixed * TornadoMultiplierTime * timeMultiplier),360) if TornadoActive else 0.0
	timeRGB = fmod(timeRGB + (delta * velocityRGB * timeMultiplier), 1.0) if RGBActive else 0.0
	shakeTime = shakeTime + (delta * timeMultiplier) if shakeActive else 0.0
	queue_redraw()
	
func _draw() -> void:
	startShake = -1
	prevPosx = 0
	if shakeActive:
		SetShakePosition()
		
	for count:int in range(longitudText):
		var chart:String = textClean[count]
		var angleChart = GetAngleChart(timeTornado,count)
		var centerSizeChart = -chartsSize[count].x/2.0
		var basePosX:float = prevPosx + chartsSize[count].x/2.0
		var positionChart:Vector2 = Vector2(basePosX,0.0)
		var colorChart:Color = GetColorChart(count)
		var finalShadowColor:Color = shadowColor
		var finalScale:Vector2 = BaseScale
		var finalPosition:Vector2 = BasePosition
		SetPositionChart(angleChart,count)
		
		if EntradaActiva:
			colorChart = GetTransitionColor(colorChart)
			finalShadowColor = GetTransitionColor(finalShadowColor)
			finalScale = GetTransitionScale(finalScale)
			finalPosition = GetTransitionPosition(finalPosition)
		
		draw_set_transform( posicionTextoFinal + chartsPosition[count] + chartsTornadoPosition[count] + chartShakePosition[count] + chartsOffset[count] + positionChart + finalPosition,deg_to_rad(BaseRotation+rotationCharts[count]), finalScale)
		
		if shadowActive:
			if not (count < startShadow or count > longitudText- finalShadow-1):
				draw_char(fuente,Vector2(centerSizeChart,0) + shadowPosition,chart, chartFontSize[count],finalShadowColor)
		
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
	
func SetPositionChart(angleChart,count:int) -> void:
	if DataText[count].find("tornado") != -1 and TornadoActive:
		if !rotationPerChartActive:
			rotationCharts[count] = lerp(rotationCharts[count],0.0,0.1*timeFixed)
			
		chartsTornadoPosition[count] = GetTornadoPosition(angleChart,count)
	else:
		chartsTornadoPosition[count] = lerp(chartsTornadoPosition[count],Vector2.ZERO,0.1)
		rotationCharts[count] = lerp(rotationCharts[count],0.0,0.1*timeFixed)
		
	if DataText[count].find("shake") != -1 and shakeActive:
		if startShake == -1:
			startShake = count
		if connected:
			if count == startShake:
				var objetivo:Vector2 = chartShakeObjective[count]
				var lerpPosition:Vector2 = chartShakePosition[count].lerp(objetivo,frequency * timeFixed * timeMultiplier)
				chartShakePosition[count] = limitarShake(lerpPosition)
			else:
				chartShakePosition[count] = chartShakePosition[startShake]
		else:
			var objetivo:Vector2 = chartShakeObjective[count]
			var lerpPosition:Vector2 = chartShakePosition[count].lerp(objetivo,frequency * timeFixed * timeMultiplier)
			chartShakePosition[count] = limitarShake(lerpPosition)
	else:
		chartShakePosition[count] = lerp(chartShakePosition[count],Vector2.ZERO,0.1*timeFixed)

func limitarShake(posicion:Vector2) -> Vector2:
	var xLimit:float
	var yLimit:float
	xLimit = clamp(posicion.x,-abs(shakeAmp),abs(shakeAmp))
	yLimit = clamp(posicion.y,-abs(shakeAmp),abs(shakeAmp))
		
	return Vector2(xLimit,yLimit)

func SetShakePosition() -> void:
	if shakeTime >= shakeRate:
		for count:int in range(longitudText):
			chartShakeObjective[count] = Vector2(randf_range(-shakeAmp,shakeAmp),randf_range(-shakeAmp,shakeAmp))
	
	if shakeTime >= shakeRate:
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

func GetColorChart(count:int) -> Color:
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

func GetTransitionColor(color:Color) -> Color:
	return Color(color.r,color.g,color.b,lerp(OpacidadEntrada,color.a,ProgresoIntro))

func GetTransitionScale(Scale:Vector2) -> Vector2:
	return lerp(EscalaEntrada,Scale,MathFunctions.call(EasingType.find_key(SuavizadoEscala),ProgresoIntro))

func GetTransitionPosition(Position:Vector2) -> Vector2:
	return lerp(PosicionEntrada,Position,MathFunctions.call(EasingType.find_key(SuavizadoPosicion),ProgresoIntro))
