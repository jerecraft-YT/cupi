extends Panel

@export var infoAudio: Label
@export var efectos: Button
@export var scrollVertical: VBoxContainer
@export var generalScroll: ScrollContainer
@export var panelParametros: Panel
@export var scrollParametros: VBoxContainer
@export var musicScene: AudioStreamPlayer

# Nuevos controles exportados
@export var panelControles: Panel
@export var listaEfectos: OptionButton
@export var botonPausa: Button
@export var botonPlay: Button
@export var botonAgregarEfecto: Button
@export var botonEliminarEfecto: Button
@export var botonHabilitarEfecto: Button
@export var botonDeshabilitarEfecto: Button
@export var labelEstado: Label

# Fuentes más grandes
@export var font_size_titulo: int = 44
@export var font_size_subtitulo: int = 32
@export var font_size_normal: int = 32
@export var font_size_pequeno: int = 24

var efecto_seleccionado: AudioEffect = null
var indice_efecto_seleccionado: int = -1
var audio_pausado: bool = false

# Lista de todos los efectos de audio disponibles en Godot
var todos_efectos_disponibles = [
	{"nombre": "Amplify", "clase": "AudioEffectAmplify"},
	{"nombre": "Chorus", "clase": "AudioEffectChorus"},
	{"nombre": "Compressor", "clase": "AudioEffectCompressor"},
	{"nombre": "Delay", "clase": "AudioEffectDelay"},
	{"nombre": "Distortion", "clase": "AudioEffectDistortion"},
	{"nombre": "EQ (6 bandas)", "clase": "AudioEffectEQ6"},
	{"nombre": "EQ (10 bandas)", "clase": "AudioEffectEQ10"},
	{"nombre": "EQ (21 bandas)", "clase": "AudioEffectEQ21"},
	{"nombre": "HighPass Filter", "clase": "AudioEffectHighpassFilter"},
	{"nombre": "LowPass Filter", "clase": "AudioEffectLowpassFilter"},
	{"nombre": "BandPass Filter", "clase": "AudioEffectBandpassFilter"},
	{"nombre": "Notch Filter", "clase": "AudioEffectNotchFilter"},
	{"nombre": "Limiter", "clase": "AudioEffectLimiter"},
	{"nombre": "Panner", "clase": "AudioEffectPanner"},
	{"nombre": "Phaser", "clase": "AudioEffectPhaser"},
	{"nombre": "Pitch Shift", "clase": "AudioEffectPitchShift"},
	{"nombre": "Reverb", "clase": "AudioEffectReverb"},
	{"nombre": "Spectrum Analyzer", "clase": "AudioEffectSpectrumAnalyzer"},
	{"nombre": "Stereo Enhance", "clase": "AudioEffectStereoEnhance"},
	{"nombre": "Record", "clase": "AudioEffectRecord"}
]

func _ready() -> void:
	# Configurar tamaños de fuente iniciales
	infoAudio.add_theme_font_size_override("font_size", font_size_normal)
	labelEstado.add_theme_font_size_override("font_size", font_size_pequeno)
	
	# Configurar controles
	configurar_controles()
	
	# Cargar efectos iniciales
	spawnEffects()
	cargar_lista_efectos_disponibles()
	
	# Ocultar paneles
	panelParametros.visible = false
	panelControles.visible = true

