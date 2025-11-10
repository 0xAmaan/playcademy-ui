extends Control

## Sentence Multiple Choice activity - choose the sentence that correctly uses the word
## Mock data for now (no backend)

# Mock word data
var current_word = {
	"word": "brilliant",
	"correct_sentence": "She had a brilliant idea for the science project.",
	"wrong_sentences": [
		"The sun was brilliant in the sky.",  # Misuse: using as "bright/shiny"
		"He wore a brilliant red shirt.",     # Misuse: using as color descriptor
		"The brilliant light hurt my eyes."   # Misuse: using as "very bright"
	],
	"emoji": "💡",
	"definition": "exceptionally clever or talented"
}

var word_index: int = 3
var total_words: int = 5
var selected_answer: int = -1
var correct_index: int = -1

# UI references
var feedback_label: Label
var next_button_container: CenterContainer
var choices_container: VBoxContainer

signal answer_submitted_signal

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
	instruction.text = "Which sentence correctly uses this word?"
	instruction.add_theme_font_size_override("font_size", 28)
	instruction.add_theme_color_override("font_color", Color("#666666"))
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(instruction)

	# Word card - match MultipleChoice styling
	var word_card = PanelContainer.new()
	word_card.custom_minimum_size = Vector2(600, 200)

	# Card styling with darker border (like MultipleChoice)
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color.WHITE
	card_style.border_color = AssetLoader.get_color("figma_dark_brown")
	card_style.border_width_left = 3
	card_style.border_width_right = 3
	card_style.border_width_top = 3
	card_style.border_width_bottom = 3
	card_style.corner_radius_top_left = 20
	card_style.corner_radius_top_right = 20
	card_style.corner_radius_bottom_left = 20
	card_style.corner_radius_bottom_right = 20
	card_style.shadow_size = 12
	card_style.shadow_color = Color(0, 0, 0, 0.2)
	card_style.shadow_offset = Vector2(0, 6)
	card_style.content_margin_left = 40
	card_style.content_margin_right = 40
	card_style.content_margin_top = 30
	card_style.content_margin_bottom = 30
	word_card.add_theme_stylebox_override("panel", card_style)

	var word_card_container = CenterContainer.new()
	word_card_container.add_child(word_card)
	vbox.add_child(word_card_container)

	var word_vbox = VBoxContainer.new()
	word_vbox.add_theme_constant_override("separation", 15)
	word_card.add_child(word_vbox)

	# Emoji FIRST (above word)
	var emoji_label = Label.new()
	emoji_label.text = current_word["emoji"]
	emoji_label.add_theme_font_size_override("font_size", 72)
	emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	word_vbox.add_child(emoji_label)

	# Word (pixel font, gold color)
	var word_label = Label.new()
	word_label.text = current_word["word"]
	AssetLoader.apply_header_font(word_label, 48)
	word_label.add_theme_color_override("font_color", AssetLoader.get_color("figma_gold"))
	word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	word_vbox.add_child(word_label)

	# Definition
	var def_label = Label.new()
	def_label.text = current_word["definition"]
	AssetLoader.apply_body_font(def_label, 20)
	def_label.add_theme_color_override("font_color", AssetLoader.get_color("text_dark"))
	def_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	def_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	word_vbox.add_child(def_label)

	# Create shuffled sentence options
	var options = _create_shuffled_options()

	# Answer choices
	choices_container = VBoxContainer.new()
	choices_container.add_theme_constant_override("separation", 15)
	vbox.add_child(choices_container)

	for i in range(options.size()):
		# Create centered container for each button
		var btn_center = CenterContainer.new()
		choices_container.add_child(btn_center)

		var choice_btn = Button.new()
		choice_btn.custom_minimum_size = Vector2(900, 70)
		choice_btn.pressed.connect(_on_choice_pressed.bind(i))
		choice_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		choice_btn.focus_mode = Control.FOCUS_NONE

		# Button styling with 3D effect (larger shadow on bottom)
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = AssetLoader.get_color("figma_gold")
		btn_style.border_color = AssetLoader.get_color("figma_dark_brown")
		btn_style.border_width_left = 3
		btn_style.border_width_right = 3
		btn_style.border_width_top = 3
		btn_style.border_width_bottom = 6  # Larger bottom border for 3D effect
		btn_style.corner_radius_top_left = 15
		btn_style.corner_radius_top_right = 15
		btn_style.corner_radius_bottom_left = 15
		btn_style.corner_radius_bottom_right = 15
		btn_style.shadow_size = 8
		btn_style.shadow_color = Color(0, 0, 0, 0.4)
		btn_style.shadow_offset = Vector2(0, 6)  # Bottom shadow for 3D depth
		btn_style.content_margin_left = 25
		btn_style.content_margin_right = 25
		btn_style.content_margin_top = 18
		btn_style.content_margin_bottom = 18

		# Hover state - brighter and "lifted"
		var btn_hover = btn_style.duplicate()
		btn_hover.bg_color = AssetLoader.get_color("figma_gold_light")
		btn_hover.shadow_size = 10
		btn_hover.shadow_offset = Vector2(0, 8)  # Lift effect

		# Pressed state
		var btn_pressed = btn_style.duplicate()
		btn_pressed.bg_color = AssetLoader.get_color("figma_gold").darkened(0.1)
		btn_pressed.shadow_size = 4
		btn_pressed.shadow_offset = Vector2(0, 3)  # Push down effect

		choice_btn.add_theme_stylebox_override("normal", btn_style)
		choice_btn.add_theme_stylebox_override("hover", btn_hover)
		choice_btn.add_theme_stylebox_override("pressed", btn_pressed)

		AssetLoader.apply_header_font(choice_btn, 18)
		choice_btn.add_theme_color_override("font_color", AssetLoader.get_color("figma_dark_brown"))

		btn_center.add_child(choice_btn)
		await get_tree().process_frame
		choice_btn.text = options[i]
		choice_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		# Make buttons left-aligned text
		choice_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		# Staggered fade-in animation for each button
		btn_center.modulate.a = 0
		Anima.Node(btn_center).anima_fade_in(0.4).anima_delay(0.5 + i * 0.1).play()

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

