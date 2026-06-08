extends Node2D

@export var notasPosibles:Array = ["D-","D","D+","C-","C","C+","B-","B","B+","A-","A","A+","S"]
@export var expresionBoca:PackedInt32Array
@export var expresionOjos:PackedInt32Array
@export var texto:RichTextLabel
var previoMostrarResultados:bool = true
var cambiarLetraPrevio:bool = true
@export var factorComplete:float
var timeFactorComplete:float
var valorProgreso:float
var quitandoPrevio:bool
var timeAnimation:float
var sonidoPrevioActivo:bool = true
var sonidoFinal:bool = false
@export var progresoBarra:ProgressBar
@export var particles:GPUParticles2D
@export var sonidoPrevio:AudioStreamPlayer2D
@export var sonidoFinalBadum:AudioStreamPlayer2D
@export var resultados:RichTextLabel
@export var cupi:CupiContainer
var resultadosDefinidos:bool
@export var contenedorCupi:Node2D
@export var sonidoMultiplicador:AudioStreamPlayer2D
var mostrarMultiplicador:bool
@export var textoMultiplicador:RichTextLabel
@export var particulasMultiplicador:GPUParticles2D
@export var botonContinuar:Button
var mostrarContinuar:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DataGame.JSONLoaded = false
	DataGame.musicLoaded = false
	DataGame.resourceLoaded = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	factorComplete = DataGame.puntos / DataGame.puntosMaximos
	if previoMostrarResultados:
		if cambiarLetraPrevio:
			previoResultados()
		if sonidoPrevioActivo:
			sonidoPrevioAudio()
			
	else:
		definirNota()
		timeAnimation = clamp(timeAnimation + delta * 3.0, 0, 1)
		texto.scale = Vector2.ONE * (0.6 +  MathFunctions.easeOutBack(timeAnimation) * 0.5)
		contenedorCupi.scale = texto.scale
	progresoBarra.value = valorProgreso * factorComplete
	resultados.scale = lerp(resultados.scale,Vector2.ONE,delta * 10.0)
	timeFactorComplete = clamp(timeFactorComplete + delta * 0.7, 0, 1)
	
	valorProgreso = MathFunctions.easeInCubic(timeFactorComplete)
	
	if timeFactorComplete >= 0.85 and !sonidoFinal:
		sonidoFinal = true
		sonidoFinalBadum.play()
	
	if timeFactorComplete >= 1 and !quitandoPrevio:
		quitandoPrevio = true
		quitarPrevio()
		if DataGame.multiplicadorVelocidad != 1.0:
			Multiplicador()
		else:
			mostrarContinuar = true
	if mostrarMultiplicador:
		textoMultiplicador.modulate = lerp(textoMultiplicador.modulate,Color(1.0, 1.0, 1.0, 1.0),delta * 10.0)
		textoMultiplicador.scale = lerp(textoMultiplicador.scale,Vector2.ONE,delta * 10.0)
	if mostrarContinuar:
		botonContinuar.position = lerp(botonContinuar.position,Vector2(515,600),delta * 10)

func sonidoPrevioAudio():
	sonidoPrevioActivo = false
	await get_tree().create_timer(0.075).timeout
	sonidoPrevioActivo = true
	sonidoPrevio.play()
	sonidoPrevio.pitch_scale = randf_range(0.9,1.2)
	pass

func Multiplicador():
	await get_tree().create_timer(1.5).timeout
	textoMultiplicador.text = "x%s" % [DataGame.multiplicadorVelocidad]
	mostrarMultiplicador = true
	await get_tree().create_timer(0.1).timeout
	particulasMultiplicador.emitting = true
	sonidoMultiplicador.play()
	resultados.scale = Vector2.ONE * 1.2
	DataGame.puntos = DataGame.puntos * (1 +((DataGame.multiplicadorVelocidad - 1) / 2.0 ))
	resultados.text ="
	Puntos: %s
	
	Combo Maximo: %s

	Perfecto: %s
	Ok: %s
	Meh: %s
	Fallidas: %s
		" % [int(DataGame.puntos),DataGame.comboMaximo,DataGame.notasPerfectas,DataGame.notasBuenas,DataGame.notasNormales,DataGame.errores]
	definirNota()
	timeAnimation = 0
	mostrarContinuar = true
	pass

