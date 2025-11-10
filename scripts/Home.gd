extends Control

## Home/Welcome screen - Figma Design Implementation
## Shows character selection, stats, daily quest, and start button

signal start_session_pressed
signal character_selected(character_id: String)

# Character data matching Figma design
const CHARACTERS = [
	{
		"id": "wizard",
		"emoji": "🧙‍♂️",
		"name": "Wizard",
		"description": "Magic Words",
		"level": 5,
		"color": "char_purple",
		"xp_current": 340,
		"xp_max": 500,
		"unlocked": true
	},
	{
		"id": "knight",
		"emoji": "⚔️",
		"name": "Knight",
		"description": "Strong Vocab",
		"level": 1,
		"color": "char_red",
		"xp_current": 0,
		"xp_max": 100,
		"unlocked": true
	},
	{
		"id": "archer",
		"emoji": "🏹",
		"name": "Archer",
		"description": "Quick Thinking",
		"level": 1,
		"color": "char_green",
		"xp_current": 0,
		"xp_max": 100,
		"unlocked": false
	},
	{
		"id": "guardian",
		"emoji": "🛡️",
		"name": "Guardian",
		"description": "Defense Master",
		"level": 1,
		"color": "char_blue",
		"xp_current": 0,
		"xp_max": 100,
		"unlocked": false
	}
]

var selected_character_id: String = "wizard"  # Default selection
var character_card_panels: Array[PanelContainer] = []  # Track panels for border updates

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	# Background - Figma parchment color
	var bg = ColorRect.new()
	bg.color = AssetLoader.get_color("figma_bg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Decorative clouds in background
	_add_decorative_clouds(bg)

	# Main container - use MarginContainer for proper centering
	var main_margin = MarginContainer.new()
	main_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_margin.add_theme_constant_override("margin_left", 0)
	main_margin.add_theme_constant_override("margin_right", 0)
	add_child(main_margin)

	# Main VBox for all content
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 30)
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_margin.add_child(main_vbox)

	# Add top margin (increased to prevent title overlap with stats panel)
	var top_spacer = Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 120)
	main_vbox.add_child(top_spacer)

	# Stats Panel - positioned absolutely to align with X button
	_create_stats_panel_absolute()

	# Title: "WORD WARRIORS"
	var title_container = CenterContainer.new()
	title_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(title_container)

	var title = Label.new()
	title.text = "WORD WARRIORS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(title, 60)
	title.add_theme_color_override("font_color", AssetLoader.get_color("figma_gold"))
	title_container.add_child(title)

	# Subtitle: "CHOOSE YOUR HERO"
	var subtitle_container = CenterContainer.new()
	subtitle_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(subtitle_container)

	var subtitle = Label.new()
	subtitle.text = "CHOOSE YOUR HERO"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(subtitle, 20)
	subtitle.add_theme_color_override("font_color", AssetLoader.get_color("figma_dark_brown"))
	subtitle_container.add_child(subtitle)

	# Character Grid
	_create_character_grid(main_vbox)

	# Daily Quest Card
	_create_daily_quest(main_vbox)

	# Start Adventure Button
	_create_start_button(main_vbox)

	# Bottom spacer
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 60)
	main_vbox.add_child(bottom_spacer)

	# Decorative grass at bottom
	_add_decorative_grass()

	# Add pause/exit button in top-left corner
	_add_pause_button()

	# Animate entrance
	_animate_entrance(title, subtitle)

func _create_stats_panel_absolute() -> void:
	# Create stats container positioned absolutely in top-right
	var stats_container = HBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 15)
	stats_container.position = Vector2(get_viewport_rect().size.x - 420, 20)  # Align with X button (y=20)
	add_child(stats_container)

	# Level stat
	var level_box = _create_stat_box("LEVEL", str(XPManager.current_level), AssetLoader.get_color("figma_gold"))
	stats_container.add_child(level_box)

	# Coins stat
	var coins_box = _create_stat_box("COINS", "127 " + AssetLoader.COIN_EMOJI, AssetLoader.get_color("figma_gold_light"))
	stats_container.add_child(coins_box)

	# Streak stat with special orange color
	var streak_box = _create_stat_box("STREAK", "7 " + AssetLoader.FIRE_EMOJI, AssetLoader.get_color("figma_orange"))
	stats_container.add_child(streak_box)

	# Animate stats panel with stagger using Tween
	level_box.modulate.a = 0
	coins_box.modulate.a = 0
	streak_box.modulate.a = 0

	var level_tween = create_tween()
	level_tween.tween_interval(0.2)
	level_tween.tween_property(level_box, "modulate:a", 1.0, 0.4)

	var coins_tween = create_tween()
	coins_tween.tween_interval(0.3)
	coins_tween.tween_property(coins_box, "modulate:a", 1.0, 0.4)

	var streak_tween = create_tween()
	streak_tween.tween_interval(0.4)
	streak_tween.tween_property(streak_box, "modulate:a", 1.0, 0.4)

