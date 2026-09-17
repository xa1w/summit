extends Node2D

@export var cloud_count := 90
@export var level_width := 21000.0
@export var level_top := -2800.0

func _ready():
	randomize()

	var cloud_texture = $CloudSprite.texture
	$CloudSprite.hide()

	for i in cloud_count:
		var cloud = Sprite2D.new()
		cloud.texture = cloud_texture

		# ponytail: 30 tries, then just take the last spot - a rare
		# overlapping cloud beats an infinite loop when the sky fills up
		for attempt in 30:
			cloud.position = Vector2(
				randf_range(0, level_width),
				randf_range(level_top, 200)
			)

			var too_close = false

			for existing_cloud in get_children():
				if existing_cloud is Sprite2D:
					if cloud.position.distance_to(existing_cloud.position) < 250:
						too_close = true
						break

			if not too_close:
				break

		var size = randf_range(2.0, 4.0)
		cloud.scale = Vector2(size, size)

		cloud.set_meta("cloud_speed", randf_range(10.0, 25.0))

		add_child(cloud)


func _process(delta):
	for cloud in get_children():
		if cloud is Sprite2D and cloud.has_meta("cloud_speed"):
			cloud.position.x += cloud.get_meta("cloud_speed") * delta
			if cloud.position.x > level_width + 400.0:
				cloud.position.x = -400.0
