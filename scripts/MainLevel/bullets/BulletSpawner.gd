extends Node2D
class_name BulletSpawner

var chartData:JSON = DataGame.datalevel

@onready var Efecto_NoRefresh:EffectNoRefresh = get_tree().get_first_node_in_group("effectNoRefresh")

@export var prefabBulletNormal:PackedScene
@export var prefabBulletSpiral:PackedScene
@export var prefabEffecto:PackedScene
@export var chunkSpawner:PackedScene

@export var speedObjective:float = 0.3
var speed:float = 0.3

var bullet_index:int = -1
var efectos_index: int = -1
var bullet_spiral_index: int = -1

var actualview_chart:int = 0
var actualview_chartSpiral:int = 0
var actualview_efectos:int = 0
var chunk_size:float = 5000 ##longitud en milisegundos
var offset_spawn:float = 2000 ##longitud en milisegundos
var chunkView:int = -1

@export var spirales:Node2D 
@export var normales:Node2D
@export var efectos:Node2D
@export var bulletChunk:Node2D

var bulletsData:Array
var spiralesData:Array
var effectsData:Array

var bulletsChunks:Array

# Referencia a cupi
@export var cupi:Cupi
@export var cupiContainer:CupiContainer

func _ready() -> void:
	cupi.bpm = chartData.data.bpm
	
	#if chartData.data.has("spiral"):
		#spiralesData = chartData.data.spiral
	#if chartData.data.has("bullets"):
		#bulletsData = chartData.data.bullets
	#if chartData.data.has("effects"):
		#effectsData = chartData.data.effects
		
	spiralesData = chartData.data.get("spiral", [])  # o None, o 0, etc.
	bulletsData = chartData.data.get("bullets", [])
	effectsData = chartData.data.get("effects", [])
	
	generateChunksData()
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var songTime:float = cupi.get_song_time()
	speed = lerp(speed,speedObjective,0.1*DataGame.time_fixed)
	
	#spawnDataDrewVersion()
	
	#nuevo sistema
	chunkControl(songTime)
	
