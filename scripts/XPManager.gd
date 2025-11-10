extends Node

## XPManager - Handles XP, levels, and progression
## Singleton that tracks player progress throughout the game

signal xp_gained(amount: int)
signal level_up(new_level: int)
signal xp_changed(current_xp: int, xp_to_next: int)

# Current stats
var current_xp: int = 0
var current_level: int = 1

# XP rewards
const XP_CORRECT_ANSWER = 10
const XP_PERFECT_SESSION = 50
const XP_STREAK_BONUS = 5

# Leveling system - XP required for each level
# Level 1->2: 100 XP, Level 2->3: 150 XP, etc.
const BASE_XP_FOR_LEVEL = 100
const XP_INCREASE_PER_LEVEL = 50

func _ready() -> void:
	_load_progress()
	print("XPManager: Loaded - Level %d, %d XP" % [current_level, current_xp])

# Calculate XP needed for next level
func get_xp_for_next_level() -> int:
	return BASE_XP_FOR_LEVEL + (current_level - 1) * XP_INCREASE_PER_LEVEL

# Get current progress to next level (0.0 to 1.0)
func get_level_progress() -> float:
	var xp_needed = get_xp_for_next_level()
	return float(current_xp) / float(xp_needed)

# Award XP and check for level up
func add_xp(amount: int) -> void:
	current_xp += amount
	xp_gained.emit(amount)
	xp_changed.emit(current_xp, get_xp_for_next_level())

	# Check for level up
	while current_xp >= get_xp_for_next_level():
		_level_up()

	_save_progress()

# Level up!
func _level_up() -> void:
	var xp_needed = get_xp_for_next_level()
	current_xp -= xp_needed
	current_level += 1
	level_up.emit(current_level)
	xp_changed.emit(current_xp, get_xp_for_next_level())
	print("LEVEL UP! Now level %d" % current_level)

# Reward correct answer
func reward_correct_answer() -> void:
	add_xp(XP_CORRECT_ANSWER)

# Reward perfect session (all correct)
func reward_perfect_session() -> void:
	add_xp(XP_PERFECT_SESSION)

# Reward streak bonus
func reward_streak(streak_count: int) -> void:
	if streak_count >= 3:
		add_xp(XP_STREAK_BONUS * (streak_count - 2))

# Save progress to file
func _save_progress() -> void:
	var save_data = {
		"level": current_level,
		"xp": current_xp
	}
	var file = FileAccess.open("user://xp_progress.save", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

# Load progress from file
func _load_progress() -> void:
	if not FileAccess.file_exists("user://xp_progress.save"):
		return

	var file = FileAccess.open("user://xp_progress.save", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var save_data = json.data
			current_level = save_data.get("level", 1)
			current_xp = save_data.get("xp", 0)

# Reset progress (for testing)
func reset_progress() -> void:
	current_level = 1
	current_xp = 0
	_save_progress()
	xp_changed.emit(current_xp, get_xp_for_next_level())
	print("Progress reset!")
