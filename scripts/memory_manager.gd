# memory_manager.gd — Central NPC Memory System (Autoload Singleton)
# ===================================================================
# This is the CORE of the competition entry for Problem 09:
# "NPC Memory Without Invented Lore"
#
# It stores three distinct categories of data:
#   A. ESTABLISHED WORLD FACTS — things that are always true in the story
#   B. PLAYER INTERACTION MEMORIES — events caused by player choices
#   C. RELATIONSHIP STATE — numerical trust + flags derived from interactions
#
# Dialogue is selected deterministically: we check what the player
# actually did and pick only lines that match those recorded facts.
# Maya never claims something happened that wasn't recorded.

extends Node

# ── A. ESTABLISHED WORLD FACTS ──────────────────────────────────────
# These never change during a playthrough. They represent the story's
# baseline reality that must not be contradicted.
var world_facts: Dictionary = {
	"maya_attends_school": true,
	"maya_was_bullied_today": true,
	"player_witnessed_bullying": true,
	"maya_sitting_alone_courtyard": true,
	"school_name": "Westridge High",
}

# ── B. PLAYER INTERACTION MEMORIES ──────────────────────────────────
# An ordered list of action IDs recorded as the player makes choices.
# Example IDs: "offered_support", "ignored_maya", "sought_help",
#              "asked_feeling", "offered_accompany", "gave_space"
var interaction_history: Array[String] = []

# ── C. RELATIONSHIP STATE ───────────────────────────────────────────
# Numeric and boolean values that summarise the relationship.
# These are DERIVED from interactions but stored separately so we
# don't confuse "trust == 2" with "player did exactly two things".
var trust: int = 0
var support_count: int = 0
var help_sought: bool = false

# ── Current story position ──────────────────────────────────────────
# Tracks which scene/beat the player is on (e.g., "intro", "first_choice",
# "later_interaction", "second_choice", "ending").
var current_scene_id: String = "intro"

# Guard against rapid double-clicks registering the same choice twice
var _choice_lock: bool = false


# ── PUBLIC API ──────────────────────────────────────────────────────

## Record a player interaction and update relationship values.
func record_interaction(action_id: String) -> void:
	if _choice_lock:
		return  # prevent rapid double-registration
	_choice_lock = true

	# Only record if not already the last interaction (extra safety)
	if interaction_history.is_empty() or interaction_history[-1] != action_id:
		interaction_history.append(action_id)

	# Update relationship values based on the action
	match action_id:
		"offered_support":
			trust += 2
			support_count += 1
		"ignored_maya":
			trust -= 1
		"sought_help":
			trust += 1
			help_sought = true
		"asked_feeling":
			trust += 1
			support_count += 1
		"offered_accompany":
			trust += 2
			support_count += 1
			help_sought = true
		"gave_space":
			trust += 0  # neutral but respectful
		_:
			push_warning("MemoryManager: Unknown action_id '%s'" % action_id)

	# Unlock after a short delay so the player can't register twice
	await get_tree().create_timer(0.3).timeout
	_choice_lock = false


## Check whether a specific interaction was ever recorded.
func has_interaction(action_id: String) -> bool:
	return action_id in interaction_history


## Return the most recent interaction, or "" if none recorded.
func get_last_interaction() -> String:
	if interaction_history.is_empty():
		return ""
	return interaction_history[-1]


## Return the first interaction (the pivotal first choice).
func get_first_interaction() -> String:
	if interaction_history.is_empty():
		return ""
	return interaction_history[0]


## Select dialogue for Maya based ONLY on recorded interactions.
## This is the key function that prevents invented memories.
func get_valid_dialogue(scene_id: String) -> Dictionary:
	# Returns { "speaker": String, "text": String, "choices": Array }
	# where choices is an Array of { "label": String, "action_id": String }

	var first_choice := get_first_interaction()

	match scene_id:
		"later_interaction":
			return _get_later_interaction_dialogue(first_choice)
		"second_choice":
			return _get_second_choice_dialogue(first_choice)
		"ending":
			return _get_ending_dialogue()
		_:
			return {"speaker": "", "text": "...", "choices": []}


## Determine which ending the player earned.
func select_ending() -> String:
	# Priority: check patterns of behaviour across recorded interactions
	if help_sought and support_count >= 1:
		return "help_seeking"  # sought adult help AND showed personal support
	elif support_count >= 2:
		return "supportive"    # consistently supportive
	elif help_sought:
		return "help_seeking"  # sought help but maybe less personal warmth
	elif trust <= -1:
		return "distant"       # avoided engagement
	elif support_count >= 1:
		return "supportive"    # at least some support shown
	else:
		return "distant"       # fallback: not enough engagement


## Reset all player-dependent state for a fresh playthrough.
## World facts remain the same (they are always true).
func reset_memory() -> void:
	interaction_history.clear()
	trust = 0
	support_count = 0
	help_sought = false
	current_scene_id = "intro"
	_choice_lock = false


# ── PRIVATE DIALOGUE BUILDERS ───────────────────────────────────────

func _get_later_interaction_dialogue(first_choice: String) -> Dictionary:
	var text: String
	var speaker: String = "Maya"

	match first_choice:
		"offered_support":
			text = "Hey... I remember you came and sat with me in the courtyard earlier. That meant a lot. Most people just walked past like nothing happened. Thank you for staying."
		"ignored_maya":
			text = "Oh... hi. I noticed you were in the courtyard earlier, but you didn't come over. It's okay — I understand. Not everyone knows what to say in those situations."
		"sought_help":
			text = "I heard you went to talk to a teacher about what happened. I wasn't sure how to feel about it at first... but I think it was the right thing to do. Thank you for trying to help."
		_:
			# Fallback — should not happen but prevents crash
			text = "Hi... I've seen you around school today."

	return {
		"speaker": speaker,
		"text": text,
		"choices": []  # choices are presented separately by game.gd
	}