func configurar_controles():
	# Configurar tamaños de botones
	botonPausa.custom_minimum_size = Vector2(100, 60)
	botonPlay.custom_minimum_size = Vector2(100, 60)
	botonAgregarEfecto.custom_minimum_size = Vector2(100, 60)
	botonEliminarEfecto.custom_minimum_size = Vector2(100, 60)
	botonHabilitarEfecto.custom_minimum_size = Vector2(100, 60)
	botonDeshabilitarEfecto.custom_minimum_size = Vector2(100, 60)
	
	# Configurar fuentes
	botonPausa.add_theme_font_size_override("font_size", font_size_normal)
	botonPlay.add_theme_font_size_override("font_size", font_size_normal)
	botonAgregarEfecto.add_theme_font_size_override("font_size", font_size_normal)
	botonEliminarEfecto.add_theme_font_size_override("font_size", font_size_normal)
	botonHabilitarEfecto.add_theme_font_size_override("font_size", font_size_normal)
	botonDeshabilitarEfecto.add_theme_font_size_override("font_size", font_size_normal)
	listaEfectos.add_theme_font_size_override("font_size", font_size_pequeno)
	
	# Configurar textos
	botonPausa.text = "⏸️ PAUSAR"
	botonPlay.text = "▶️ REANUDAR"
	botonAgregarEfecto.text = "➕ AGREGAR EFECTO"
	botonEliminarEfecto.text = "🗑️ ELIMINAR EFECTO"
	botonHabilitarEfecto.text = "✅ HABILITAR"
	botonDeshabilitarEfecto.text = "❌ DESHABILITAR"
	
	# Conectar señales
	botonPausa.pressed.connect(_on_pausar_pressed)
	botonPlay.pressed.connect(_on_play_pressed)
	botonAgregarEfecto.pressed.connect(_on_agregar_efecto_pressed)
	botonEliminarEfecto.pressed.connect(_on_eliminar_efecto_pressed)
	botonHabilitarEfecto.pressed.connect(_on_habilitar_efecto_pressed)
	botonDeshabilitarEfecto.pressed.connect(_on_deshabilitar_efecto_pressed)
	
	# Configurar estado inicial
	actualizar_estado_audio()

func _process(delta: float) -> void:
	infoAudio.text = drawEffects()
	actualizar_estado_controles()

func _physics_process(delta: float) -> void:
	generalScroll.size.x = scrollVertical.size.x + 8

func spawnEffects():
	# Limpiar botones existentes
	for child in scrollVertical.get_children():
		child.queue_free()
	
	# Crear botones para cada efecto en el bus 0
	for i in range(AudioServer.get_bus_effect_count(0)):
		var boton: Button = Button.new()
		
		# Configurar tamaño y estilo - MÁS GRANDE
		boton.custom_minimum_size = Vector2(250, 70)  # Más grande
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Aplicar tema si existe referencia
		if efectos:
			boton.theme = efectos.theme
		
		# Fuente más grande para el botón
		boton.add_theme_font_size_override("font_size", font_size_normal)
		
		# Texto del botón con estado
		#var efecto = AudioServer.get_bus_effect(0, i)
		var habilitado = not AudioServer.is_bus_effect_enabled(0, i)
		var estado = " ❌" if habilitado else " ✅"
		boton.text = getEffectName(i) + estado
		
		# Color según estado
		if !habilitado:
			boton.add_theme_color_override("font_color", Color.GREEN)
		else:
			boton.add_theme_color_override("font_color", Color.RED)
		
		# Conectar señal
		boton.pressed.connect(_on_efecto_seleccionado.bind(i))
		
		scrollVertical.add_child(boton)

func _on_efecto_seleccionado(indice_efecto: int):
	efecto_seleccionado = AudioServer.get_bus_effect(0, indice_efecto)
	indice_efecto_seleccionado = indice_efecto
	
	# Mostrar información básica con fuente grande
	infoAudio.text = crear_info_basica(efecto_seleccionado, indice_efecto)
	
	# Crear controles de parámetros
	crear_controles_parametros(efecto_seleccionado)
	
	# Mostrar panel de parámetros
	panelParametros.visible = true

func crear_info_basica(efecto: AudioEffect, indice: int) -> String:
	var habilitado = AudioServer.is_bus_effect_enabled(0, indice)
	var estado = "✅ HABILITADO" if habilitado else "❌ DESHABILITADO"
	
	var info = "🎵 EFECTO DE AUDIO SELECCIONADO\n\n"
	info += "📍 Bus: Master\n"
	info += "🔢 Índice: " + str(indice) + "\n"
	info += "📋 Tipo: " + efecto.get_class().replace("AudioEffect", "") + "\n"
	info += "🏷️ Nombre: " + efecto.resource_name + "\n"
	info += "📊 Estado: " + estado + "\n\n"
	info += "💡 Configura los parámetros a continuación:\n"
	
	# Agregar propiedades principales si existen
	if efecto.has_method("get_wet"):
		info += "\n🔊 Wet: %.2f" % efecto.get_wet()
	if efecto.has_method("get_dry"):
		info += "   🔊 Dry: %.2f" % efecto.get_dry()
	
	return info