func _create_stats_panel(parent: HBoxContainer) -> void:
	var stats_container = HBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 15)
	parent.add_child(stats_container)

	# Level stat
	var level_box = _create_stat_box("LEVEL", str(XPManager.current_level), AssetLoader.get_color("figma_gold"))
	stats_container.add_child(level_box)

	# Coins stat
	var coins_box = _create_stat_box("COINS", "127 " + AssetLoader.COIN_EMOJI, AssetLoader.get_color("figma_gold_light"))
	stats_container.add_child(coins_box)

	# Streak stat with special orange color
	var streak_box = _create_stat_box("STREAK", "7 " + AssetLoader.FIRE_EMOJI, AssetLoader.get_color("figma_orange"))
	stats_container.add_child(streak_box)

	# Animate stats panel with stagger using Tween
	level_box.modulate.a = 0
	coins_box.modulate.a = 0
	streak_box.modulate.a = 0

	var level_tween = create_tween()
	level_tween.tween_interval(0.2)
	level_tween.tween_property(level_box, "modulate:a", 1.0, 0.4)

	var coins_tween = create_tween()
	coins_tween.tween_interval(0.3)
	coins_tween.tween_property(coins_box, "modulate:a", 1.0, 0.4)

	var streak_tween = create_tween()
	streak_tween.tween_interval(0.4)
	streak_tween.tween_property(streak_box, "modulate:a", 1.0, 0.4)

func _create_stat_box(label_text: String, value_text: String, value_color: Color) -> PanelContainer:
	var panel = PanelContainer.new()

	# Dark background style
	var style = StyleBoxFlat.new()
	style.bg_color = AssetLoader.get_color("figma_dark_brown")
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_color = AssetLoader.get_color("figma_medium_brown")
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 15
	style.content_margin_bottom = 15

	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	panel.add_child(vbox)

	# Label
	var label = Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(label, 10)
	label.add_theme_color_override("font_color", AssetLoader.get_color("figma_light_brown"))
	vbox.add_child(label)

	# Value
	var value = Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(value, 20)
	value.add_theme_color_override("font_color", value_color)
	vbox.add_child(value)

	return panel

func _create_character_grid(parent: VBoxContainer) -> void:
	# Center the character grid
	var grid_center = CenterContainer.new()
	grid_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(grid_center)

	var grid = HBoxContainer.new()
	grid.add_theme_constant_override("separation", 15)
	grid_center.add_child(grid)

	# Clear previous panel references
	character_card_panels.clear()

	# Create character cards
	for i in range(CHARACTERS.size()):
		var char_data = CHARACTERS[i]
		var card = _create_character_card(char_data, i)
		grid.add_child(card)
		character_card_panels.append(card)  # Store for border updates

