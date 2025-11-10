extends Control

## Antonym activity - matching game
## Match words with their antonyms

# Matching pairs data
var matching_pairs = [
	{"word": "huge", "match": "tiny", "emoji": "🐘"},
	{"word": "happy", "match": "sad", "emoji": "😊"},
	{"word": "fast", "match": "slow", "emoji": "⚡"}
]

var word_index: int = 5
var total_words: int = 6

# Game state
var selected_card = null  # {index: int, column: String, button: Button}
var matched_pairs_list = []  # Array of matched indices
var left_cards = []  # Array of buttons
var right_cards = []  # Array of buttons

# UI references
var feedback_label: Label
var next_button_container: CenterContainer

signal answer_submitted

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = AssetLoader.get_color("parchment")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Main container
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	add_child(margin)

	# VBox for everything
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 25)
	margin.add_child(vbox)

	# XP bar at top
	var xp_bar = PanelContainer.new()
	xp_bar.set_script(load("res://scripts/ui/XPBar.gd"))
	var xp_container = CenterContainer.new()
	xp_container.add_child(xp_bar)
	vbox.add_child(xp_container)

	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer1)

	# Instruction text
	var instruction = Label.new()
	instruction.text = "Match the antonyms:"
	instruction.add_theme_font_size_override("font_size", 28)
	instruction.add_theme_color_override("font_color", Color("#666666"))
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(instruction)

	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer2)

	# Shuffle the right column (matches)
	var shuffled_matches = []
	for pair in matching_pairs:
		shuffled_matches.append(pair["match"])
	shuffled_matches.shuffle()

	# Matching game grid - 2 columns, 3 rows
	var grid_container = HBoxContainer.new()
	grid_container.add_theme_constant_override("separation", 40)
	var grid_center = CenterContainer.new()
	grid_center.add_child(grid_container)
	vbox.add_child(grid_center)

	# Left column (words)
	var left_column = VBoxContainer.new()
	left_column.add_theme_constant_override("separation", 20)
	grid_container.add_child(left_column)

	# Right column (matches)
	var right_column = VBoxContainer.new()
	right_column.add_theme_constant_override("separation", 20)
	grid_container.add_child(right_column)

	# Create left column cards (words)
	for i in range(matching_pairs.size()):
		var card = _create_card(matching_pairs[i]["word"], matching_pairs[i]["emoji"], i, "left")
		left_column.add_child(card)
		left_cards.append(card)

		# Staggered fade-in
		card.modulate.a = 0
		Anima.Node(card).anima_fade_in(0.4).anima_delay(0.3 + i * 0.1).play()

	# Create right column cards (shuffled matches)
	for i in range(shuffled_matches.size()):
		var card = _create_card(shuffled_matches[i], "", i, "right")
		right_column.add_child(card)
		right_cards.append(card)

		# Staggered fade-in
		card.modulate.a = 0
		Anima.Node(card).anima_fade_in(0.4).anima_delay(0.3 + i * 0.1).play()

	# Feedback label (hidden initially)
	feedback_label = Label.new()
	feedback_label.text = ""
	feedback_label.add_theme_font_size_override("font_size", 32)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.visible = false
	vbox.add_child(feedback_label)

	# Next button (hidden initially)
	next_button_container = CenterContainer.new()
	next_button_container.visible = false
	vbox.add_child(next_button_container)

	var next_btn = Button.new()
	next_btn.pressed.connect(_on_next_pressed)
	next_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var next_style = StyleBoxFlat.new()
	next_style.bg_color = AssetLoader.get_color("stone_light")
	next_style.corner_radius_top_left = 15
	next_style.corner_radius_top_right = 15
	next_style.corner_radius_bottom_left = 15
	next_style.corner_radius_bottom_right = 15
	next_style.shadow_size = 6
	next_style.shadow_color = Color(0, 0, 0, 0.3)
	next_style.shadow_offset = Vector2(0, 4)
	next_style.content_margin_left = 30
	next_style.content_margin_right = 30
	next_style.content_margin_top = 20
	next_style.content_margin_bottom = 20

	var next_hover = next_style.duplicate()
	next_hover.bg_color = AssetLoader.get_color("stone_light").lightened(0.1)

	var next_pressed = next_style.duplicate()
	next_pressed.bg_color = AssetLoader.get_color("stone_dark")

	next_btn.add_theme_stylebox_override("normal", next_style)
	next_btn.add_theme_stylebox_override("hover", next_hover)
	next_btn.add_theme_stylebox_override("pressed", next_pressed)

	AssetLoader.apply_header_font(next_btn, 20)
	next_btn.add_theme_color_override("font_color", AssetLoader.get_color("text_dark"))

	next_button_container.add_child(next_btn)
	await get_tree().process_frame
	next_btn.text = "CLAIM XP"
	next_btn.custom_minimum_size = Vector2(250, 70)

	# Return Home button (top left) - add LAST so it's on top
	var home_btn = Button.new()
	home_btn.text = "← Home"
	home_btn.position = Vector2(20, 20)
	home_btn.custom_minimum_size = Vector2(120, 50)
	home_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	home_btn.pressed.connect(_on_home_pressed)

	# Button styling
	var home_style = StyleBoxFlat.new()
	home_style.bg_color = AssetLoader.get_color("stone_light")
	home_style.corner_radius_top_left = 10
	home_style.corner_radius_top_right = 10
	home_style.corner_radius_bottom_left = 10
	home_style.corner_radius_bottom_right = 10
	home_style.content_margin_left = 15
	home_style.content_margin_right = 15
	home_style.content_margin_top = 10
	home_style.content_margin_bottom = 10

	var home_hover = home_style.duplicate()
	home_hover.bg_color = AssetLoader.get_color("stone_dark")

	home_btn.add_theme_stylebox_override("normal", home_style)
	home_btn.add_theme_stylebox_override("hover", home_hover)
	home_btn.add_theme_stylebox_override("pressed", home_hover)

	AssetLoader.apply_header_font(home_btn, 16)
	home_btn.add_theme_color_override("font_color", AssetLoader.get_color("text_dark"))
	add_child(home_btn)