func spawnDataDrewVersion():
	var songTime:float = cupi.get_song_time()
	#esta version originalmente fue creada con andrew dev yo solo cambie cosas para que soportara mas tipos de bala :P
	var time_offset:float = 0.0
	var time_offsetSpiral:float = 0.0
	var time_offsetEfectos:float = 0.0
	#bala normal
	for i in range(50):
		if !chartData.data.has("bullets"):
			break
		var cur_time:float = time_offset # woops
		if cupi.musicNormalOrInverted:
			if cur_time >= 2000 + songTime or actualview_chart >= chartData.data.bullets.size() or actualview_chart<0:
				#print(cur_time,"|||",2000+snapped(song_time,0),"|||",actualview_chart,"|||",str(Time.get_ticks_msec()),"|||",cupi.musicNormalOrInverted)
				break

			var next_time:float = chartData.data.bullets[actualview_chart]["time"]
			
			if cur_time >= next_time:
				actualview_chart += 1
			else:
				time_offset = next_time+1
				
			if bullet_index != actualview_chart:
				var bullet:CupiBullet = prefabBulletNormal.instantiate()  
				normales.add_child(bullet)
				bullet.baseSpawnTime = cupi.get_song_time()
				bullet.baseStrumTime = next_time
				bullet.distance = (next_time - songTime)
				bullet.angle = fmod(chartData.data.bullets[actualview_chart]["angle"],360)
				bullet_index = actualview_chart
				bullet.expresionContain= chartData.data.bullets[actualview_chart]["expresion"]
				bullet.cupi = cupi
				bullet.cupiContainer = cupiContainer
				bullet.spawner = self
				#print(cupi.chartData.data.bullets[actualview_chart-1]["id"])
				actualview_chart += 1
						
		else:
			
			var reverseView = actualview_chart - normales.get_child_count()-1

			if reverseView<0:
				break
			if songTime < chartData.data.bullets[reverseView]["time"]:
				var bullet:CupiBullet = prefabBulletNormal.instantiate()  
				normales.add_child(bullet)
				bullet.baseSpawnTime = songTime
				bullet.baseStrumTime = chartData.data.bullets[reverseView]["time"]
				bullet.distance = (chartData.data.bullets[reverseView]["time"] - songTime)
				bullet.angle = chartData.data.bullets[reverseView]["angle"]
				bullet_index = actualview_chart
				bullet.expresionContain= chartData.data.bullets[reverseView-1]["expresion"]
				bullet.cupi = cupi
				bullet.cupiContainer = cupiContainer
				bullet.spawner = self
				
				#cupi.cupiMouth.frame=cupi.chartData.data.bullets[reverseView]["expresion"]
				#print(cupi.chartData.data.bullets[reverseView]["time"])

	#bala en espiral
	for i in range(50):
		if !chartData.data.has("spiral"):
			break
		var cur_timeSpiral:float = time_offsetSpiral # woops
		#print(time_offsetSpiral)
		if cupi.musicNormalOrInverted:
			if cur_timeSpiral >= 2000 + songTime or actualview_chartSpiral >= chartData.data.spiral.size() or actualview_chartSpiral<0:
				break
			var next_timeSpiral:float = chartData.data.spiral[actualview_chartSpiral]["time"]
			#var time_difference = next_time - cur_time 
			
			if cur_timeSpiral >= next_timeSpiral:
				actualview_chartSpiral += 1
			else:
				time_offsetSpiral = next_timeSpiral+1
				continue
				
			if bullet_spiral_index != actualview_chartSpiral:
				var spiral:CupiSpiral = prefabBulletSpiral.instantiate()  
				var duracion = chartData.data.spiral[actualview_chartSpiral-1]["duration"]
				var spiralTime = chartData.data.spiral[actualview_chartSpiral-1]["time"]
				bullet_spiral_index = actualview_chartSpiral
				spirales.add_child(spiral)
						
				#establecer datos de bala inicial
				spiral.AngleStart= -chartData.data.spiral[actualview_chartSpiral-1]["startAngle"]
				spiral.AngleFinal= -chartData.data.spiral[actualview_chartSpiral-1]["finalAngle"]
				
				bullet_index = actualview_chartSpiral
				spiral.calc = (spiralTime + duracion)-(spiralTime)
				spiral.idFuncion = chartData.data.spiral[actualview_chartSpiral-1]["tipeMoveAngle"]

				spiral.bulletStart.baseSpawnTime = songTime
				spiral.bulletStart.baseStrumTime = next_timeSpiral
				spiral.bulletStart.distance = (next_timeSpiral - songTime)
				spiral.bulletStart.angle = -chartData.data.spiral[actualview_chartSpiral-1]["startAngle"]
				spiral.bulletStart.expresionContain= chartData.data.spiral[actualview_chartSpiral-1]["expresion"]
				spiral.bulletStart.isSpiral = true
				spiral.bulletStart.spiralStart = true
				#ahora la otra bala
				spiral.bulletFinal.baseSpawnTime = songTime
				spiral.bulletFinal.baseStrumTime = next_timeSpiral + duracion
				spiral.bulletFinal.distance = (next_timeSpiral - songTime)+duracion
				spiral.bulletFinal.angle = -chartData.data.spiral[actualview_chartSpiral-1]["finalAngle"]
				spiral.bulletFinal.expresionContain=chartData.data.spiral[actualview_chartSpiral-1]["expresion"]
				spiral.bulletFinal.isSpiral = true
				spiral.bulletFinal.spiralStart = false

				#referencia de datos
				spiral.bulletStart.cupi = cupi
				spiral.bulletStart.cupiContainer = cupiContainer
				spiral.bulletStart.spawner = self
				
				spiral.bulletFinal.cupi = cupi
				spiral.bulletFinal.cupiContainer = cupiContainer
				spiral.bulletFinal.spawner = self
				
		else:
			
			var reverseView = actualview_chartSpiral-spirales.get_child_count()-1
			if reverseView<0:
				break
				
			if songTime < chartData.data.spiral[reverseView]["time"] + chartData.data.spiral[reverseView]["duration"]:
				var spiral:CupiSpiral = prefabBulletSpiral.instantiate()  
				var duracion = chartData.data.spiral[reverseView]["duration"]
				var spiralTime = chartData.data.spiral[reverseView]["time"]
				
				spirales.add_child(spiral)
				
				spiral.AngleStart= -chartData.data.spiral[reverseView]["startAngle"]
				bullet_index = actualview_chartSpiral
				spiral.AngleFinal= -chartData.data.spiral[reverseView]["finalAngle"]
				spiral.ampFinal = ((chartData.data.spiral[reverseView]["time"] + duracion) - songTime)
				spiral.calc = (spiralTime + duracion)-(spiralTime)
				spiral.idFuncion = chartData.data.spiral[reverseView]["tipeMoveAngle"]
				
				#establecer datos de bala inicial
				spiral.bulletStart.baseSpawnTime = 0
				spiral.bulletStart.baseStrumTime = chartData.data.spiral[reverseView]["time"]
				spiral.bulletStart.distance = chartData.data.spiral[reverseView]["time"]
				spiral.bulletStart.angle = -chartData.data.spiral[reverseView]["finalAngle"]
				spiral.bulletStart.expresionContain= chartData.data.spiral[reverseView-1]["expresion"]
				spiral.bulletStart.isSpiral = true
				spiral.bulletStart.spiralStart = true
				#ahora la otra bala
				spiral.bulletFinal.baseSpawnTime = cupi.get_song_time()
				spiral.bulletFinal.baseStrumTime = chartData.data.spiral[reverseView]["time"] + duracion
				spiral.bulletFinal.distance = ((chartData.data.spiral[reverseView]["time"] + duracion) - songTime)
				spiral.bulletFinal.angle = -chartData.data.spiral[reverseView]["finalAngle"]
				spiral.bulletFinal.expresionContain= chartData.data.spiral[reverseView-1]["expresion"]
				spiral.bulletFinal.isSpiral = true
				
				#referencia de datos
				spiral.bulletStart.cupi = cupi
				spiral.bulletStart.cupiContainer = cupiContainer
				spiral.bulletStart.spawner = self
				
				spiral.bulletFinal.cupi = cupi
				spiral.bulletFinal.cupiContainer = cupiContainer
				spiral.bulletFinal.spawner = self
	
	#efectos
	for i in range(50):
		if !chartData.data.has("effects"):
			break
		var cur_time:float = time_offsetEfectos # woops
		if cupi.musicNormalOrInverted:
			if cur_time >= 2000 + songTime or actualview_efectos >= chartData.data.effects.size() or actualview_efectos<0:
				#print(cur_time,"|||",2000+snapped(song_time,0),"|||",actualview_chart,"|||",str(Time.get_ticks_msec()),"|||",cupi.musicNormalOrInverted)
				break

			var next_time:float = chartData.data.effects[actualview_efectos]["time"]
			
			if cur_time >= next_time:
				actualview_efectos += 1
			else:
				time_offsetEfectos = next_time+1
				
			if efectos_index != actualview_efectos:
				var effect:CupiCustomEffect = prefabEffecto.instantiate()  
				efectos.add_child(effect)
				effect.cupi = cupi
				effect.baseSpawnTime = cupi.get_song_time()
				effect.baseStrumTime = next_time
				efectos_index = actualview_efectos
				if chartData.data.effects[actualview_efectos].has("effectNoRefresh"):
					effect.NoRefreshEffect = Efecto_NoRefresh
					effect.NoRefreshEffectState = chartData.data.effects[actualview_efectos]["effectNoRefresh"]
				actualview_efectos += 1
						
		else:
			
			var reverseView = actualview_chart-normales.get_child_count()-1

			if reverseView<0:
				break
			if songTime < chartData.data.bullets[reverseView]["time"]:
				var bullet:CupiBullet = prefabBulletNormal.instantiate()  
				normales.add_child(bullet)
				bullet.baseSpawnTime = cupi.get_song_time()
				bullet.baseStrumTime = chartData.data.bullets[reverseView]["time"]
				bullet.distance = (chartData.data.bullets[reverseView]["time"] - songTime)
				bullet.angle = chartData.data.bullets[reverseView]["angle"]
				bullet_index = actualview_chart
				bullet.expresionContain= chartData.data.bullets[reverseView-1]["expresion"]
				bullet.cupi = cupi
				bullet.cupiContainer = cupiContainer
				bullet.spawner = self
				
				#cupi.cupiMouth.frame=cupi.chartData.data.bullets[reverseView]["expresion"]
				#print(cupi.chartData.data.bullets[reverseView]["time"])

