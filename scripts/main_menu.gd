# main_menu.gd — Main Menu Controller
# =====================================
# Handles the title screen with Play, How to Play, and Quit buttons.
# Creates an attractive school-themed visual using built-in Godot nodes.

extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var play_btn: Button = $MainButtons/PlayButton
@onready var howto_btn: Button = $MainButtons/HowToPlayButton
@onready var quit_btn: Button = $MainButtons/QuitButton

@onready var howto_panel: PanelContainer = $HowToPlayPanel
@onready var howto_close_btn: Button = $HowToPlayPanel/VBox/BackButton

# Floating particles (decorative)
var _particles: Array = []
var _time: float = 0.0


func _ready() -> void:
	howto_panel.visible = false

	play_btn.pressed.connect(_on_play)
	howto_btn.pressed.connect(_on_howto)
	quit_btn.pressed.connect(_on_quit)
	howto_close_btn.pressed.connect(_on_howto_close)

	# Ensure MemoryManager is reset when returning to menu
	if MemoryManager:
		MemoryManager.reset_memory()

	# Spawn decorative floating circles
	_spawn_particles()


func _process(delta: float) -> void:
	_time += delta
	_animate_particles(delta)


func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_howto() -> void:
	main_buttons.visible = false
	howto_panel.visible = true


func _on_howto_close() -> void:
	howto_panel.visible = false
	main_buttons.visible = true


func _on_quit() -> void:
	get_tree().quit()


# ── Decorative floating particles ───────────────────────────────────

func _spawn_particles() -> void:
	var colors := [
		Color(0.3, 0.6, 0.65, 0.12),  # teal
		Color(0.5, 0.4, 0.6, 0.10),   # purple
		Color(0.75, 0.65, 0.4, 0.08), # gold
		Color(0.4, 0.6, 0.4, 0.10),   # green
	]

	for i in range(15):
		var circle := ColorRect.new()
		var size := randf_range(8, 40)
		circle.custom_minimum_size = Vector2(size, size)
		circle.size = Vector2(size, size)
		circle.position = Vector2(randf_range(0, 1280), randf_range(0, 720))
		circle.color = colors[i % colors.size()]
		circle.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# Store velocity as metadata
		var data := {
			"node": circle,
			"vx": randf_range(-15, 15),
			"vy": randf_range(-10, -30),
			"base_y": circle.position.y,
		}
		_particles.append(data)
		add_child(circle)
		move_child(circle, 1)  # behind UI elements


func _animate_particles(delta: float) -> void:
	for p in _particles:
		var node: ColorRect = p["node"]
		node.position.x += p["vx"] * delta
		node.position.y = p["base_y"] + sin(_time * 0.5 + node.position.x * 0.01) * 20

		# Wrap around screen edges
		if node.position.x < -50:
			node.position.x = 1330
		elif node.position.x > 1330:
			node.position.x = -50
