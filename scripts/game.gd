# game.gd — Main Game Controller
# ================================
# Manages the entire story flow: scene transitions, dialogue display,
# choice presentation, and the Memory Log overlay.
# Works with MemoryManager (autoload) for all state.

extends Control

# ── Node references (assigned in _ready) ─────────────────────────────
@onready var bg_rect: ColorRect = $Background
@onready var bg_overlay: ColorRect = $BackgroundOverlay

# Dialogue panel
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/VBox/SpeakerLabel
@onready var dialogue_label: RichTextLabel = $DialoguePanel/VBox/DialogueText
@onready var continue_button: Button = $DialoguePanel/VBox/ContinueButton

# Choices panel
@onready var choices_panel: VBoxContainer = $ChoicesPanel

# Memory log
@onready var memory_overlay: PanelContainer = $MemoryOverlay
@onready var memory_content: RichTextLabel = $MemoryOverlay/VBox/MemoryContent
@onready var memory_close_btn: Button = $MemoryOverlay/VBox/CloseButton

# Memory log toggle button
@onready var memory_toggle_btn: Button = $MemoryToggleButton

# Scene decorations (character portrait area)
@onready var portrait_panel: PanelContainer = $PortraitPanel
@onready var portrait_label: Label = $PortraitPanel/PortraitLabel

# Scene title
@onready var scene_title: Label = $SceneTitle

# ── Story flow ───────────────────────────────────────────────────────
# Each "beat" is a story moment with dialogue and optional choices.
var current_beat: int = 0
var story_beats: Array = []
var _transitioning: bool = false