func previoResultados():
	cambiarLetraPrevio = false
	await get_tree().create_timer(0.04).timeout
	if !previoMostrarResultados:
		return
	texto.text = notasPosibles[randi_range(0,notasPosibles.size()-1)]
	resultados.text = "
	Puntos: %s
	
	Combo Maximo: %s

	Perfecto: %s
	Ok: %s
	Meh: %s
	Fallidas: %s
	" % [randi_range(0,10000),randi_range(0,100),randi_range(0,100),randi_range(0,100),randi_range(0,100),randi_range(0,100)]
	
	cambiarLetraPrevio = true

func quitarPrevio():
	await get_tree().create_timer(0.3).timeout
	previoMostrarResultados = false
	
func definirNota():
	if !resultadosDefinidos:
		resultados.text ="
	Puntos: %s
	
	Combo Maximo: %s

	Perfecto: %s
	Ok: %s
	Meh: %s
	Fallidas: %s
		" % [int(DataGame.puntos),DataGame.comboMaximo,DataGame.notasPerfectas,DataGame.notasBuenas,DataGame.notasNormales,DataGame.errores]
		resultadosDefinidos = true
	
	particles.emitting = true
	if factorComplete <= 0.1:
		texto.text = notasPosibles[0]
		cupi.BocaCupi.frame = expresionBoca[0]
		cupi.ojosCupi.frame = expresionOjos[0]
		return
	if factorComplete <= 0.15:
		texto.text = notasPosibles[1]
		cupi.BocaCupi.frame = expresionBoca[1]
		cupi.ojosCupi.frame = expresionOjos[1]
		return
	if factorComplete <= 0.2:
		texto.text = notasPosibles[2]
		cupi.BocaCupi.frame = expresionBoca[2]
		cupi.ojosCupi.frame = expresionOjos[2]
		return
	if factorComplete <= 0.25:
		texto.text = notasPosibles[3]
		cupi.BocaCupi.frame = expresionBoca[3]
		cupi.ojosCupi.frame = expresionOjos[3]
		return
	if factorComplete <= 0.3:
		texto.text = "[rainbow]" +notasPosibles[4]
		cupi.BocaCupi.frame = expresionBoca[4]
		cupi.ojosCupi.frame = expresionOjos[4]
		return
	if factorComplete <= 0.4:
		texto.text = "[rainbow]" +notasPosibles[5]
		cupi.BocaCupi.frame = expresionBoca[5]
		cupi.ojosCupi.frame = expresionOjos[5]
		return
	if factorComplete <= 0.5:
		texto.text = "[rainbow]" +notasPosibles[6]
		cupi.BocaCupi.frame = expresionBoca[6]
		cupi.ojosCupi.frame = expresionOjos[6]
		return
	if factorComplete <= 0.6:
		texto.text = "[rainbow]" +notasPosibles[7]
		cupi.BocaCupi.frame = expresionBoca[7]
		cupi.ojosCupi.frame = expresionOjos[7]
		return
	if factorComplete <= 0.7:
		texto.text = "[rainbow]" +notasPosibles[8]
		cupi.BocaCupi.frame = expresionBoca[8]
		cupi.ojosCupi.frame = expresionOjos[8]
		return
	if factorComplete <= 0.8:
		texto.text = "[rainbow]" +notasPosibles[9]
		cupi.BocaCupi.frame = expresionBoca[9]
		cupi.ojosCupi.frame = expresionOjos[9]
		return
	if factorComplete <= 0.9:
		texto.text = "[rainbow]" +notasPosibles[10]
		cupi.BocaCupi.frame = expresionBoca[10]
		cupi.ojosCupi.frame = expresionOjos[10]
		return
	if factorComplete <= 0.95:
		texto.text = "[rainbow]" +notasPosibles[11]
		cupi.BocaCupi.frame = expresionBoca[11]
		cupi.ojosCupi.frame = expresionOjos[11]
		return
	if factorComplete <= 1.0:
		texto.text = "[rainbow]" +notasPosibles[12]
		cupi.BocaCupi.frame = expresionBoca[12]
		cupi.ojosCupi.frame = expresionOjos[12]
		return


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Pantalla_Titulo.tscn")