func _create_card(text: String, emoji: String, index: int, column: String) -> Button:
	var card = Button.new()
	card.custom_minimum_size = Vector2(300, 100)
	card.pressed.connect(_on_card_pressed.bind(index, column, card))
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.focus_mode = Control.FOCUS_NONE

	# Button styling with 3D effect
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = AssetLoader.get_color("figma_gold")
	btn_style.border_color = AssetLoader.get_color("figma_dark_brown")
	btn_style.border_width_left = 3
	btn_style.border_width_right = 3
	btn_style.border_width_top = 3
	btn_style.border_width_bottom = 6
	btn_style.corner_radius_top_left = 15
	btn_style.corner_radius_top_right = 15
	btn_style.corner_radius_bottom_left = 15
	btn_style.corner_radius_bottom_right = 15
	btn_style.shadow_size = 8
	btn_style.shadow_color = Color(0, 0, 0, 0.4)
	btn_style.shadow_offset = Vector2(0, 6)
	btn_style.content_margin_left = 20
	btn_style.content_margin_right = 20
	btn_style.content_margin_top = 15
	btn_style.content_margin_bottom = 15

	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = AssetLoader.get_color("figma_gold_light")
	btn_hover.shadow_size = 10
	btn_hover.shadow_offset = Vector2(0, 8)

	var btn_pressed = btn_style.duplicate()
	btn_pressed.bg_color = AssetLoader.get_color("figma_gold").darkened(0.1)
	btn_pressed.shadow_size = 4
	btn_pressed.shadow_offset = Vector2(0, 3)

	card.add_theme_stylebox_override("normal", btn_style)
	card.add_theme_stylebox_override("hover", btn_hover)
	card.add_theme_stylebox_override("pressed", btn_pressed)

	# Store original styles for reset
	card.set_meta("original_normal", btn_style)
	card.set_meta("original_hover", btn_hover)
	card.set_meta("original_pressed", btn_pressed)

	# Create label with text and emoji
	var display_text = emoji + " " + text if emoji != "" else text
	card.text = display_text
	AssetLoader.apply_header_font(card, 22)
	card.add_theme_color_override("font_color", AssetLoader.get_color("figma_dark_brown"))

	return card

func _on_card_pressed(index: int, column: String, button: Button) -> void:
	# Check if this card is already matched
	for pair in matched_pairs_list:
		if (pair["left_index"] == index and column == "left") or (pair["right_index"] == index and column == "right"):
			return  # Already matched, ignore click

	# If no card selected yet, select this card
	if selected_card == null:
		selected_card = {"index": index, "column": column, "button": button}
		_highlight_selected_card(button)
		return

	# If same card clicked again, deselect it
	if selected_card["button"] == button:
		_reset_card_style(button)
		selected_card = null
		return

	# If card from same column clicked, switch selection
	if selected_card["column"] == column:
		_reset_card_style(selected_card["button"])
		selected_card = {"index": index, "column": column, "button": button}
		_highlight_selected_card(button)
		return

	# Different column - attempt to match
	_try_match(selected_card, {"index": index, "column": column, "button": button})

