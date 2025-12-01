extends Node2D
class_name BulletSpawner

@export var prefabBulletNormal:PackedScene
@export var prefabBulletSpiral:PackedScene

var actualview_chart:int = 0
var bullet_index:int = -1
var actualview_chartSpiral:int = 0
var bullet_spiral_index: int = -1

@export var spirales:Node2D 
@export var normales:Node2D

@export var speed:float = 0.75
# Referencia a cupi
@export var cupi:Cupi
@export var cupiContainer:CupiContainer

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	# limitar esto a 2 segundos o algo
	var time_offset:float = 0.0
	var time_offsetSpiral:float = 0.0
	var song_time:float = cupi.get_song_time()
	#bala normal
	for i in range(50):
		var cur_time:float = time_offset # woops
		if cupi.musicNormalOrInverted:
			if cur_time >= 2000 + song_time or actualview_chart >= cupi.chartData.data.bullets.size() or actualview_chart<0:
				#print(cur_time,"|||",2000+snapped(song_time,0),"|||",actualview_chart,"|||",str(Time.get_ticks_msec()),"|||",cupi.musicNormalOrInverted)
				break

			var next_time:float = cupi.chartData.data.bullets[actualview_chart]["time"]
			
			if cur_time >= next_time:
				actualview_chart += 1
			else:
				time_offset = next_time+1
				
			if bullet_index != actualview_chart:
				var bullet:CupiBullet = prefabBulletNormal.instantiate()  
				normales.add_child(bullet)
				bullet.baseSpawnTime = cupi.get_song_time()
				bullet.baseStrumTime = next_time
				bullet.distance = (next_time - song_time)
				bullet.angle = cupi.chartData.data.bullets[actualview_chart-1]["angle"]
				actualview_chart += 1
				bullet_index = actualview_chart
				bullet.expresionContain=cupi.chartData.data.bullets[actualview_chart-1]["expresion"]
				bullet.cupi = cupi
				bullet.cupiContainer = cupiContainer
				bullet.spawner = self
				#print(cupi.chartData.data.bullets[actualview_chart-1]["id"])
				
						
		else:
			
			var reverseView = actualview_chart-normales.get_child_count()-1

			if reverseView<0:
				break
			if song_time < cupi.chartData.data.bullets[reverseView]["time"]:
				var bullet:CupiBullet = prefabBulletNormal.instantiate()  
				normales.add_child(bullet)
				bullet.baseSpawnTime = cupi.get_song_time()
				bullet.baseStrumTime = cupi.chartData.data.bullets[reverseView]["time"]
				bullet.distance = (cupi.chartData.data.bullets[reverseView]["time"] - song_time)
				bullet.angle = cupi.chartData.data.bullets[reverseView]["angle"]
				bullet_index = actualview_chart
				bullet.expresionContain=cupi.chartData.data.bullets[reverseView-1]["expresion"]
				bullet.cupi = cupi
				bullet.cupiContainer = cupiContainer
				bullet.spawner = self
				
				#cupi.cupiMouth.frame=cupi.chartData.data.bullets[reverseView]["expresion"]
				#print(cupi.chartData.data.bullets[reverseView]["time"])

	#bala en espiral
	for i in range(50):
		var cur_timeSpiral:float = time_offsetSpiral # woops
		#print(time_offsetSpiral)
		if cupi.musicNormalOrInverted:
			if cur_timeSpiral >= 2000 + song_time or actualview_chartSpiral >= cupi.chartData.data.spiral.size() or actualview_chartSpiral<0:
				break
			var next_timeSpiral:float = cupi.chartData.data.spiral[actualview_chartSpiral]["time"]
			#var time_difference = next_time - cur_time 
			
			if cur_timeSpiral >= next_timeSpiral:
				actualview_chartSpiral += 1
			else:
				time_offsetSpiral = next_timeSpiral+1
				continue
				
			if bullet_spiral_index != actualview_chartSpiral:
				var spiral:CupiSpiral = prefabBulletSpiral.instantiate()  
				var duracion = cupi.chartData.data.spiral[actualview_chartSpiral-1]["duration"]
				var spiralTime = cupi.chartData.data.spiral[actualview_chartSpiral-1]["time"]
				
				spirales.add_child(spiral)
						
				#establecer datos de bala inicial
				spiral.AngleStart=-cupi.chartData.data.spiral[actualview_chartSpiral-1]["startAngle"]
				spiral.AngleFinal=-cupi.chartData.data.spiral[actualview_chartSpiral-1]["finalAngle"]
				
				bullet_index = actualview_chartSpiral
				spiral.calc = (spiralTime + duracion)-(spiralTime)
				spiral.idFuncion = cupi.chartData.data.spiral[actualview_chartSpiral-1]["tipeMoveAngle"]

				spiral.bulletStart.baseSpawnTime = song_time
				spiral.bulletStart.baseStrumTime = next_timeSpiral
				spiral.bulletStart.distance = (next_timeSpiral - song_time)
				spiral.bulletStart.angle = -cupi.chartData.data.spiral[actualview_chartSpiral-1]["startAngle"]
				spiral.bulletStart.expresionContain=cupi.chartData.data.spiral[actualview_chartSpiral-1]["expresion"]
				spiral.bulletStart.isSpiral = true
				spiral.bulletStart.spiralStart = true
				#ahora la otra bala
				spiral.bulletFinal.baseSpawnTime = song_time
				spiral.bulletFinal.baseStrumTime = next_timeSpiral + duracion
				spiral.bulletFinal.distance = (next_timeSpiral - song_time)+duracion
				spiral.bulletFinal.angle = -cupi.chartData.data.spiral[actualview_chartSpiral-1]["finalAngle"]
				spiral.bulletFinal.expresionContain=cupi.chartData.data.spiral[actualview_chartSpiral-1]["expresion"]
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
				
			if song_time < cupi.chartData.data.spiral[reverseView]["time"]+cupi.chartData.data.spiral[reverseView]["duration"]:
				var spiral:CupiSpiral = prefabBulletSpiral.instantiate()  
				var duracion = cupi.chartData.data.spiral[reverseView]["duration"]
				var spiralTime = cupi.chartData.data.spiral[reverseView]["time"]
				
				spirales.add_child(spiral)
				
				spiral.AngleStart= -cupi.chartData.data.spiral[reverseView]["startAngle"]
				bullet_index = actualview_chartSpiral
				spiral.AngleFinal= -cupi.chartData.data.spiral[reverseView]["finalAngle"]
				spiral.ampFinal = ((cupi.chartData.data.spiral[reverseView]["time"] + duracion) - song_time)
				spiral.calc = (spiralTime + duracion)-(spiralTime)
				spiral.idFuncion = cupi.chartData.data.spiral[reverseView]["tipeMoveAngle"]
				
				#establecer datos de bala inicial
				spiral.bulletStart.baseSpawnTime = 0
				spiral.bulletStart.baseStrumTime = cupi.chartData.data.spiral[reverseView]["time"]
				spiral.bulletStart.distance = cupi.chartData.data.spiral[reverseView]["time"]
				spiral.bulletStart.angle = -cupi.chartData.data.spiral[reverseView]["finalAngle"]
				spiral.bulletStart.expresionContain=cupi.chartData.data.spiral[reverseView-1]["expresion"]
				spiral.bulletStart.isSpiral = true
				spiral.bulletStart.spiralStart = true
				#ahora la otra bala
				spiral.bulletFinal.baseSpawnTime = cupi.get_song_time()
				spiral.bulletFinal.baseStrumTime = cupi.chartData.data.spiral[reverseView]["time"] + duracion
				spiral.bulletFinal.distance = ((cupi.chartData.data.spiral[reverseView]["time"] + duracion) - song_time)
				spiral.bulletFinal.angle = -cupi.chartData.data.spiral[reverseView]["finalAngle"]
				spiral.bulletFinal.expresionContain=cupi.chartData.data.spiral[reverseView-1]["expresion"]
				spiral.bulletFinal.isSpiral = true
				
				#referencia de datos
				spiral.bulletStart.cupi = cupi
				spiral.bulletStart.cupiContainer = cupiContainer
				spiral.bulletStart.spawner = self
				
				spiral.bulletFinal.cupi = cupi
				spiral.bulletFinal.cupiContainer = cupiContainer
				spiral.bulletFinal.spawner = self
