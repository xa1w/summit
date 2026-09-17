extends Node

const TILE = 80.0  # world pixels per tile == 1 metre of climbing

const DEATH_BACKDROP = Color(0.12, 0.09, 0.14, 0.82)
const WIN_BACKDROP = Color(0.09, 0.32, 0.16, 0.82)
const DEATH_TITLE = Color(1, 0.35, 0.28)
const WIN_TITLE = Color(1, 0.88, 0.38)

@onready var player = $CharacterBody2D
@onready var summit = $Summit
@onready var hud_label = $HUD/DistanceLabel
@onready var end_screen = $EndScreen
@onready var backdrop = $EndScreen/Background
@onready var title_label = $EndScreen/Background/Box/Title
@onready var result_label = $EndScreen/Background/Box/Result
@onready var prompt_label = $EndScreen/Background/Box/Prompt
@onready var skull = $EndScreen/Background/Box/Skull
@onready var crown = $EndScreen/Background/Box/Crown

var finished = false
var input_ready = false


func _ready():
	player.died.connect(_on_player_died)
	summit.body_entered.connect(_on_summit_reached)
	end_screen.hide()


func _process(_delta):
	if not finished:
		hud_label.text = "%d m to the summit" % metres_to_summit()


func metres_to_summit() -> int:
	return maxi(0, int((summit.global_position.x - player.global_position.x) / TILE))


func _on_player_died():
	if finished:
		return
	show_end_screen("YOU DIED", "%d m short of the summit" % metres_to_summit(), false)


func _on_summit_reached(body):
	if finished or body != player:
		return
	hud_label.text = "0 m to the summit"
	$WinSound.play()
	show_end_screen("SUMMIT!", "You made it to the top", true)


func show_end_screen(title: String, result: String, won: bool):
	finished = true
	input_ready = false
	title_label.text = title
	result_label.text = result
	title_label.add_theme_color_override("font_color", WIN_TITLE if won else DEATH_TITLE)
	backdrop.color = WIN_BACKDROP if won else DEATH_BACKDROP
	crown.visible = won
	skull.visible = not won
	prompt_label.text = "Press any key to play again" if won else "Press any key to respawn"
	prompt_label.hide()
	end_screen.show()

	# let the win sink in before a stray key wipes it off the screen
	await get_tree().create_timer(2.5 if won else 0.4).timeout
	if finished:
		prompt_label.show()
		input_ready = true


func _unhandled_input(event):
	if not finished or not input_ready:
		return
	if (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		finished = false
		input_ready = false
		end_screen.hide()
		player.respawn()