func _create_character_card(char_data: Dictionary, index: int) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(180, 200)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS

	# Card style
	var is_selected = char_data["id"] == selected_character_id
	var style = StyleBoxFlat.new()
	style.bg_color = AssetLoader.get_color("figma_dark_brown")
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	# Thicker, brighter gold border for selected character
	if is_selected:
		style.border_color = AssetLoader.get_color("figma_gold_light")
		style.border_width_left = 5
		style.border_width_right = 5
		style.border_width_top = 5
		style.border_width_bottom = 5
	else:
		style.border_color = AssetLoader.get_color("figma_medium_brown")
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
	style.shadow_size = 8
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_offset = Vector2(0, 4)

	panel.add_theme_stylebox_override("panel", style)

	# Store character data
	panel.set_meta("character_id", char_data["id"])
	panel.set_meta("character_index", index)
	panel.set_meta("is_flipping", false)  # Track if card is currently animating
	panel.set_meta("showing_back", false)  # Track current side

	# FRONT SIDE - visible by default
	var front = _create_card_front(char_data)
	front.name = "Front"
	panel.add_child(front)

	# BACK SIDE - hidden by default
	var back = _create_card_back(char_data)
	back.name = "Back"
	back.visible = false
	panel.add_child(back)

	# Add button for all characters (both locked and unlocked)
	var button = Button.new()
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.flat = true
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.focus_mode = Control.FOCUS_NONE  # Disable focus outline

	# Hover triggers card flip for ALL characters
	button.mouse_entered.connect(_on_character_card_hover_enter.bind(char_data["id"], panel))
	button.mouse_exited.connect(_on_character_card_hover_exit.bind(panel))

	# Click selects character (only if unlocked)
	if char_data.get("unlocked", true):
		button.pressed.connect(_on_character_card_clicked.bind(char_data["id"]))

	panel.add_child(button)

	# Add locked overlay if character is not unlocked (render AFTER button so it's visible)
	if not char_data.get("unlocked", true):
		var overlay = ColorRect.new()
		overlay.color = Color(0, 0, 0, 0.7)  # Dark semi-transparent overlay
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let button below handle input
		panel.add_child(overlay)

		# Add lock icon/text
		var lock_label = Label.new()
		lock_label.text = "🔒"
		lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		lock_label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let button below handle input
		AssetLoader.apply_header_font(lock_label, 40)
		panel.add_child(lock_label)

	# Stagger entrance animation
	panel.modulate.a = 0
	panel.scale = Vector2(0.95, 0.95)

	# Use Tween for multi-property animation with delay
	var tween = create_tween()
	tween.tween_interval(0.5 + index * 0.1)  # Delay
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.4)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.4)

	return panel

func _create_card_front(char_data: Dictionary) -> VBoxContainer:
	# Front side: emoji, name, level badge, description
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)

	# Level badge
	var level_badge = Label.new()
	level_badge.text = "LVL " + str(char_data["level"])
	AssetLoader.apply_header_font(level_badge, 12)
	level_badge.add_theme_color_override("font_color", AssetLoader.get_color("figma_dark_brown"))
	level_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var level_bg = PanelContainer.new()
	var level_style = StyleBoxFlat.new()
	level_style.bg_color = AssetLoader.get_color("figma_gold")
	level_style.corner_radius_top_left = 8
	level_style.corner_radius_top_right = 8
	level_style.corner_radius_bottom_left = 8
	level_style.corner_radius_bottom_right = 8
	level_style.content_margin_left = 10
	level_style.content_margin_right = 10
	level_style.content_margin_top = 5
	level_style.content_margin_bottom = 5
	level_bg.add_theme_stylebox_override("panel", level_style)
	level_bg.add_child(level_badge)
	vbox.add_child(level_bg)

	# Character emoji
	var emoji = Label.new()
	emoji.text = char_data["emoji"]
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(emoji, 80)
	vbox.add_child(emoji)

	# Character name
	var name_label = Label.new()
	name_label.text = char_data["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(name_label, 18)
	name_label.add_theme_color_override("font_color", AssetLoader.get_color(char_data["color"]))
	vbox.add_child(name_label)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 5)
	vbox.add_child(spacer)

	# Description
	var desc_label = Label.new()
	desc_label.text = char_data["description"]
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(desc_label, 10)
	desc_label.add_theme_color_override("font_color", AssetLoader.get_color("figma_light_brown"))
	vbox.add_child(desc_label)

	# Bottom spacer
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(bottom_spacer)

	return vbox