func crear_controles_parametros(efecto: AudioEffect):
	# Limpiar controles anteriores
	for child in scrollParametros.get_children():
		child.queue_free()
	
	# Título del panel de parámetros - MÁS GRANDE
	var titulo = Label.new()
	titulo.text = "🎛️  PARÁMETROS DE AUDIO"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", font_size_titulo)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scrollParametros.add_child(titulo)
	
	# Separador
	var separador = HSeparator.new()
	separador.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scrollParametros.add_child(separador)
	
	# Espacio
	agregar_espacio(15)
	
	# Obtener y crear controles para propiedades editables
	var propiedades = efecto.get_property_list()
	var propiedades_creadas = 0
	
	for prop in propiedades:
		if prop.usage & PROPERTY_USAGE_EDITOR:
			# Filtrar solo propiedades relevantes para audio
			if es_propiedad_audio_relevante(prop["name"]):
				crear_control_parametro_grande(prop, efecto)
				propiedades_creadas += 1
	
	# Si no hay propiedades relevantes, mostrar mensaje
	if propiedades_creadas == 0:
		var mensaje = Label.new()
		mensaje.text = "Este efecto no tiene parámetros ajustables"
		mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mensaje.add_theme_font_size_override("font_size", font_size_normal)
		scrollParametros.add_child(mensaje)

func es_propiedad_audio_relevante(nombre: String) -> bool:
	# Lista de propiedades comunes de efectos de audio
	var propiedades_audio = [
		"dry", "wet", "volume", "gain", "threshold", "ratio", 
		"attack", "release", "mix", "feedback", "delay",
		"depth", "rate", "predelay", "room", "damping",
		"cutoff", "resonance", "pan", "pitch", "sample"
	]
	
	# También aceptar cualquier propiedad que contenga estas palabras
	var nombre_lower = nombre.to_lower()
	for palabra in propiedades_audio:
		if palabra in nombre_lower:
			return true
	
	return true

func crear_control_parametro_grande(prop: Dictionary, efecto: AudioEffect):
	var nombre = prop["name"]
	var valor_actual = efecto.get(nombre)
	var tipo = prop.type
	var hint = prop.get("hint_string", "")
	
	# Contenedor principal para el parámetro - MÁS GRANDE
	var container_param = VBoxContainer.new()
	container_param.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container_param.custom_minimum_size.y = 120  # Más alto
	
	# Nombre del parámetro - MÁS GRANDE
	var label_nombre = Label.new()
	label_nombre.text = nombre.replace("_", " ").capitalize()
	label_nombre.add_theme_font_size_override("font_size", font_size_subtitulo)
	container_param.add_child(label_nombre)
	
	# Valor actual - MÁS GRANDE
	var label_valor = Label.new()
	label_valor.name = "valor_" + nombre
	label_valor.text = "Actual: " + formatear_valor_legible(valor_actual, tipo)
	label_valor.add_theme_font_size_override("font_size", font_size_pequeno)
	label_valor.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	container_param.add_child(label_valor)
	
	# Controles según el tipo
	var control_container = HBoxContainer.new()
	control_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control_container.custom_minimum_size.y = 50  # Más alto
	
	match tipo:
		TYPE_FLOAT, TYPE_INT:
			# Determinar si es int o float
			var es_int = (tipo == TYPE_INT)
			
			# Obtener rango del hint
			var min_val = 0.0
			var max_val = 100.0 if es_int else 1.0
			var step = 1.0 if es_int else 0.01
			
			if hint:
				var hints = hint.split(",")
				if hints.size() >= 2:
					min_val = float(hints[0])
					max_val = float(hints[1])
					if hints.size() >= 3:
						step = float(hints[2])
			
			# Slider para la mayoría de casos
			var slider = HSlider.new()
			slider.min_value = min_val
			slider.max_value = max_val
			slider.step = step
			slider.value = float(valor_actual)
			slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slider.custom_minimum_size.y = 40  # Slider más alto
			
			# Etiqueta del slider - MÁS GRANDE
			var label_slider = Label.new()
			label_slider.custom_minimum_size.x = 100
			label_slider.add_theme_font_size_override("font_size", font_size_pequeno)
			label_slider.text = formatear_valor_legible(valor_actual, tipo)
			
			slider.value_changed.connect(
				func(valor: float):
					if es_int:
						efecto.set(nombre, int(valor))
						label_slider.text = str(int(valor))
						label_valor.text = "Actual: " + str(int(valor))
					else:
						efecto.set(nombre, valor)
						label_slider.text = "%.3f" % valor
						label_valor.text = "Actual: %.3f" % valor
			)
			
			control_container.add_child(slider)
			control_container.add_child(label_slider)
			
		TYPE_BOOL:
			var checkbox = CheckBox.new()
			checkbox.button_pressed = valor_actual
			checkbox.text = " ACTIVO" if valor_actual else " INACTIVO"
			checkbox.custom_minimum_size.x = 250
			checkbox.custom_minimum_size.y = 50
			
			# Hacer el texto del checkbox más grande
			checkbox.add_theme_font_size_override("font_size", font_size_normal)
			
			checkbox.toggled.connect(
				func(valor: bool):
					efecto.set(nombre, valor)
					checkbox.text = " ACTIVO" if valor else " INACTIVO"
					label_valor.text = "Actual: " + ("Sí" if valor else "No")
			)
			
			control_container.add_child(checkbox)
		
		TYPE_STRING:
			var hbox = HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var line_edit = LineEdit.new()
			line_edit.text = str(valor_actual)
			line_edit.custom_minimum_size.y = 50
			line_edit.placeholder_text = "Ingrese valor..."
			line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			# Texto más grande en el LineEdit
			line_edit.add_theme_font_size_override("font_size", font_size_normal)
			
			line_edit.text_changed.connect(
				func(texto: String):
					efecto.set(nombre, texto)
					label_valor.text = "Actual: " + texto
			)
			
			hbox.add_child(line_edit)
			control_container.add_child(hbox)
	
	container_param.add_child(control_container)
	scrollParametros.add_child(container_param)
	
	# Separador entre parámetros
	var sep = HSeparator.new()
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scrollParametros.add_child(sep)
	
	# Espacio entre parámetros - MÁS GRANDE
	agregar_espacio(10)

