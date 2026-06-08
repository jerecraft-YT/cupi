extends Node2D
class_name BulletTrail

var positions:Array[Vector2] = []
var texture:Texture2D

var life := 1.0
var fade_speed := 4.0

func _process(delta):

	life -= delta * fade_speed

	if life <= 0.0:
		queue_free()
		return

	queue_redraw()

func _draw():

	if texture == null:
		return

	draw_set_transform(Vector2.ZERO - (texture.get_size() / 2.0 * 0.14), 0.0, Vector2.ONE * 0.14)

	for i in range(positions.size()):
		
		var local_pos = to_local(positions[i])
		
		var t := float(i) / float(max(1, positions.size()))

		var alpha := pow(1.0 - t, 2.0)

		draw_texture(
			texture,
			local_pos - Vector2.ONE * 2.0,
			Color(1.0, 1.0, 1.0, alpha * life)
		)