func _create_card_back(char_data: Dictionary) -> VBoxContainer:
	# Back side: larger emoji, special ability, XP bar
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)

	# Top spacer
	var top_spacer = Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(top_spacer)

	# Larger emoji
	var emoji = Label.new()
	emoji.text = char_data["emoji"]
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(emoji, 60)
	vbox.add_child(emoji)

	# "SPECIAL ABILITY" label
	var ability_header = Label.new()
	ability_header.text = "ABILITY"
	ability_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(ability_header, 10)
	ability_header.add_theme_color_override("font_color", AssetLoader.get_color("figma_gold"))
	vbox.add_child(ability_header)

	# Description
	var desc = Label.new()
	desc.text = char_data["description"]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	AssetLoader.apply_header_font(desc, 9)
	desc.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(desc)

	# XP section
	var xp_label = Label.new()
	xp_label.text = "XP: %d/%d" % [char_data["xp_current"], char_data["xp_max"]]
	xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	AssetLoader.apply_header_font(xp_label, 8)
	xp_label.add_theme_color_override("font_color", AssetLoader.get_color("figma_light_brown"))
	vbox.add_child(xp_label)

	# XP Progress bar
	var progress_bg = PanelContainer.new()
	progress_bg.custom_minimum_size = Vector2(140, 12)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = AssetLoader.get_color("figma_darker_brown")
	bg_style.corner_radius_top_left = 6
	bg_style.corner_radius_top_right = 6
	bg_style.corner_radius_bottom_left = 6
	bg_style.corner_radius_bottom_right = 6
	progress_bg.add_theme_stylebox_override("panel", bg_style)

	var xp_percent = float(char_data["xp_current"]) / float(char_data["xp_max"])
	var progress_fill = ColorRect.new()
	progress_fill.color = AssetLoader.get_color("figma_gold")
	progress_fill.custom_minimum_size = Vector2(140 * xp_percent, 12)
	progress_fill.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

	var fill_margin = MarginContainer.new()
	fill_margin.add_theme_constant_override("margin_left", 1)
	fill_margin.add_theme_constant_override("margin_top", 1)
	fill_margin.add_theme_constant_override("margin_bottom", 1)
	progress_bg.add_child(fill_margin)
	fill_margin.add_child(progress_fill)

	var progress_center = CenterContainer.new()
	progress_center.add_child(progress_bg)
	vbox.add_child(progress_center)

	# Bottom spacer
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(bottom_spacer)

	return vbox

func _on_character_card_clicked(character_id: String) -> void:
	# Select the character
	selected_character_id = character_id
	character_selected.emit(character_id)
	print("Selected character: ", character_id)

	# Refresh character cards to update borders
	_refresh_character_borders()

func _refresh_character_borders() -> void:
	# Update all character card borders to reflect new selection
	for i in range(character_card_panels.size()):
		var panel = character_card_panels[i]
		var char_data = CHARACTERS[i]
		var is_selected = char_data["id"] == selected_character_id

		# Create new style with updated border
		var style = StyleBoxFlat.new()
		style.bg_color = AssetLoader.get_color("figma_dark_brown")
		style.corner_radius_top_left = 15
		style.corner_radius_top_right = 15
		style.corner_radius_bottom_left = 15
		style.corner_radius_bottom_right = 15

		# Thicker, brighter gold border for selected character
		if is_selected:
			style.border_color = AssetLoader.get_color("figma_gold_light")
			style.border_width_left = 5
			style.border_width_right = 5
			style.border_width_top = 5
			style.border_width_bottom = 5
		else:
			style.border_color = AssetLoader.get_color("figma_medium_brown")
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2

		style.shadow_size = 8
		style.shadow_color = Color(0, 0, 0, 0.3)
		style.shadow_offset = Vector2(0, 4)

		panel.add_theme_stylebox_override("panel", style)

func _on_character_card_hover_enter(_character_id: String, panel: PanelContainer) -> void:
	# Only flip if not already showing back and not currently animating
	if panel.get_meta("is_flipping") or panel.get_meta("showing_back"):
		return

	_flip_card(panel, true)

func _on_character_card_hover_exit(panel: PanelContainer) -> void:
	# Only flip if not already showing front and not currently animating
	if panel.get_meta("is_flipping") or not panel.get_meta("showing_back"):
		return

	_flip_card(panel, false)

