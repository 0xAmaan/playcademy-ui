extends Control

## Flashcard activity - shows word, definition, and example
## Mock data for now (no backend)

# Mock word data
var current_word = {
	"word": "magnificent",
	"definition": "extremely beautiful, elaborate, or impressive",
	"example": "The sunset over the ocean was absolutely magnificent.",
	"emoji": "✨"
}

var word_index: int = 0
var total_words: int = 5

signal next_word

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	# Background - parchment
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
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	# XP bar at top
	var xp_bar = PanelContainer.new()
	xp_bar.set_script(load("res://scripts/ui/XPBar.gd"))
	var xp_container = CenterContainer.new()
	xp_container.add_child(xp_bar)
	vbox.add_child(xp_container)

	# Spacer
	var spacer1 = Control.new()
	spacer1.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer1)

	# Card with word content - darker border like Figma
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(700, 500)

	# Card styling with darker border
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color.WHITE
	card_style.border_color = AssetLoader.get_color("figma_dark_brown")  # Darker border
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
	card_style.content_margin_left = 50
	card_style.content_margin_right = 50
	card_style.content_margin_top = 40
	card_style.content_margin_bottom = 40
	card.add_theme_stylebox_override("panel", card_style)

	var card_container = CenterContainer.new()
	card_container.add_child(card)
	vbox.add_child(card_container)

	# Card content
	var card_vbox = VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 25)
	card.add_child(card_vbox)

	# Emoji FIRST (above word)
	var emoji_label = Label.new()
	emoji_label.text = current_word["emoji"]
	emoji_label.add_theme_font_size_override("font_size", 80)
	emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_vbox.add_child(emoji_label)

	# Word (pixel font, gold color)
	var word_label = Label.new()
	word_label.text = current_word["word"]
	AssetLoader.apply_header_font(word_label, 48)
	word_label.add_theme_color_override("font_color", AssetLoader.get_color("figma_gold"))
	word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_vbox.add_child(word_label)

	# Definition (body font, dark text)
	var def_label = Label.new()
	def_label.text = current_word["definition"]
	AssetLoader.apply_body_font(def_label, 22)
	def_label.add_theme_color_override("font_color", Color.BLACK)
	def_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	def_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_vbox.add_child(def_label)

	# Example sentence in bordered box (like Figma)
	var example_panel = PanelContainer.new()
	var example_style = StyleBoxFlat.new()
	example_style.bg_color = AssetLoader.get_color("parchment")
	example_style.border_color = AssetLoader.get_color("figma_medium_brown")
	example_style.border_width_left = 2
	example_style.border_width_right = 2
	example_style.border_width_top = 2
	example_style.border_width_bottom = 2
	example_style.corner_radius_top_left = 12
	example_style.corner_radius_top_right = 12
	example_style.corner_radius_bottom_left = 12
	example_style.corner_radius_bottom_right = 12
	example_style.content_margin_left = 20
	example_style.content_margin_right = 20
	example_style.content_margin_top = 15
	example_style.content_margin_bottom = 15
	example_panel.add_theme_stylebox_override("panel", example_style)

	var example_label = Label.new()
	example_label.text = '"%s"' % current_word["example"]
	AssetLoader.apply_body_font(example_label, 18)
	example_label.add_theme_color_override("font_color", AssetLoader.get_color("figma_dark_brown"))
	example_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	example_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	example_panel.add_child(example_label)
	card_vbox.add_child(example_panel)

	# Spacer before button
	var btn_spacer = Control.new()
	btn_spacer.custom_minimum_size = Vector2(0, 20)
	card_vbox.add_child(btn_spacer)

	# Got it button INSIDE card - darker brown color
	var btn_container = CenterContainer.new()
	card_vbox.add_child(btn_container)

	var got_it_btn = Button.new()
	got_it_btn.pressed.connect(_on_got_it_pressed)
	got_it_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	got_it_btn.focus_mode = Control.FOCUS_NONE
	btn_container.add_child(got_it_btn)

	# Button styling - darker brown/tan like Figma
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = AssetLoader.get_color("figma_gold")
	btn_style.corner_radius_top_left = 12
	btn_style.corner_radius_top_right = 12
	btn_style.corner_radius_bottom_left = 12
	btn_style.corner_radius_bottom_right = 12
	btn_style.shadow_size = 4
	btn_style.shadow_color = Color(0, 0, 0, 0.2)
	btn_style.shadow_offset = Vector2(0, 3)
	btn_style.content_margin_left = 40
	btn_style.content_margin_right = 40
	btn_style.content_margin_top = 15
	btn_style.content_margin_bottom = 15

	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = AssetLoader.get_color("figma_gold_light")

	var btn_pressed = btn_style.duplicate()
	btn_pressed.bg_color = AssetLoader.get_color("figma_gold").darkened(0.1)

	got_it_btn.add_theme_stylebox_override("normal", btn_style)
	got_it_btn.add_theme_stylebox_override("hover", btn_hover)
	got_it_btn.add_theme_stylebox_override("pressed", btn_pressed)

	await get_tree().process_frame
	got_it_btn.text = "Got it! →"
	AssetLoader.apply_header_font(got_it_btn, 20)
	got_it_btn.add_theme_color_override("font_color", AssetLoader.get_color("figma_dark_brown"))
	got_it_btn.custom_minimum_size = Vector2(200, 55)

	# Spacer
	var spacer2 = Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer2)

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

func _on_got_it_pressed() -> void:
	print("Next word!")

	# Award XP for viewing flashcard
	XPManager.add_xp(5)

	# Wait for XP animation to play before changing scenes
	await get_tree().create_timer(1.0).timeout

	next_word.emit()
	# Go to multiple choice activity
	get_tree().change_scene_to_file("res://scenes/activities/MultipleChoice.tscn")

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Home.tscn")