func _ready() -> void:
	# Hide overlays initially
	memory_overlay.visible = false
	choices_panel.visible = false
	portrait_panel.visible = false

	# Connect signals
	continue_button.pressed.connect(_on_continue)
	memory_close_btn.pressed.connect(_close_memory_log)
	memory_toggle_btn.pressed.connect(_toggle_memory_log)

	# Reset memory for a fresh game
	MemoryManager.reset_memory()

	# Build and start the story
	_build_story()
	_show_beat(0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_memory_log"):
		_toggle_memory_log()


# ── STORY CONSTRUCTION ──────────────────────────────────────────────
# Each beat is a Dictionary:
#   scene_id   : String — for MemoryManager tracking
#   speaker    : String — name shown above dialogue
#   text       : String — dialogue / narration
#   bg_color   : Color  — background tint
#   portrait   : String — character portrait emoji/symbol
#   title      : String — scene title text
#   choices    : Array of { label: String, action_id: String }
#   dynamic    : bool   — if true, text is fetched from MemoryManager
#   on_show    : Callable — optional function to call when beat is shown

func _build_story() -> void:
	story_beats = [
		# ── Beat 0: INTRODUCTION ──────────────────────────────────
		{
			"scene_id": "intro",
			"speaker": "Narrator",
			"text": "Westridge High. Another ordinary school day — or so you thought.\n\nDuring lunch break, you saw something that made your stomach turn. A group of students cornered Maya Chen near the lockers, mocking her, knocking her books out of her hands, laughing as pages scattered across the floor.\n\nNo one stepped in. The hallway was full of people, but everyone looked away.",
			"bg_color": Color(0.10, 0.15, 0.27),  # deep navy
			"portrait": "",
			"title": "CHAPTER 1 — THE INCIDENT",
			"choices": [],
		},
		# ── Beat 1: COURTYARD ─────────────────────────────────────
		{
			"scene_id": "intro",
			"speaker": "Narrator",
			"text": "The afternoon sun casts long shadows across the school courtyard. You spot Maya sitting alone on a bench beneath an old oak tree.\n\nHer shoulders are hunched. She's staring at the ground, her backpack clutched tightly to her chest. The courtyard is quiet — most students have moved on to their next class or headed home.\n\nYou hesitate at the edge of the courtyard. What do you do?",
			"bg_color": Color(0.12, 0.22, 0.18),  # natural green
			"portrait": "🧑‍🎓",
			"title": "THE COURTYARD",
			"choices": [],
		},
		# ── Beat 2: FIRST CHOICE ──────────────────────────────────
		{
			"scene_id": "first_choice",
			"speaker": "Narrator",
			"text": "Maya is right there. The courtyard is nearly empty. This is your moment to decide.",
			"bg_color": Color(0.12, 0.22, 0.18),
			"portrait": "",
			"title": "WHAT WILL YOU DO?",
			"choices": [
				{
					"label": "🤝  Approach Maya and offer support\n\"Hey Maya, I saw what happened. You don't deserve that. Want some company?\"",
					"action_id": "offered_support",
				},
				{
					"label": "🚶  Keep walking and don't get involved\nIt's not really your business. You look away and head to class.",
					"action_id": "ignored_maya",
				},
				{
					"label": "📋  Find a trusted teacher and report the bullying\nYou decide Maya needs real help, not just words from a classmate.",
					"action_id": "sought_help",
				},
			],
		},
		# ── Beat 3: CHOICE RESPONSE (dynamic) ────────────────────
		{
			"scene_id": "choice_response",
			"speaker": "",
			"text": "",  # filled dynamically
			"bg_color": Color(0.12, 0.22, 0.18),
			"portrait": "",
			"title": "",
			"choices": [],
			"dynamic_response": true,
		},
		# ── Beat 4: TIME SKIP ─────────────────────────────────────
		{
			"scene_id": "time_skip",
			"speaker": "Narrator",
			"text": "The next morning arrives. Grey light filters through the classroom windows as students shuffle to their desks.\n\nYou notice Maya enter the room. She glances around nervously, clutching her books. For a moment, her eyes meet yours.",
			"bg_color": Color(0.15, 0.13, 0.22),  # muted purple
			"portrait": "",
			"title": "THE NEXT DAY",
			"choices": [],
		},
		# ── Beat 5: LATER INTERACTION (dynamic) ──────────────────
		{
			"scene_id": "later_interaction",
			"speaker": "",
			"text": "",  # filled by MemoryManager
			"bg_color": Color(0.15, 0.13, 0.22),
			"portrait": "👩",
			"title": "MAYA REMEMBERS",
			"choices": [],
			"dynamic": true,
		},
		# ── Beat 6: SECOND CHOICE LEAD-IN (dynamic) ─────────────
		{
			"scene_id": "second_choice",
			"speaker": "",
			"text": "",
			"bg_color": Color(0.15, 0.13, 0.22),
			"portrait": "👩",
			"title": "",
			"choices": [],
			"dynamic": true,
		},
		# ── Beat 7: SECOND CHOICE ─────────────────────────────────
		{
			"scene_id": "second_choice_action",
			"speaker": "",
			"text": "How do you respond?",
			"bg_color": Color(0.15, 0.13, 0.22),
			"portrait": "",
			"title": "YOUR RESPONSE",
			"choices": [],  # filled dynamically based on context
			"dynamic_choices": true,
		},
		# ── Beat 8: SECOND CHOICE RESPONSE (dynamic) ─────────────
		{
			"scene_id": "second_choice_response",
			"speaker": "",
			"text": "",
			"bg_color": Color(0.15, 0.13, 0.22),
			"portrait": "",
			"title": "",
			"choices": [],
			"dynamic_response2": true,
		},
		# ── Beat 9: ENDING (dynamic) ──────────────────────────────
		{
			"scene_id": "ending",
			"speaker": "",
			"text": "",
			"bg_color": Color(0.10, 0.12, 0.20),
			"portrait": "",
			"title": "ENDING",
			"choices": [],
			"dynamic": true,
			"is_ending": true,
		},
	]


# ── BEAT DISPLAY ────────────────────────────────────────────────────

func _show_beat(index: int) -> void:
	if index < 0 or index >= story_beats.size():
		return

	current_beat = index
	var beat: Dictionary = story_beats[index]

	MemoryManager.current_scene_id = beat.get("scene_id", "")

	# Background colour transition
	var tween := create_tween()
	tween.tween_property(bg_rect, "color", beat.get("bg_color", Color(0.1, 0.1, 0.2)), 0.5)

	# Scene title
	var title_text: String = beat.get("title", "")
	scene_title.text = title_text
	scene_title.visible = title_text != ""

	# Portrait
	var portrait_text: String = beat.get("portrait", "")
	if portrait_text != "":
		portrait_panel.visible = true
		portrait_label.text = portrait_text
	else:
		portrait_panel.visible = false

	# Handle dynamic content from MemoryManager
	var speaker: String = beat.get("speaker", "")
	var text: String = beat.get("text", "")

	if beat.get("dynamic", false):
		var dialogue_data := MemoryManager.get_valid_dialogue(beat["scene_id"])
		speaker = dialogue_data.get("speaker", speaker)
		text = dialogue_data.get("text", text)

	if beat.get("dynamic_response", false):
		var response := _get_first_choice_response()
		speaker = response["speaker"]
		text = response["text"]
		if response.has("title"):
			scene_title.text = response["title"]

	if beat.get("dynamic_response2", false):
		var response := _get_second_choice_response()
		speaker = response["speaker"]
		text = response["text"]
		if response.has("title"):
			scene_title.text = response["title"]

	# Show dialogue
	_clear_choices()
	var choices: Array = beat.get("choices", [])

	# Dynamic choices for second interaction
	if beat.get("dynamic_choices", false):
		choices = _get_second_choices()

	if text != "":
		dialogue_panel.visible = true
		speaker_label.text = speaker
		dialogue_label.text = text

		if choices.size() > 0:
			continue_button.visible = false
			_show_choices(choices)
		elif beat.get("is_ending", false):
			continue_button.visible = false
			_show_ending_buttons()
		else:
			continue_button.visible = true
			continue_button.text = "Continue ▸"
	else:
		# Choice-only beat (like beat 2)
		dialogue_panel.visible = false
		if choices.size() > 0:
			_show_choices(choices)


func _on_continue() -> void:
	if _transitioning:
		return
	_transitioning = true
	_advance_beat()
	_transitioning = false


func _advance_beat() -> void:
	if current_beat + 1 < story_beats.size():
		_show_beat(current_beat + 1)


# ── CHOICES ─────────────────────────────────────────────────────────

func _show_choices(choices: Array) -> void:
	_clear_choices()
	choices_panel.visible = true

	for choice in choices:
		var btn := Button.new()
		btn.text = choice["label"]
		btn.custom_minimum_size = Vector2(700, 60)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		# Style the button
		var style_normal := StyleBoxFlat.new()
		style_normal.bg_color = Color(0.18, 0.25, 0.35, 0.9)
		style_normal.border_color = Color(0.3, 0.55, 0.6, 0.8)
		style_normal.set_border_width_all(2)
		style_normal.set_corner_radius_all(8)
		style_normal.set_content_margin_all(12)

		var style_hover := StyleBoxFlat.new()
		style_hover.bg_color = Color(0.22, 0.35, 0.45, 0.95)
		style_hover.border_color = Color(0.4, 0.7, 0.75, 1.0)
		style_hover.set_border_width_all(2)
		style_hover.set_corner_radius_all(8)
		style_hover.set_content_margin_all(12)

		var style_pressed := StyleBoxFlat.new()
		style_pressed.bg_color = Color(0.15, 0.20, 0.30, 0.95)
		style_pressed.border_color = Color(0.5, 0.8, 0.85, 1.0)
		style_pressed.set_border_width_all(2)
		style_pressed.set_corner_radius_all(8)
		style_pressed.set_content_margin_all(12)

		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style_pressed)
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
		btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		var action_id: String = choice["action_id"]
		btn.pressed.connect(_on_choice_selected.bind(action_id))
		choices_panel.add_child(btn)