func agregar_espacio(altura: int):
	var espacio = Control.new()
	espacio.custom_minimum_size.y = altura
	scrollParametros.add_child(espacio)

func formatear_valor_legible(valor, tipo: int) -> String:
	match tipo:
		TYPE_BOOL:
			return "Sí" if valor else "No"
		TYPE_FLOAT:
			var float_val = float(valor)
			if float_val == 0:
				return "0"
			elif abs(float_val) < 0.001:
				return "%.6f" % float_val
			elif abs(float_val) < 0.01:
				return "%.4f" % float_val
			elif abs(float_val) < 1.0:
				return "%.3f" % float_val
			else:
				return "%.2f" % float_val
		TYPE_INT:
			return str(valor)
		TYPE_STRING:
			if str(valor).length() > 20:
				return str(valor).substr(0, 17) + "..."
			return str(valor)
		_:
			return str(valor)

func getEffectName(i: int) -> String:
	var efecto = AudioServer.get_bus_effect(0, i)
	if efecto:
		var nombre_clase = efecto.get_class().replace("AudioEffect", "")
		var nombre_recurso = efecto.resource_name
		
		if nombre_recurso.begins_with("AudioEffect") or nombre_recurso == "":
			return nombre_clase
		else:
			return nombre_recurso
	return "Efecto " + str(i)

func drawEffects() -> String:
	var busName = AudioServer.get_bus_name(0)
	var info = "🔊 CONFIGURACIÓN DE AUDIO\n\n"
	info += "Bus Principal: " + busName + "\n"
	info += "Volumen: %.1f dB\n" % AudioServer.get_bus_volume_db(0)
	info += "Efectos Activos: " + str(AudioServer.get_bus_effect_count(0)) + "\n"
	info += "Audio: " + ("PAUSADO ⏸️" if audio_pausado else "REPRODUCIENDO ▶️") + "\n\n"
	
	if AudioServer.get_bus_effect_count(0) == 0:
		info += "⚠️ No hay efectos en el bus\n"
		info += "Usa 'AGREGAR EFECTO' para añadir uno"
	else:
		info += "Selecciona un efecto:"
	
	return info

func cargar_lista_efectos_disponibles():
	listaEfectos.clear()
	listaEfectos.add_item("-- Selecciona un efecto --", 0)
	
	for i in range(todos_efectos_disponibles.size()):
		var efecto = todos_efectos_disponibles[i]
		listaEfectos.add_item(efecto["nombre"], i + 1)

# ====== CONTROLES DE AUDIO ======
func _on_pausar_pressed():
	#AudioServer.set_bus_mute(0, true)
	musicScene.stream_paused = true
	audio_pausado = true
	actualizar_estado_audio()
	print("Audio pausado")