func _create_shuffled_options() -> Array:
	var options = [current_word["correct_sentence"]]
	options.append_array(current_word["wrong_sentences"])

	# Shuffle the options
	options.shuffle()

	# Find the correct answer's new index
	correct_index = options.find(current_word["correct_sentence"])

	return options

func _on_choice_pressed(choice_index: int) -> void:
	if selected_answer != -1:
		return  # Already answered

	selected_answer = choice_index
	var is_correct = (choice_index == correct_index)

	# Update all button styles based on correctness
	for i in range(choices_container.get_child_count()):
		var button_container = choices_container.get_child(i)
		if button_container is CenterContainer:
			var btn = button_container.get_child(0)
			if btn is Button:
				# Disable button to prevent further clicks
				btn.disabled = true
				btn.mouse_default_cursor_shape = Control.CURSOR_ARROW

				# Create new styles for feedback
				if i == correct_index:
					# Correct answer - turn green
					var correct_style = StyleBoxFlat.new()
					correct_style.bg_color = AssetLoader.get_color("success")  # Green
					correct_style.border_color = AssetLoader.get_color("figma_dark_brown")
					correct_style.border_width_left = 3
					correct_style.border_width_right = 3
					correct_style.border_width_top = 3
					correct_style.border_width_bottom = 6
					correct_style.corner_radius_top_left = 15
					correct_style.corner_radius_top_right = 15
					correct_style.corner_radius_bottom_left = 15
					correct_style.corner_radius_bottom_right = 15
					correct_style.shadow_size = 8
					correct_style.shadow_color = Color(0, 0, 0, 0.4)
					correct_style.shadow_offset = Vector2(0, 6)
					correct_style.content_margin_left = 25
					correct_style.content_margin_right = 25
					correct_style.content_margin_top = 18
					correct_style.content_margin_bottom = 18

					btn.add_theme_stylebox_override("normal", correct_style)
					btn.add_theme_stylebox_override("disabled", correct_style)
					btn.add_theme_color_override("font_color", Color.WHITE)
					btn.add_theme_color_override("font_disabled_color", Color.WHITE)

					# Celebrate if user selected correct answer
					if is_correct:
						Anima.Node(btn).anima_animation("tada", 0.6).play()

				elif i == choice_index and not is_correct:
					# User's wrong selection - red with extra border highlight
					var wrong_style = StyleBoxFlat.new()
					wrong_style.bg_color = AssetLoader.get_color("danger")  # Red
					wrong_style.border_color = AssetLoader.get_color("figma_dark_brown")
					wrong_style.border_width_left = 5
					wrong_style.border_width_right = 5
					wrong_style.border_width_top = 5
					wrong_style.border_width_bottom = 8  # Extra thick bottom border
					wrong_style.corner_radius_top_left = 15
					wrong_style.corner_radius_top_right = 15
					wrong_style.corner_radius_bottom_left = 15
					wrong_style.corner_radius_bottom_right = 15
					wrong_style.shadow_size = 8
					wrong_style.shadow_color = Color(0, 0, 0, 0.4)
					wrong_style.shadow_offset = Vector2(0, 6)
					wrong_style.content_margin_left = 25
					wrong_style.content_margin_right = 25
					wrong_style.content_margin_top = 18
					wrong_style.content_margin_bottom = 18

					btn.add_theme_stylebox_override("normal", wrong_style)
					btn.add_theme_stylebox_override("disabled", wrong_style)
					btn.add_theme_color_override("font_color", Color.WHITE)
					btn.add_theme_color_override("font_disabled_color", Color.WHITE)

					# Small horizontal shake for wrong answer
					Anima.Node(btn).anima_animation("shake_x", 0.4).play()

					# Show feedback for incorrect answer
					feedback_label.visible = true
					feedback_label.text = "Not quite. The correct sentence is: \"%s\"" % current_word["correct_sentence"]
					feedback_label.add_theme_color_override("font_color", Color("#FF9800"))  # Orange
					feedback_label.modulate.a = 0
					Anima.Node(feedback_label).anima_fade_in(0.4).play()

				else:
					# Other wrong answers - red (no extra border)
					var other_wrong_style = StyleBoxFlat.new()
					other_wrong_style.bg_color = AssetLoader.get_color("danger")  # Red
					other_wrong_style.border_color = AssetLoader.get_color("figma_dark_brown")
					other_wrong_style.border_width_left = 3
					other_wrong_style.border_width_right = 3
					other_wrong_style.border_width_top = 3
					other_wrong_style.border_width_bottom = 6
					other_wrong_style.corner_radius_top_left = 15
					other_wrong_style.corner_radius_top_right = 15
					other_wrong_style.corner_radius_bottom_left = 15
					other_wrong_style.corner_radius_bottom_right = 15
					other_wrong_style.shadow_size = 8
					other_wrong_style.shadow_color = Color(0, 0, 0, 0.4)
					other_wrong_style.shadow_offset = Vector2(0, 6)
					other_wrong_style.content_margin_left = 25
					other_wrong_style.content_margin_right = 25
					other_wrong_style.content_margin_top = 18
					other_wrong_style.content_margin_bottom = 18

					btn.add_theme_stylebox_override("normal", other_wrong_style)
					btn.add_theme_stylebox_override("disabled", other_wrong_style)
					btn.add_theme_color_override("font_color", Color.WHITE)
					btn.add_theme_color_override("font_disabled_color", Color.WHITE)

	# Award XP only if correct
	if is_correct:
		XPManager.reward_correct_answer()

	# Show next button with bounce
	next_button_container.visible = true
	next_button_container.modulate.a = 0
	Anima.Node(next_button_container).anima_fade_in(0.4).anima_delay(0.3).play()

func _on_next_pressed() -> void:
	print("Continue to next activity")
	answer_submitted_signal.emit()
	get_tree().change_scene_to_file("res://scenes/activities/SynonymAntonym.tscn")

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Home.tscn")