func _get_second_choice_dialogue(first_choice: String) -> Dictionary:
	var text: String
	var speaker: String = "Maya"

	# Build context-appropriate lead-in
	if trust >= 2:
		text = "I... I've been trying to hold it together all day. It's hard when people say those things and everyone just watches. But talking to you helps."
	elif trust >= 0:
		text = "It's been a rough day. I keep replaying what happened in my head. I just wish things were different."
	else:
		text = "I don't really feel like talking much... but I guess it's nice that someone is here."

	return {
		"speaker": speaker,
		"text": text,
		"choices": []
	}


func _get_ending_dialogue() -> Dictionary:
	var ending := select_ending()
	var text: String
	var speaker: String = "Narrator"

	match ending:
		"supportive":
			text = _build_supportive_ending()
		"help_seeking":
			text = _build_help_seeking_ending()
		"distant":
			text = _build_distant_ending()
		_:
			text = _build_distant_ending()

	return {
		"speaker": speaker,
		"text": text,
		"choices": []
	}


func _build_supportive_ending() -> String:
	var parts: Array[String] = []
	parts.append("— A Friend in Need —\n")
	parts.append("Through your actions today, you showed Maya that she wasn't alone.")

	if has_interaction("offered_support"):
		parts.append("When you sat with her in the courtyard, you gave her something simple but powerful — the knowledge that someone cared enough to stay.")

	if has_interaction("asked_feeling"):
		parts.append("By asking how she felt, you showed that her emotions mattered — that she was more than just a bystander in her own story.")

	if has_interaction("offered_accompany"):
		parts.append("Offering to go with her to a teacher showed real courage. It's not easy to stand up, but you did.")

	parts.append("\nMaya still has a long road ahead. Bullying doesn't disappear after one conversation. But today, she learned that someone at this school sees her — really sees her.")
	parts.append("\nSometimes, the smallest choices make the biggest difference.")

	return "\n".join(parts)


func _build_help_seeking_ending() -> String:
	var parts: Array[String] = []
	parts.append("— Seeking Help —\n")
	parts.append("You recognised that this situation needed more than words — it needed action.")

	if has_interaction("sought_help"):
		parts.append("By going to a teacher, you took a step that many students are afraid to take. It wasn't easy, but it was important.")

	if has_interaction("offered_accompany"):
		parts.append("Offering to accompany Maya to a teacher showed that you weren't just passing the problem along — you wanted to be there for her.")

	if has_interaction("asked_feeling"):
		parts.append("Taking the time to ask how Maya was feeling showed genuine empathy alongside your practical action.")

	parts.append("\nThe teacher promised to look into the situation. These things take time, and one report doesn't fix everything. But it's a start.")
	parts.append("\nReal change begins when someone decides to speak up.")

	return "\n".join(parts)


func _build_distant_ending() -> String:
	var parts: Array[String] = []
	parts.append("— The Distance Between Us —\n")
	parts.append("Today came and went, and Maya remained mostly on her own.")

	if has_interaction("ignored_maya"):
		parts.append("When you saw her in the courtyard, you chose not to approach. Maybe you didn't know what to say. Maybe it felt too awkward. Those feelings are understandable.")

	if has_interaction("gave_space"):
		parts.append("You gave Maya space, which isn't always wrong — but without any other support, space can feel a lot like silence.")

	if interaction_history.is_empty():
		parts.append("Sometimes doing nothing feels like the safest option. But for the person sitting alone, silence can be the loudest sound.")

	parts.append("\nMaya went home that evening still carrying everything alone. Not every story has a perfect ending — but there's always tomorrow.")
	parts.append("\nEvery day brings new chances to reach out.")

	return "\n".join(parts)


# ── MEMORY LOG DATA (for the visible UI panel) ──────────────────────

## Returns a dictionary formatted for the Memory Log display.
func get_memory_log_data() -> Dictionary:
	var facts: Array[String] = []
	for key in world_facts:
		match key:
			"maya_attends_school":
				facts.append("Maya is a student at %s." % world_facts["school_name"])
			"maya_was_bullied_today":
				facts.append("Maya was bullied by classmates earlier today.")
			"player_witnessed_bullying":
				facts.append("You witnessed the bullying incident.")
			"maya_sitting_alone_courtyard":
				facts.append("Maya was sitting alone in the school courtyard.")

	var interactions: Array[String] = []
	for action_id in interaction_history:
		match action_id:
			"offered_support":
				interactions.append("You offered Maya support and company.")
			"ignored_maya":
				interactions.append("You chose not to interact with Maya.")
			"sought_help":
				interactions.append("You reported the bullying to a teacher.")
			"asked_feeling":
				interactions.append("You asked Maya how she was feeling.")
			"offered_accompany":
				interactions.append("You offered to accompany Maya to a teacher.")
			"gave_space":
				interactions.append("You gave Maya space while showing you care.")
			_:
				interactions.append("Unknown action: %s" % action_id)

	return {
		"facts": facts,
		"interactions": interactions,
		"trust": trust,
		"support_count": support_count,
		"help_sought": help_sought,
		"current_scene": current_scene_id,
		"ending": select_ending() if current_scene_id == "ending" else "—",
	}