func _flip_card(panel: PanelContainer, show_back: bool) -> void:
	# Get the front and back containers
	var front = panel.get_node_or_null("Front")
	var back = panel.get_node_or_null("Back")

	if not front or not back:
		return

	# Mark as flipping to prevent re-triggering
	panel.set_meta("is_flipping", true)

	# Simple cross-fade between front and back
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(true)

	if show_back:
		# Make back visible first
		back.visible = true
		back.modulate.a = 0.0

		# Fade out front, fade in back
		tween.tween_property(front, "modulate:a", 0.0, 0.25)
		tween.tween_property(back, "modulate:a", 1.0, 0.25)

		tween.tween_callback(func():
			front.visible = false
			front.modulate.a = 1.0  # Reset for next time
			panel.set_meta("is_flipping", false)
			panel.set_meta("showing_back", true)
		).set_delay(0.25)
	else:
		# Make front visible first
		front.visible = true
		front.modulate.a = 0.0

		# Fade out back, fade in front
		tween.tween_property(back, "modulate:a", 0.0, 0.25)
		tween.tween_property(front, "modulate:a", 1.0, 0.25)

		tween.tween_callback(func():
			back.visible = false
			back.modulate.a = 1.0  # Reset for next time
			panel.set_meta("is_flipping", false)
			panel.set_meta("showing_back", false)
		).set_delay(0.25)

func _create_daily_quest(parent: VBoxContainer) -> void:
	# Center the daily quest card
	var quest_center = CenterContainer.new()
	quest_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(quest_center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(700, 0)  # Set max width

	# Quest card style
	var style = StyleBoxFlat.new()
	style.bg_color = AssetLoader.get_color("figma_dark_brown")
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.border_color = AssetLoader.get_color("figma_medium_brown")
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.shadow_size = 10
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_offset = Vector2(0, 5)
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 25
	style.content_margin_bottom = 25

	panel.add_theme_stylebox_override("panel", style)
	quest_center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	panel.add_child(vbox)

	# Header with star and gift emojis
	var header_hbox = HBoxContainer.new()
	header_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	header_hbox.add_theme_constant_override("separation", 15)
	vbox.add_child(header_hbox)

	var star = Label.new()
	star.text = AssetLoader.STAR_EMOJI
	AssetLoader.apply_header_font(star, 30)
	header_hbox.add_child(star)

	var title = Label.new()
	title.text = "DAILY QUESTS"
	AssetLoader.apply_header_font(title, 20)
	title.add_theme_color_override("font_color", AssetLoader.get_color("figma_gold"))
	header_hbox.add_child(title)

	var gift = Label.new()
	gift.text = AssetLoader.GIFT_EMOJI
	AssetLoader.apply_header_font(gift, 30)
	header_hbox.add_child(gift)

	# Quest 1: Complete 1 lesson
	_create_quest_row(vbox, "Complete 1 lesson", 0, 1)

	# Quest 2: Learn 5 words
	_create_quest_row(vbox, "Learn 5 words", 3, 5)

	# Quest 3: Get 90% for 2 lessons
	_create_quest_row(vbox, "Get 90% for 2 lessons", 1, 2)

	# Scale-in animation
	panel.modulate.a = 0
	panel.scale = Vector2(0.95, 0.95)

	# Use Tween for multi-property animation with delay
	var tween = create_tween()
	tween.tween_interval(0.9)  # Delay
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.5)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.5)

func _create_quest_row(parent: VBoxContainer, quest_text: String, current: int, total: int) -> void:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)

	# Quest text on left
	var quest_label = Label.new()
	quest_label.text = quest_text
	quest_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	AssetLoader.apply_header_font(quest_label, 12)
	quest_label.add_theme_color_override("font_color", AssetLoader.get_color("figma_light_brown"))
	row.add_child(quest_label)

	# Progress section on right
	var progress_vbox = VBoxContainer.new()
	progress_vbox.add_theme_constant_override("separation", 5)
	row.add_child(progress_vbox)

	# Progress text
	var progress_text = Label.new()
	progress_text.text = "%d / %d" % [current, total]
	progress_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	AssetLoader.apply_header_font(progress_text, 11)
	progress_text.add_theme_color_override("font_color", AssetLoader.get_color("char_green"))
	progress_vbox.add_child(progress_text)

	# Progress bar
	var progress_bg = PanelContainer.new()
	progress_bg.custom_minimum_size = Vector2(200, 12)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = AssetLoader.get_color("figma_darker_brown")
	bg_style.corner_radius_top_left = 6
	bg_style.corner_radius_top_right = 6
	bg_style.corner_radius_bottom_left = 6
	bg_style.corner_radius_bottom_right = 6
	progress_bg.add_theme_stylebox_override("panel", bg_style)
	progress_vbox.add_child(progress_bg)

	# Progress fill
	var progress_percentage = float(current) / float(total)
	var fill_width = 200 * progress_percentage

	var progress_fill = ColorRect.new()
	progress_fill.color = AssetLoader.get_color("char_green")
	progress_fill.custom_minimum_size = Vector2(fill_width, 12)
	progress_fill.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

	var fill_margin = MarginContainer.new()
	fill_margin.add_theme_constant_override("margin_left", 1)
	fill_margin.add_theme_constant_override("margin_top", 1)
	fill_margin.add_theme_constant_override("margin_bottom", 1)
	progress_bg.add_child(fill_margin)
	fill_margin.add_child(progress_fill)