func _on_play_pressed():
	musicScene.stream_paused = false
	#AudioServer.set_bus_mute(0, false)
	audio_pausado = false
	actualizar_estado_audio()
	print("Audio reanudado")

func _on_agregar_efecto_pressed():
	var indice_seleccionado = listaEfectos.get_selected_id()
	
	if indice_seleccionado > 0:  # No es el item de selección
		var efecto_info = todos_efectos_disponibles[indice_seleccionado - 1]
		var clase_efecto = efecto_info["clase"]
		
		# Crear instancia del efecto
		if ClassDB.class_exists(clase_efecto):
			var nuevo_efecto = ClassDB.instantiate(clase_efecto)
			if nuevo_efecto:
				# Agregar al bus 0
				AudioServer.add_bus_effect(0, nuevo_efecto)
				print("Efecto agregado: ", efecto_info["nombre"])
				
				# Actualizar interfaz
				spawnEffects()
				actualizar_estado_audio()
				
				# Seleccionar el nuevo efecto
				var ultimo_indice = AudioServer.get_bus_effect_count(0) - 1
				_on_efecto_seleccionado(ultimo_indice)
			else:
				print("Error: No se pudo crear el efecto")
		else:
			print("Error: Clase no existe: ", clase_efecto)
	else:
		print("Selecciona un efecto de la lista")

func _on_eliminar_efecto_pressed():
	if indice_efecto_seleccionado >= 0:
		# Eliminar efecto del bus
		AudioServer.remove_bus_effect(0, indice_efecto_seleccionado)
		print("Efecto eliminado")
		
		# Actualizar interfaz
		spawnEffects()
		panelParametros.visible = false
		infoAudio.text = drawEffects()
		actualizar_estado_audio()
	else:
		print("Selecciona un efecto primero")

func _on_habilitar_efecto_pressed():
	if indice_efecto_seleccionado >= 0:
		AudioServer.set_bus_effect_enabled(0, indice_efecto_seleccionado, true)
		print("Efecto habilitado")
		spawnEffects()
		actualizar_estado_audio()
		
		# Actualizar info si el efecto está seleccionado
		if efecto_seleccionado:
			infoAudio.text = crear_info_basica(efecto_seleccionado, indice_efecto_seleccionado)
	else:
		print("Selecciona un efecto primero")

func _on_deshabilitar_efecto_pressed():
	if indice_efecto_seleccionado >= 0:
		AudioServer.set_bus_effect_enabled(0, indice_efecto_seleccionado, false)
		print("Efecto deshabilitado")
		spawnEffects()
		actualizar_estado_audio()
		
		# Actualizar info si el efecto está seleccionado
		if efecto_seleccionado:
			infoAudio.text = crear_info_basica(efecto_seleccionado, indice_efecto_seleccionado)
	else:
		print("Selecciona un efecto primero")

func actualizar_estado_audio():
	var estado_texto = "🎵 Estado: "
	estado_texto += "PAUSADO ⏸️" if audio_pausado else "REPRODUCIENDO ▶️"
	estado_texto += "\n"
	estado_texto += "🔊 Efectos: " + str(AudioServer.get_bus_effect_count(0))
	estado_texto += " | Seleccionado: "
	estado_texto += str(indice_efecto_seleccionado) if indice_efecto_seleccionado >= 0 else "Ninguno"
	
	labelEstado.text = estado_texto

func actualizar_estado_controles():
	# Habilitar/deshabilitar botones según selección
	var tiene_seleccion = (indice_efecto_seleccionado >= 0)
	
	botonEliminarEfecto.disabled = not tiene_seleccion
	botonHabilitarEfecto.disabled = not tiene_seleccion
	botonDeshabilitarEfecto.disabled = not tiene_seleccion
	
	# Actualizar estado de botones de audio
	botonPausa.disabled = audio_pausado
	botonPlay.disabled = not audio_pausado

# Función para cerrar el panel de parámetros
func _on_cerrar_parametros_pressed():
	panelParametros.visible = false
	infoAudio.text = drawEffects()

# Función para actualizar la lista de efectos
func _on_refrescar_pressed():
	spawnEffects()
	panelParametros.visible = false
	infoAudio.text = drawEffects()
	actualizar_estado_audio()
