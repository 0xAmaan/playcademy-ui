extends Control

## Summary/Results screen shown after completing a session
## Shows stats and completion message

# Mock session data
var session_data = {
	"words_practiced": 5,
	"correct_answers": 4,
	"time_spent": "3:45",
	"new_words_learned": 2
}

signal restart_pressed
signal quit_pressed

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	# Background - parchment color
	var bg = ColorRect.new()
	bg.color = AssetLoader.get_color("parchment")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Main container with margin
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 60)  # More bottom margin for buttons
	add_child(margin)

	# VBox for content
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	# Trophy emoji with bounce animation
	var trophy = Label.new()
	trophy.text = AssetLoader.TROPHY_EMOJI
	trophy.add_theme_font_size_override("font_size", 100)
	trophy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(trophy)

	# Animate trophy bounce in
	trophy.scale = Vector2(0, 0)
	var trophy_tween = create_tween()
	trophy_tween.tween_property(trophy, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	trophy_tween.tween_property(trophy, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC)

	# Victory title with fade in
	var title = Label.new()
	title.text = "VICTORY!"
	AssetLoader.apply_header_font(title, 56)
	title.add_theme_color_override("font_color", AssetLoader.get_color("gold"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Animate title fade and scale
	title.modulate.a = 0
	var title_tween = create_tween()
	title_tween.tween_property(title, "modulate:a", 1.0, 0.5).set_delay(0.3)

	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "Quest Completed"
	AssetLoader.apply_body_font(subtitle, 24)
	subtitle.add_theme_color_override("font_color", AssetLoader.get_color("text_dark"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)

	# Stats grid - 2 rows of cards
	var stats_container = VBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 20)
	vbox.add_child(stats_container)

	# First row: 3 main stats (Total XP, Accuracy, Time)
	var row1 = HBoxContainer.new()
	row1.add_theme_constant_override("separation", 20)
	row1.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_container.add_child(row1)

	# Calculate accuracy
	var accuracy = (float(session_data["correct_answers"]) / float(session_data["words_practiced"])) * 100.0
	var accuracy_str = "%.0f%%" % accuracy

	# Card 1: Total XP (calculated from correct answers)
	var total_xp = session_data["correct_answers"] * 10
	var xp_card = await _create_stat_card("⭐", "Total XP", str(total_xp), AssetLoader.get_color("figma_gold"))
	row1.add_child(xp_card)

	# Card 2: Accuracy
	var accuracy_card = await _create_stat_card("🎯", "Accuracy", accuracy_str, Color("#58D68D"))
	row1.add_child(accuracy_card)

	# Card 3: Time
	var time_card = await _create_stat_card("⏱️", "Time", session_data["time_spent"], Color("#5DADE2"))
	row1.add_child(time_card)

	# Second row: 2 detail stats (Words Practiced, New Words)
	var row2 = HBoxContainer.new()
	row2.add_theme_constant_override("separation", 20)
	row2.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_container.add_child(row2)

	# Card 4: Words Practiced
	var words_card = await _create_stat_card(AssetLoader.SWORD_EMOJI, "Words Practiced", str(session_data["words_practiced"]), Color("#E67E22"))
	row2.add_child(words_card)

	# Card 5: New Words Mastered
	var new_words_card = await _create_stat_card(AssetLoader.STAR_EMOJI, "New Words Mastered", str(session_data["new_words_learned"]), Color("#9B59B6"))
	row2.add_child(new_words_card)

	# Spacer between stats cards and buttons (50px total margin, accounting for vbox separation)
	var button_spacer = Control.new()
	button_spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(button_spacer)

	# Buttons - medieval styled
	var btn_hbox = HBoxContainer.new()
	btn_hbox.add_theme_constant_override("separation", 50)
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_hbox)

	# Try again button (gold)
	var again_btn = Button.new()
	again_btn.pressed.connect(_on_try_again_pressed)
	again_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	again_btn.focus_mode = Control.FOCUS_NONE  # Remove focus outline
	btn_hbox.add_child(again_btn)

	var again_style = StyleBoxFlat.new()
	again_style.bg_color = AssetLoader.get_color("gold")
	again_style.corner_radius_top_left = 15
	again_style.corner_radius_top_right = 15
	again_style.corner_radius_bottom_left = 15
	again_style.corner_radius_bottom_right = 15
	again_style.shadow_size = 6
	again_style.shadow_color = Color(0, 0, 0, 0.3)
	again_style.shadow_offset = Vector2(0, 4)
	again_style.content_margin_left = 30
	again_style.content_margin_right = 30
	again_style.content_margin_top = 20
	again_style.content_margin_bottom = 20

	# Hover state - slightly brighter gold, maintain rounded corners
	var again_hover = again_style.duplicate()
	again_hover.bg_color = AssetLoader.get_color("gold").lightened(0.1)
	again_hover.shadow_size = 8
	again_hover.shadow_offset = Vector2(0, 6)

	# Pressed state - darker gold, maintain rounded corners
	var again_pressed = again_style.duplicate()
	again_pressed.bg_color = AssetLoader.get_color("gold").darkened(0.15)
	again_pressed.shadow_size = 4
	again_pressed.shadow_offset = Vector2(0, 2)

	again_btn.add_theme_stylebox_override("normal", again_style)
	again_btn.add_theme_stylebox_override("hover", again_hover)
	again_btn.add_theme_stylebox_override("pressed", again_pressed)

	await get_tree().process_frame
	again_btn.text = "%s Quest Again" % AssetLoader.SWORD_EMOJI
	AssetLoader.apply_header_font(again_btn, 20)
	again_btn.add_theme_color_override("font_color", AssetLoader.get_color("text_dark"))
	again_btn.custom_minimum_size = Vector2(250, 70)

	# Home button (stone)
	var home_btn = Button.new()
	home_btn.pressed.connect(_on_home_pressed)
	home_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	home_btn.focus_mode = Control.FOCUS_NONE  # Remove focus outline
	btn_hbox.add_child(home_btn)

	var home_style = StyleBoxFlat.new()
	home_style.bg_color = AssetLoader.get_color("stone_light")
	home_style.corner_radius_top_left = 15
	home_style.corner_radius_top_right = 15
	home_style.corner_radius_bottom_left = 15
	home_style.corner_radius_bottom_right = 15
	home_style.shadow_size = 6
	home_style.shadow_color = Color(0, 0, 0, 0.3)
	home_style.shadow_offset = Vector2(0, 4)
	home_style.content_margin_left = 30
	home_style.content_margin_right = 30
	home_style.content_margin_top = 20
	home_style.content_margin_bottom = 20

	# Hover state - darker stone (not gray), maintain rounded corners
	var home_hover = home_style.duplicate()
	home_hover.bg_color = AssetLoader.get_color("stone_dark")
	home_hover.shadow_size = 8
	home_hover.shadow_offset = Vector2(0, 6)

	# Pressed state - even darker stone, maintain rounded corners
	var home_pressed = home_style.duplicate()
	home_pressed.bg_color = AssetLoader.get_color("stone_dark").darkened(0.1)
	home_pressed.shadow_size = 4
	home_pressed.shadow_offset = Vector2(0, 2)

	home_btn.add_theme_stylebox_override("normal", home_style)
	home_btn.add_theme_stylebox_override("hover", home_hover)
	home_btn.add_theme_stylebox_override("pressed", home_pressed)

	await get_tree().process_frame
	home_btn.text = "Return Home"
	AssetLoader.apply_header_font(home_btn, 20)
	home_btn.add_theme_color_override("font_color", AssetLoader.get_color("text_light"))
	home_btn.custom_minimum_size = Vector2(250, 70)

func _create_stat_card(icon: String, label_text: String, value_text: String, accent_color: Color) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 155)  # Even smaller cards

	# Premium gradient card with rich depth
	var card_style = StyleBoxFlat.new()

	# Darker, richer base colors for more contrast
	var base_very_dark = Color("#2A1F17")  # Very dark brown
	var base_dark = Color("#362816")  # Dark brown with warmth

	# Use the base dark as the main color
	card_style.bg_color = base_dark

	# Rounded corners with larger radius for modern feel
	card_style.set_corner_radius_all(24)

	# Double border effect - inner lighter accent border
	card_style.border_color = accent_color.darkened(0.2)
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2

	# Dramatic 3D shadow with multiple layers
	card_style.shadow_size = 22
	card_style.shadow_color = Color(0, 0, 0, 0.7)
	card_style.shadow_offset = Vector2(0, 12)

	card_style.content_margin_left = 22
	card_style.content_margin_right = 22
	card_style.content_margin_top = 22
	card_style.content_margin_bottom = 24  # Smaller padding

	card_style.draw_center = true
	card.add_theme_stylebox_override("panel", card_style)

	# Card content (no gradient overlays)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)  # Tighter spacing
	card.add_child(vbox)

	# Icon with dramatic glowing background
	var icon_container = CenterContainer.new()
	vbox.add_child(icon_container)

	var icon_bg = PanelContainer.new()
	icon_bg.custom_minimum_size = Vector2(70, 70)  # Smaller icon circle
	icon_container.add_child(icon_bg)

	# Icon background - vibrant glowing circle
	var icon_bg_style = StyleBoxFlat.new()
	icon_bg_style.bg_color = accent_color.lightened(0.15)
	icon_bg_style.border_color = accent_color.lightened(0.45)
	icon_bg_style.border_width_left = 3
	icon_bg_style.border_width_right = 3
	icon_bg_style.border_width_top = 3
	icon_bg_style.border_width_bottom = 3
	icon_bg_style.corner_radius_top_left = 35
	icon_bg_style.corner_radius_top_right = 35
	icon_bg_style.corner_radius_bottom_left = 35
	icon_bg_style.corner_radius_bottom_right = 35
	# Dramatic glow effect with larger shadow
	icon_bg_style.shadow_size = 14
	icon_bg_style.shadow_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.7)
	icon_bg_style.shadow_offset = Vector2(0, 0)  # Centered glow
	icon_bg.add_theme_stylebox_override("panel", icon_bg_style)

	var icon_label = Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override("font_size", 42)  # Smaller icon
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_bg.add_child(icon_label)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)  # Smaller spacer
	vbox.add_child(spacer)

	# Value (big number) with dramatic styling
	var value_label = Label.new()
	value_label.text = value_text
	AssetLoader.apply_header_font(value_label, 48)  # Smaller value text
	value_label.add_theme_color_override("font_color", accent_color.lightened(0.5))
	# Strong outline for dramatic pop
	value_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	value_label.add_theme_constant_override("outline_size", 3)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(value_label)

	# Small spacer between value and description
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 2)
	vbox.add_child(spacer2)

	# Label (description) - warm light text
	var desc_label = Label.new()
	desc_label.text = label_text
	AssetLoader.apply_body_font(desc_label, 16)  # Smaller description text
	desc_label.add_theme_color_override("font_color", Color("#E8D4B8"))  # Warmer, lighter tan
	# Subtle outline for better readability
	desc_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	desc_label.add_theme_constant_override("outline_size", 1)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	# Animate card with smooth staggered entrance
	card.modulate.a = 0
	card.scale = Vector2(0.85, 0.85)
	card.position.y += 15  # Start slightly below

	# Shorter, smoother delay
	var card_delay = randf_range(0.1, 0.3)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "modulate:a", 1.0, 0.3).set_delay(card_delay).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.4).set_delay(card_delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "position:y", card.position.y - 15, 0.4).set_delay(card_delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Don't wait for floating animation - just return the card
	return card

func _on_try_again_pressed() -> void:
	print("Try again pressed")
	restart_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/Home.tscn")

func _on_home_pressed() -> void:
	print("Home pressed")
	quit_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/Home.tscn")