func _create_start_button(parent: VBoxContainer) -> void:
	var btn_container = CenterContainer.new()
	btn_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(btn_container)

	var start_btn = Button.new()
	start_btn.pressed.connect(_on_start_pressed)
	start_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_container.add_child(start_btn)

	# Button style with Figma gold color
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = AssetLoader.get_color("figma_gold")
	btn_normal.corner_radius_top_left = 15
	btn_normal.corner_radius_top_right = 15
	btn_normal.corner_radius_bottom_left = 15
	btn_normal.corner_radius_bottom_right = 15
	btn_normal.shadow_size = 8
	btn_normal.shadow_color = Color(0, 0, 0, 0.4)
	btn_normal.shadow_offset = Vector2(0, 6)
	btn_normal.content_margin_left = 50
	btn_normal.content_margin_right = 50
	btn_normal.content_margin_top = 25
	btn_normal.content_margin_bottom = 25
	# 3D depth effect
	btn_normal.border_width_bottom = 4
	btn_normal.border_color = AssetLoader.get_color("figma_dark_brown")

	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = AssetLoader.get_color("figma_gold_light")
	btn_hover.shadow_offset = Vector2(0, 4)

	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = AssetLoader.get_color("gold_dark")
	btn_pressed.shadow_size = 4
	btn_pressed.shadow_offset = Vector2(0, 2)
	btn_pressed.border_width_bottom = 2

	start_btn.add_theme_stylebox_override("normal", btn_normal)
	start_btn.add_theme_stylebox_override("hover", btn_hover)
	start_btn.add_theme_stylebox_override("pressed", btn_pressed)

	await get_tree().process_frame
	start_btn.text = "%s START ADVENTURE %s" % [AssetLoader.SWORD_EMOJI, AssetLoader.SWORD_EMOJI]
	AssetLoader.apply_header_font(start_btn, 22)
	start_btn.add_theme_color_override("font_color", AssetLoader.get_color("figma_dark_brown"))
	start_btn.custom_minimum_size = Vector2(500, 90)

	# Fade in animation using Tween
	start_btn.modulate.a = 0
	var btn_tween = create_tween()
	btn_tween.tween_interval(1.2)
	btn_tween.tween_property(start_btn, "modulate:a", 1.0, 0.6)

func _on_start_pressed() -> void:
	print("Starting adventure with character: ", selected_character_id)
	start_session_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/activities/Flashcard.tscn")

func _add_decorative_clouds(parent: ColorRect) -> void:
	# Add cloud emojis at various positions with different opacities
	# Each cloud moves horizontally at different speeds
	var cloud_positions = [
		{"pos": Vector2(100, 80), "opacity": 0.2, "size": 60, "speed": 30},
		{"pos": Vector2(300, 150), "opacity": 0.25, "size": 55, "speed": 20},
		{"pos": Vector2(900, 100), "opacity": 0.3, "size": 65, "speed": 25},
		{"pos": Vector2(1100, 180), "opacity": 0.2, "size": 58, "speed": 35},
		{"pos": Vector2(200, 400), "opacity": 0.25, "size": 62, "speed": 15},
		{"pos": Vector2(1000, 450), "opacity": 0.2, "size": 56, "speed": 28}
	]

	for cloud_data in cloud_positions:
		var cloud = Label.new()
		cloud.text = AssetLoader.CLOUD_EMOJI
		cloud.position = cloud_data["pos"]
		cloud.modulate.a = cloud_data["opacity"]
		AssetLoader.apply_header_font(cloud, cloud_data["size"])
		parent.add_child(cloud)

		# Animate cloud horizontally (infinite loop)
		_animate_cloud(cloud, cloud_data["speed"])

