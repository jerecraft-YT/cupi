extends Node

var prefabBulletNormal:PackedScene = load("res://prefabs/bullet.tscn")
var prefabBulletSpiral:PackedScene = load("res://prefabs/SpiralBullet.tscn")
var rng = RandomNumberGenerator.new()
var actualview_chart:int = 0
var bullet_index:int = -1
var actualview_chartSpiral:int = 0
var bullet_spiral_index: int = -1
@onready var spirales:Node2D = $spirales
@onready var normales:Node2D = $normales

@export var speed:float = 0.75
# Referencia a cupi
@export var cupi:Node 

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
			#var time_difference = next_time - cur_time 
			
			if cur_time >= next_time:
				actualview_chart += 1
			else:
				time_offset = next_time+1
				
			if bullet_index != actualview_chart:
				var bullet = prefabBulletNormal.instantiate()  
				normales.add_child(bullet)
				bullet.baseSpawnTime = cupi.get_song_time()
				bullet.baseStrumTime = next_time
				bullet.distance = (next_time - song_time)
				bullet.position = Vector2.ONE * 1000
				bullet.angle = cupi.chartData.data.bullets[actualview_chart-1]["angle"]
				bullet_index = actualview_chart
				bullet.expresionContain=cupi.chartData.data.bullets[actualview_chart-1]["expresion"]
						
		else:
			
			var reverseView = actualview_chart-normales.get_child_count()-1

			if reverseView<0:
				break
			if song_time < cupi.chartData.data.bullets[reverseView]["time"]:
				var bullet = prefabBulletNormal.instantiate()  
				normales.add_child(bullet)
				bullet.baseSpawnTime = cupi.get_song_time()
				bullet.baseStrumTime = cupi.chartData.data.bullets[reverseView]["time"]
				bullet.distance = (cupi.chartData.data.bullets[reverseView]["time"] - song_time)
				bullet.position = Vector2.ONE * 1000
				bullet.angle = cupi.chartData.data.bullets[reverseView]["angle"]
				bullet_index = actualview_chart
				bullet.expresionContain=cupi.chartData.data.bullets[reverseView-1]["expresion"]
				#cupi.cupiMouth.frame=cupi.chartData.data.bullets[reverseView]["expresion"]
				#print(cupi.chartData.data.bullets[reverseView]["time"])

	#bala en espiral
	for i in range(50):
		var cur_timeSpiral:float = time_offsetSpiral # woops
		#print(time_offsetSpiral)
		if cupi.musicNormalOrInverted:
			if cur_timeSpiral >= 2000 + song_time or actualview_chartSpiral >= cupi.chartData.data.spiral.size() or actualview_chartSpiral<0:
				#print(cur_time,"|||",2000+snapped(song_time,0),"|||",actualview_chart,"|||",str(Time.get_ticks_msec()),"|||",cupi.musicNormalOrInverted)
				break
			var next_timeSpiral:float = cupi.chartData.data.spiral[actualview_chartSpiral]["time"]
			#var time_difference = next_time - cur_time 
			
			if cur_timeSpiral >= next_timeSpiral:
				actualview_chartSpiral += 1
			else:
				time_offsetSpiral = next_timeSpiral+1
				continue
				
			if bullet_spiral_index != actualview_chartSpiral:
				var bullet = prefabBulletSpiral.instantiate()  
				var duracion = cupi.chartData.data.spiral[actualview_chartSpiral-1]["duration"]
				#print(duracion)
				spirales.add_child(bullet)
						
						#establecer datos de bala inicial
				bullet.bulletStart.baseSpawnTime = song_time
				bullet.bulletStart.baseStrumTime = next_timeSpiral
				bullet.bulletStart.distance = (next_timeSpiral - song_time)
				bullet.bulletStart.position = Vector2.ONE * 1000
				bullet.bulletStart.angle = cupi.chartData.data.spiral[actualview_chartSpiral-1]["startAngle"]
				bullet.AngleStart=cupi.chartData.data.spiral[actualview_chartSpiral-1]["startAngle"]
				bullet_index = actualview_chartSpiral
				bullet.bulletStart.expresionContain=cupi.chartData.data.spiral[actualview_chartSpiral-1]["expresion"]
				bullet.bulletStart.isSpiral = true
				bullet.bulletStart.spiralStart = true
						#ahora la otra bala
				bullet.bulletFinal.baseSpawnTime = song_time
				bullet.bulletFinal.baseStrumTime = next_timeSpiral + duracion
				bullet.bulletFinal.distance = (next_timeSpiral - song_time)+duracion
				bullet.bulletFinal.position = Vector2.ONE * 1000
				bullet.bulletFinal.angle = cupi.chartData.data.spiral[actualview_chartSpiral-1]["finalAngle"]
				bullet.AngleFinal=cupi.chartData.data.spiral[actualview_chartSpiral-1]["finalAngle"]
				bullet_index = actualview_chartSpiral
				bullet.bulletFinal.expresionContain=cupi.chartData.data.spiral[actualview_chartSpiral-1]["expresion"]
				bullet.bulletFinal.isSpiral = true
				bullet.bulletFinal.spiralStart = false
				bullet.calc = (cupi.chartData.data.spiral[actualview_chartSpiral-1]["time"] + duracion)-(cupi.chartData.data.spiral[actualview_chartSpiral-1]["time"])

		else:
			
			var reverseView = actualview_chartSpiral-spirales.get_child_count()-1
			if reverseView<0:
				break
				
			if song_time < cupi.chartData.data.spiral[reverseView]["time"]+cupi.chartData.data.spiral[reverseView]["duration"]:
				var bullet = prefabBulletSpiral.instantiate()  
				var duracion = cupi.chartData.data.spiral[actualview_chartSpiral-1]["duration"]
				#print(duracion)
				spirales.add_child(bullet)
				#establecer datos de bala inicial
				bullet.bulletStart.baseSpawnTime = 0
				bullet.bulletStart.baseStrumTime = cupi.chartData.data.spiral[reverseView]["time"]
				bullet.bulletStart.distance = cupi.chartData.data.spiral[reverseView]["time"]
				bullet.bulletStart.position = Vector2.ONE * 1000
				bullet.bulletStart.angle = cupi.chartData.data.spiral[reverseView]["startAngle"]
				bullet.AngleStart= cupi.chartData.data.spiral[reverseView]["startAngle"]
				bullet.ampStart = 0
				bullet_index = actualview_chartSpiral
				bullet.bulletStart.expresionContain=cupi.chartData.data.spiral[reverseView-1]["expresion"]
				bullet.bulletStart.isSpiral = true
				bullet.bulletStart.spiralStart = true
				#ahora la otra bala
				bullet.bulletFinal.baseSpawnTime = cupi.get_song_time()
				bullet.bulletFinal.baseStrumTime = cupi.chartData.data.spiral[reverseView]["time"] + duracion
				bullet.bulletFinal.distance = ((cupi.chartData.data.spiral[reverseView]["time"] + duracion) - song_time)
				bullet.bulletFinal.position = Vector2.ONE * 1000
				bullet.bulletFinal.angle = cupi.chartData.data.spiral[reverseView]["finalAngle"]
				bullet.AngleFinal= cupi.chartData.data.spiral[reverseView]["finalAngle"]
				bullet.ampFinal = ((cupi.chartData.data.spiral[reverseView]["time"] + duracion) - song_time)
				bullet_index = actualview_chartSpiral
				bullet.bulletFinal.expresionContain=cupi.chartData.data.spiral[reverseView-1]["expresion"]
				bullet.bulletFinal.isSpiral = true
				bullet.calc = (cupi.chartData.data.spiral[reverseView]["time"] + duracion)-(cupi.chartData.data.spiral[reverseView]["time"])