func _clear_choices() -> void:
	choices_panel.visible = false
	for child in choices_panel.get_children():
		child.queue_free()


func _on_choice_selected(action_id: String) -> void:
	if _transitioning:
		return
	_transitioning = true

	# Record the interaction
	MemoryManager.record_interaction(action_id)

	# Clear choices and advance
	_clear_choices()
	_advance_beat()
	_transitioning = false


# ── DYNAMIC RESPONSE BUILDERS ───────────────────────────────────────

func _get_first_choice_response() -> Dictionary:
	var first := MemoryManager.get_first_interaction()

	match first:
		"offered_support":
			return {
				"speaker": "Narrator",
				"text": "You walk over to Maya and sit down beside her on the bench. She looks up, startled — then surprised.\n\nFor a moment, neither of you says anything. The afternoon breeze rustles the leaves above.\n\nThen Maya lets out a shaky breath. \"Thanks,\" she whispers. \"I wasn't sure anyone noticed.\"",
				"title": "A MOMENT OF KINDNESS",
			}
		"ignored_maya":
			return {
				"speaker": "Narrator",
				"text": "You adjust your backpack strap and keep walking. Your footsteps echo softly on the path.\n\nYou don't look back, but you feel a strange heaviness in your chest. Part of you wonders if you should have said something.\n\nThe courtyard grows quiet behind you.",
				"title": "WALKING AWAY",
			}
		"sought_help":
			return {
				"speaker": "Narrator",
				"text": "You turn and head back inside the school building, making your way to the staff room.\n\nMs. Chen — the guidance counsellor — listens carefully as you describe what you witnessed. She nods, her expression serious but kind.\n\n\"Thank you for telling me,\" she says. \"That took courage. I'll make sure this is looked into.\"",
				"title": "SPEAKING UP",
			}
		_:
			return {
				"speaker": "Narrator",
				"text": "The moment passes. You continue with your day.",
				"title": "",
			}