func _animate_cloud(cloud: Label, speed: float) -> void:
	# Get viewport width
	var viewport_width = get_viewport_rect().size.x
	var cloud_start_x = cloud.position.x

	# Create looping animation
	var tween = create_tween()
	tween.set_loops()

	# Calculate duration based on speed (pixels per second)
	var distance = viewport_width + 200  # Move across screen + extra
	var duration = distance / speed

	# Move cloud to the right off-screen
	tween.tween_property(cloud, "position:x", viewport_width + 100, duration).from(cloud_start_x)
	# Reset to left side instantly
	tween.tween_callback(func(): cloud.position.x = -100)

func _add_decorative_grass() -> void:
	# Add grass pattern at bottom
	var grass_container = Control.new()
	grass_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	grass_container.offset_top = -60
	grass_container.z_index = -1
	add_child(grass_container)

	var grass = ColorRect.new()
	grass.color = AssetLoader.get_color("char_green").darkened(0.3)
	grass.set_anchors_preset(Control.PRESET_FULL_RECT)
	grass.modulate.a = 0.3
	grass_container.add_child(grass)

func _animate_entrance(title: Label, subtitle: Label) -> void:
	# Title fade in and slide down
	title.modulate.a = 0
	var original_y = title.position.y
	title.position.y -= 20

	var title_tween = create_tween()
	title_tween.tween_interval(0.3)  # Delay
	title_tween.set_parallel(true)
	title_tween.set_ease(Tween.EASE_OUT)
	title_tween.tween_property(title, "modulate:a", 1.0, 0.6)
	title_tween.tween_property(title, "position:y", original_y, 0.6)

	# Subtitle fade in using Tween
	subtitle.modulate.a = 0
	var subtitle_tween = create_tween()
	subtitle_tween.tween_interval(0.5)  # Delay
	subtitle_tween.tween_property(subtitle, "modulate:a", 1.0, 0.5)

	# Start floating animation after entrance completes
	await get_tree().create_timer(0.9).timeout  # Wait for entrance to finish
	_animate_title_float(title)

func _animate_title_float(title: Label) -> void:
	# Create a looping up/down floating animation with reduced range
	var float_tween = create_tween()
	float_tween.set_loops()
	float_tween.set_ease(Tween.EASE_IN_OUT)
	float_tween.set_trans(Tween.TRANS_SINE)

	# Float up 10 pixels (reduced from 20)
	float_tween.tween_property(title, "position:y", title.position.y - 10, 1.5).as_relative()
	# Float down 10 pixels (reduced from 20)
	float_tween.tween_property(title, "position:y", title.position.y + 10, 1.5).as_relative()

func _add_pause_button() -> void:
	# X/Exit button in top-left corner
	var exit_btn = Button.new()
	exit_btn.text = "X"
	exit_btn.custom_minimum_size = Vector2(60, 60)
	exit_btn.position = Vector2(20, 20)
	exit_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	exit_btn.pressed.connect(_on_exit_pressed)

	# Button style - dark red background
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = AssetLoader.get_color("figma_dark_red")
	btn_style.corner_radius_top_left = 12
	btn_style.corner_radius_top_right = 12
	btn_style.corner_radius_bottom_left = 12
	btn_style.corner_radius_bottom_right = 12
	btn_style.border_color = AssetLoader.get_color("figma_darker_red")
	btn_style.border_width_left = 3
	btn_style.border_width_right = 3
	btn_style.border_width_top = 3
	btn_style.border_width_bottom = 3

	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = AssetLoader.get_color("figma_darker_red")

	exit_btn.add_theme_stylebox_override("normal", btn_style)
	exit_btn.add_theme_stylebox_override("hover", btn_hover)
	AssetLoader.apply_header_font(exit_btn, 36)
	exit_btn.add_theme_color_override("font_color", Color.WHITE)
	add_child(exit_btn)

func _on_exit_pressed() -> void:
	get_tree().quit()