func generateChunksData() -> void:
	if bulletsData.size() == 0:
		return
	var intialtimeBullets:float = bulletsData[0]["time"]
	var chunkBullet:Array 
	
	#bullets
	for itemBullets in bulletsData:
		#print(item)
		if itemBullets["time"] <= intialtimeBullets + chunk_size:
			chunkBullet.append(itemBullets)
			#print(item)
		else:
			bulletsChunks.append(chunkBullet.duplicate())
			#print(bulletsChunks)
			chunkBullet.clear()
			intialtimeBullets = itemBullets["time"]
			chunkBullet.append(itemBullets)
			
	if !chunkBullet.is_empty():
		bulletsChunks.append(chunkBullet)
	
	#spirales
	
func chunkControl(songTime):
	for chunk_bullet_index in bulletsChunks.size():
		if cupi.musicNormalOrInverted:
			if  songTime >= bulletsChunks[chunk_bullet_index][0]["time"] - offset_spawn and songTime <= bulletsChunks[chunk_bullet_index][0]["time"] + chunk_size - offset_spawn and chunkView != chunk_bullet_index:
				chunkView = chunk_bullet_index
				spawnBullets()
				break
		else:
			if  songTime >= bulletsChunks[chunk_bullet_index][0]["time"] and songTime <= bulletsChunks[chunk_bullet_index][0]["time"] + chunk_size and chunkView != chunk_bullet_index:
				chunkView = chunk_bullet_index
				spawnBullets()
				break