func _get_second_choices() -> Array:
	var first := MemoryManager.get_first_interaction()
	var choices: Array = []

	# Always offer "ask how she's feeling"
	choices.append({
		"label": "💬  Ask Maya how she's feeling\n\"How are you holding up, Maya? Honestly.\"",
		"action_id": "asked_feeling",
	})

	# Offer to accompany to teacher — makes sense in most contexts
	if first == "offered_support" or first == "sought_help":
		choices.append({
			"label": "🏫  Offer to go with her to talk to a teacher\n\"Would you like me to come with you to talk to someone about what happened?\"",
			"action_id": "offered_accompany",
		})
	else:
		choices.append({
			"label": "🏫  Suggest she talks to a teacher\n\"Have you thought about talking to a teacher about what happened?\"",
			"action_id": "offered_accompany",
		})

	# Give space option
	choices.append({
		"label": "🌿  Give her some space but let her know you're there\n\"I'll be around if you need anything. You don't have to go through this alone.\"",
		"action_id": "gave_space",
	})

	return choices


func _get_second_choice_response() -> Dictionary:
	var last := MemoryManager.get_last_interaction()

	match last:
		"asked_feeling":
			return {
				"speaker": "Maya",
				"text": "Maya is quiet for a moment. Then, slowly, she starts to talk.\n\n\"Honestly? I feel invisible most of the time. Like I could disappear and nobody would even notice. Yesterday was just... the worst version of that.\"\n\nShe pauses. \"But right now, talking to you... I feel a little less invisible.\"",
				"title": "OPENING UP",
			}
		"offered_accompany":
			return {
				"speaker": "Maya",
				"text": "Maya considers this. You can see the conflict in her expression — fear, uncertainty, but also something else. Hope, maybe.\n\n\"I... yeah. I think I'd like that. I've been too scared to go alone.\" She stands up a little straighter. \"Will you really come with me?\"\n\nYou nod. Together, you walk toward the school building.",
				"title": "TAKING A STEP",
			}
		"gave_space":
			return {
				"speaker": "Narrator",
				"text": "Maya nods quietly. She doesn't say much, but there's a small change in her expression — the tension in her shoulders eases just slightly.\n\n\"Okay,\" she says softly. \"Thanks.\"\n\nYou give her a small wave and step back, leaving the door open without pushing.",
				"title": "RESPECTFUL DISTANCE",
			}
		_:
			return {
				"speaker": "Narrator",
				"text": "The conversation comes to a natural close. The school bell rings in the distance.",
				"title": "",
			}


# ── ENDING BUTTONS ──────────────────────────────────────────────────

