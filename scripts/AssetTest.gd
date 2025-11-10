extends Control

## Test scene to verify all assets load correctly

func _ready() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = AssetLoader.get_color("parchment")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Center container
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	# VBox for content
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 30)
	center.add_child(vbox)

	# Title with header font
	var title = Label.new()
	title.text = "WORD WARRIORS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(title, 48)
	title.add_theme_color_override("font_color", AssetLoader.get_color("gold"))
	vbox.add_child(title)

	# Warrior sprite
	if AssetLoader.warrior_idle:
		var warrior = TextureRect.new()
		warrior.texture = AssetLoader.warrior_idle
		warrior.custom_minimum_size = Vector2(128, 128)
		warrior.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		warrior.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var warrior_container = CenterContainer.new()
		warrior_container.add_child(warrior)
		vbox.add_child(warrior_container)
	else:
		var error = Label.new()
		error.text = "⚠️ Warrior sprite not loaded"
		error.add_theme_color_override("font_color", Color.RED)
		vbox.add_child(error)

	# Body text with body font
	var subtitle = Label.new()
	subtitle.text = "Medieval Vocabulary Adventure"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_body_font(subtitle, 28)
	subtitle.add_theme_color_override("font_color", AssetLoader.get_color("text_dark"))
	vbox.add_child(subtitle)

	# Color palette test
	var color_card = PanelContainer.new()
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color.WHITE
	card_style.corner_radius_top_left = 15
	card_style.corner_radius_top_right = 15
	card_style.corner_radius_bottom_left = 15
	card_style.corner_radius_bottom_right = 15
	card_style.content_margin_left = 20
	card_style.content_margin_right = 20
	card_style.content_margin_top = 20
	card_style.content_margin_bottom = 20
	color_card.add_theme_stylebox_override("panel", card_style)
	vbox.add_child(color_card)

	var color_vbox = VBoxContainer.new()
	color_vbox.add_theme_constant_override("separation", 10)
	color_card.add_child(color_vbox)

	var color_title = Label.new()
	color_title.text = "Color Palette Test"
	AssetLoader.apply_body_font(color_title, 20)
	color_title.add_theme_color_override("font_color", AssetLoader.get_color("text_dark"))
	color_vbox.add_child(color_title)

	# Test each color
	for color_name in ["gold", "stone_dark", "success", "danger"]:
		var color_test = HBoxContainer.new()
		color_test.add_theme_constant_override("separation", 10)
		color_vbox.add_child(color_test)

		var color_swatch = ColorRect.new()
		color_swatch.color = AssetLoader.get_color(color_name)
		color_swatch.custom_minimum_size = Vector2(40, 40)
		color_test.add_child(color_swatch)

		var color_label = Label.new()
		color_label.text = color_name
		AssetLoader.apply_body_font(color_label, 16)
		color_test.add_child(color_label)

	# Icons test
	var icons = Label.new()
	icons.text = "Icons: %s %s %s %s" % [AssetLoader.STAR_EMOJI, AssetLoader.SWORD_EMOJI, AssetLoader.SHIELD_EMOJI, AssetLoader.TROPHY_EMOJI]
	icons.add_theme_font_size_override("font_size", 48)
	icons.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icons)

	print("Asset test complete! Check the scene output.")