func spawnBullets():
	print("spawneando balas para el chunk " + str(chunkView))
	#for child in bulletChunk.get_children():
		#child.queue_free()
	var chunkContainer:chunkController = null
	var chunkFound:bool = false
	
	if bulletChunk.get_child_count() != 0:
		for chunk in bulletChunk.get_children():
			if chunk.name == "chunk_" + str(chunkView):
				print("el chunk " + str(chunkView) + " si existe")
				chunkContainer = chunk
				chunkFound = true
				if chunk.get_child_count() != 0:
					print("ya existen balas, abortando spawneo")
					return
				else:
					print("creando balas")
		if !chunkFound:
			chunkContainer = chunkSpawner.instantiate()
			chunkContainer.name = "chunk_" + str(chunkView)
			bulletChunk.add_child(chunkContainer)
	else:
		chunkContainer = chunkSpawner.instantiate()
		chunkContainer.name = "chunk_" + str(chunkView)
		bulletChunk.add_child(chunkContainer)
		
	chunkContainer.timeCleanFinal = bulletsChunks[chunkView][0]["time"] + chunk_size
	chunkContainer.timeCleanStart = bulletsChunks[chunkView][0]["time"] - offset_spawn 
	chunkContainer.cupi = cupi
	chunkContainer.set_process(true)
		
	for item in bulletsChunks[chunkView]:
		var bullet:CupiBullet = prefabBulletNormal.instantiate()  
		chunkContainer.add_child(bullet)
		bullet.visible = false
		bullet.baseSpawnTime = 0.0
		bullet.baseStrumTime = item["time"]
		bullet.distance = item["time"]
		bullet.angle = fmod(item["angle"],360)
		bullet.expresionContain = item["expresion"]
		bullet.cupi = cupi
		bullet.cupiContainer = cupiContainer
		bullet.spawner = self
		bullet.name = "bala_0" # se supone que el numero cambiara cuando haya mas de una bala
		
		
func _on_cupi_beat() -> void:
	pass
	#speed = 0.1
