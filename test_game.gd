extends SceneTree
# Smoke test - run it with:
#   godot --headless --script test_game.gd

var main


func _initialize():
	main = load("res://main.tscn").instantiate()
	root.add_child(main)
	run_checks()


func run_checks():
	var player = main.get_node("CharacterBody2D")
	print("start")
	await physics_frame
	await physics_frame

	assert(not main.end_screen.visible, "end screen should start hidden")
	var m = main.metres_to_summit()
	assert(m > 250 and m < 262, "summit should be ~256 m away, got %d" % m)

	print("hud ok")
	# spikes kill
	var spike = main.get_node("Spikes/Spike0")
	player.global_position = spike.global_position + Vector2(0, -40)
	await physics_frame
	await physics_frame
	assert(player.dead, "spike did not kill the player")
	assert(main.end_screen.visible, "death screen did not show")
	assert(main.title_label.text == "YOU DIED", "wrong death title")

	print("death ok")
	# the end screen locks input for a moment, then takes any key
	var key = InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	root.push_input(key)
	await physics_frame
	assert(player.dead, "input was accepted during the lock-out")
	while not main.input_ready:
		await physics_frame
	root.push_input(key)
	await physics_frame
	assert(not player.dead, "still dead after respawn")
	assert(not main.end_screen.visible, "death screen stayed up")
	assert(player.global_position == player.start_position, "respawned in the wrong place")

	print("respawn ok")
	# the summit ends the run
	player.global_position = main.get_node("Summit").global_position
	await physics_frame
	await physics_frame
	assert(main.end_screen.visible and main.title_label.text == "SUMMIT!", "summit did not trigger")

	print("ALL CHECKS PASSED")
	quit()