func _highlight_selected_card(button: Button) -> void:
	# Much more visible selection - bright blue/cyan color
	var selected_style = StyleBoxFlat.new()
	selected_style.bg_color = Color("#5DADE2")  # Bright blue to stand out
	selected_style.border_color = Color("#2874A6")  # Darker blue border
	selected_style.border_width_left = 5
	selected_style.border_width_right = 5
	selected_style.border_width_top = 5
	selected_style.border_width_bottom = 8  # Extra thick for emphasis
	selected_style.corner_radius_top_left = 15
	selected_style.corner_radius_top_right = 15
	selected_style.corner_radius_bottom_left = 15
	selected_style.corner_radius_bottom_right = 15
	selected_style.shadow_size = 12
	selected_style.shadow_color = Color(0, 0, 0, 0.5)
	selected_style.shadow_offset = Vector2(0, 10)
	selected_style.content_margin_left = 20
	selected_style.content_margin_right = 20
	selected_style.content_margin_top = 15
	selected_style.content_margin_bottom = 15

	button.add_theme_stylebox_override("normal", selected_style)
	button.add_theme_stylebox_override("hover", selected_style)
	button.add_theme_stylebox_override("disabled", selected_style)

	# Change text color to white for better contrast
	button.add_theme_color_override("font_color", Color.WHITE)

	# Scale up slightly to make it pop
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2)

func _reset_card_style(button: Button) -> void:
	var original_normal = button.get_meta("original_normal")
	var original_hover = button.get_meta("original_hover")
	var original_pressed = button.get_meta("original_pressed")

	button.add_theme_stylebox_override("normal", original_normal)
	button.add_theme_stylebox_override("hover", original_hover)
	button.add_theme_stylebox_override("pressed", original_pressed)

	# Reset font color to original
	button.add_theme_color_override("font_color", AssetLoader.get_color("figma_dark_brown"))

	# Reset scale
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)

func _try_match(card1: Dictionary, card2: Dictionary) -> void:
	# Determine which is left and which is right
	var left_card = card1 if card1["column"] == "left" else card2
	var right_card = card2 if card2["column"] == "right" else card1

	# Get the actual words from the cards
	var left_word = matching_pairs[left_card["index"]]["word"]
	var right_word = right_card["button"].text.strip_edges()

	# Check if they match
	var is_match = (matching_pairs[left_card["index"]]["match"] == right_word)

	if is_match:
		# Correct match!
		_mark_as_matched(left_card, right_card)
		matched_pairs_list.append({
			"left_index": left_card["index"],
			"right_index": right_card["index"]
		})

		# Celebrate
		Anima.Node(left_card["button"]).anima_animation("tada", 0.6).play()
		Anima.Node(right_card["button"]).anima_animation("tada", 0.6).play()

		# Award XP
		XPManager.add_xp(10)

		# Check if all pairs matched
		if matched_pairs_list.size() == matching_pairs.size():
			_show_completion()
	else:
		# Wrong match - shake both cards
		Anima.Node(left_card["button"]).anima_animation("shake_x", 0.4).play()
		Anima.Node(right_card["button"]).anima_animation("shake_x", 0.4).play()

		# Reset both cards after animation
		await get_tree().create_timer(0.5).timeout
		_reset_card_style(left_card["button"])
		_reset_card_style(right_card["button"])

	# Clear selection
	selected_card = null

func _mark_as_matched(left_card: Dictionary, right_card: Dictionary) -> void:
	var matched_style = StyleBoxFlat.new()
	matched_style.bg_color = AssetLoader.get_color("success")
	matched_style.border_color = AssetLoader.get_color("figma_dark_brown")
	matched_style.border_width_left = 3
	matched_style.border_width_right = 3
	matched_style.border_width_top = 3
	matched_style.border_width_bottom = 6
	matched_style.corner_radius_top_left = 15
	matched_style.corner_radius_top_right = 15
	matched_style.corner_radius_bottom_left = 15
	matched_style.corner_radius_bottom_right = 15
	matched_style.shadow_size = 8
	matched_style.shadow_color = Color(0, 0, 0, 0.4)
	matched_style.shadow_offset = Vector2(0, 6)
	matched_style.content_margin_left = 20
	matched_style.content_margin_right = 20
	matched_style.content_margin_top = 15
	matched_style.content_margin_bottom = 15

	for card in [left_card, right_card]:
		card["button"].add_theme_stylebox_override("normal", matched_style)
		card["button"].add_theme_stylebox_override("hover", matched_style)
		card["button"].add_theme_stylebox_override("disabled", matched_style)
		card["button"].add_theme_color_override("font_color", Color.WHITE)
		card["button"].add_theme_color_override("font_disabled_color", Color.WHITE)
		card["button"].disabled = true

func _show_completion() -> void:
	# Show next button
	next_button_container.visible = true
	next_button_container.modulate.a = 0
	Anima.Node(next_button_container).anima_fade_in(0.4).anima_delay(0.5).play()

func _on_next_pressed() -> void:
	print("Session complete!")
	answer_submitted.emit()
	get_tree().change_scene_to_file("res://scenes/Summary.tscn")

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Home.tscn")