func _show_ending_buttons() -> void:
	choices_panel.visible = true

	# Restart button
	var restart_btn := Button.new()
	restart_btn.text = "🔄  Play Again"
	restart_btn.custom_minimum_size = Vector2(300, 55)
	restart_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var style_restart := StyleBoxFlat.new()
	style_restart.bg_color = Color(0.2, 0.4, 0.45, 0.9)
	style_restart.border_color = Color(0.3, 0.6, 0.65, 0.9)
	style_restart.set_border_width_all(2)
	style_restart.set_corner_radius_all(8)
	style_restart.set_content_margin_all(12)

	var style_restart_hover := StyleBoxFlat.new()
	style_restart_hover.bg_color = Color(0.25, 0.5, 0.55, 0.95)
	style_restart_hover.border_color = Color(0.4, 0.75, 0.8, 1.0)
	style_restart_hover.set_border_width_all(2)
	style_restart_hover.set_corner_radius_all(8)
	style_restart_hover.set_content_margin_all(12)

	restart_btn.add_theme_stylebox_override("normal", style_restart)
	restart_btn.add_theme_stylebox_override("hover", style_restart_hover)
	restart_btn.add_theme_font_size_override("font_size", 18)
	restart_btn.add_theme_color_override("font_color", Color(0.9, 0.95, 0.95))
	restart_btn.pressed.connect(_on_restart)
	choices_panel.add_child(restart_btn)

	# Main Menu button
	var menu_btn := Button.new()
	menu_btn.text = "🏠  Main Menu"
	menu_btn.custom_minimum_size = Vector2(300, 55)
	menu_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var style_menu := StyleBoxFlat.new()
	style_menu.bg_color = Color(0.18, 0.2, 0.3, 0.9)
	style_menu.border_color = Color(0.3, 0.4, 0.5, 0.8)
	style_menu.set_border_width_all(2)
	style_menu.set_corner_radius_all(8)
	style_menu.set_content_margin_all(12)

	var style_menu_hover := StyleBoxFlat.new()
	style_menu_hover.bg_color = Color(0.22, 0.28, 0.38, 0.95)
	style_menu_hover.border_color = Color(0.4, 0.55, 0.65, 1.0)
	style_menu_hover.set_border_width_all(2)
	style_menu_hover.set_corner_radius_all(8)
	style_menu_hover.set_content_margin_all(12)

	menu_btn.add_theme_stylebox_override("normal", style_menu)
	menu_btn.add_theme_stylebox_override("hover", style_menu_hover)
	menu_btn.add_theme_font_size_override("font_size", 18)
	menu_btn.add_theme_color_override("font_color", Color(0.85, 0.87, 0.9))
	menu_btn.pressed.connect(_on_main_menu)
	choices_panel.add_child(menu_btn)


func _on_restart() -> void:
	MemoryManager.reset_memory()
	_build_story()
	_show_beat(0)


func _on_main_menu() -> void:
	MemoryManager.reset_memory()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# ── MEMORY LOG ──────────────────────────────────────────────────────

func _toggle_memory_log() -> void:
	memory_overlay.visible = !memory_overlay.visible
	if memory_overlay.visible:
		_update_memory_log()


func _close_memory_log() -> void:
	memory_overlay.visible = false


func _update_memory_log() -> void:
	var data := MemoryManager.get_memory_log_data()
	var lines: PackedStringArray = PackedStringArray()

	lines.append("[b][color=#7ac5cd]━━ ESTABLISHED WORLD FACTS ━━[/color][/b]\n")
	for fact in data["facts"]:
		lines.append("  • " + fact)

	lines.append("\n[b][color=#d4a86a]━━ RECORDED INTERACTIONS ━━[/color][/b]\n")
	if data["interactions"].size() == 0:
		lines.append("  [i](No interactions recorded yet)[/i]")
	else:
		for interaction in data["interactions"]:
			lines.append("  ▸ " + interaction)

	lines.append("\n[b][color=#b38aad]━━ RELATIONSHIP STATE ━━[/color][/b]\n")
	lines.append("  Trust Level: %d" % data["trust"])
	lines.append("  Support Actions: %d" % data["support_count"])
	lines.append("  Help Sought: %s" % ("Yes" if data["help_sought"] else "No"))

	if data["ending"] != "—":
		lines.append("\n[b][color=#8aad8a]━━ ENDING ━━[/color][/b]\n")
		lines.append("  Selected: %s" % data["ending"].to_upper())

	memory_content.text = "\n".join(lines)
