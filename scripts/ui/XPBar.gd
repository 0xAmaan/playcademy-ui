extends PanelContainer

## XPBar - Persistent XP bar component
## Shows current level, XP progress, and animates on XP gain

var level_label: Label
var xp_label: Label
var progress_bar: ProgressBar

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_update_display()

func _setup_ui() -> void:
	# Panel style - dark stone background
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = AssetLoader.get_color("stone_dark")
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.content_margin_left = 20
	panel_style.content_margin_right = 20
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	add_theme_stylebox_override("panel", panel_style)

	# HBox layout
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	add_child(hbox)

	# Level display
	level_label = Label.new()
	level_label.text = "Level 1"
	AssetLoader.apply_header_font(level_label, 20)
	level_label.add_theme_color_override("font_color", AssetLoader.get_color("gold"))
	hbox.add_child(level_label)

	# Progress bar
	var progress_container = VBoxContainer.new()
	progress_container.add_theme_constant_override("separation", 5)
	hbox.add_child(progress_container)

	xp_label = Label.new()
	xp_label.text = "0 / 100 XP"
	AssetLoader.apply_body_font(xp_label, 14)
	xp_label.add_theme_color_override("font_color", AssetLoader.get_color("text_light"))
	progress_container.add_child(xp_label)

	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.show_percentage = false

	# Progress bar fill style
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = AssetLoader.get_color("gold")
	fill_style.corner_radius_top_left = 5
	fill_style.corner_radius_top_right = 5
	fill_style.corner_radius_bottom_left = 5
	fill_style.corner_radius_bottom_right = 5

	# Progress bar background style
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = AssetLoader.get_color("stone_light")
	bg_style.corner_radius_top_left = 5
	bg_style.corner_radius_top_right = 5
	bg_style.corner_radius_bottom_left = 5
	bg_style.corner_radius_bottom_right = 5

	progress_bar.add_theme_stylebox_override("fill", fill_style)
	progress_bar.add_theme_stylebox_override("background", bg_style)
	progress_container.add_child(progress_bar)

func _connect_signals() -> void:
	XPManager.xp_changed.connect(_on_xp_changed)
	XPManager.level_up.connect(_on_level_up)
	XPManager.xp_gained.connect(_on_xp_gained)

func _update_display() -> void:
	# Update level
	level_label.text = "Level %d" % XPManager.current_level

	# Update XP text
	var xp_needed = XPManager.get_xp_for_next_level()
	xp_label.text = "%d / %d XP" % [XPManager.current_xp, xp_needed]

	# Update progress bar
	progress_bar.max_value = xp_needed
	progress_bar.value = XPManager.current_xp

func _on_xp_changed(current_xp: int, xp_to_next: int) -> void:
	_update_display()

	# Animate progress bar fill
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", current_xp, 0.3).set_ease(Tween.EASE_OUT)

func _on_level_up(new_level: int) -> void:
	# Flash gold color on level up
	var tween = create_tween()
	var original_color = level_label.get_theme_color("font_color")
	tween.tween_property(level_label, "modulate", Color.WHITE, 0.2)
	tween.tween_property(level_label, "modulate", original_color, 0.2)
	tween.set_loops(3)

	# Show gold particle effect for level up
	var effect_pos = level_label.global_position + Vector2(level_label.size.x / 2, level_label.size.y / 2)
	ParticleEffect.create_gold_effect(get_tree().root, effect_pos)

func _on_xp_gained(amount: int) -> void:
	# Show +XP text starting from center of screen, animating to XP bar
	var xp_popup = Label.new()
	xp_popup.text = "+%d XP" % amount
	AssetLoader.apply_header_font(xp_popup, 48)  # Large pixel font
	xp_popup.add_theme_color_override("font_color", AssetLoader.get_color("gold"))

	# Add glow/outline effect
	xp_popup.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	xp_popup.add_theme_constant_override("outline_size", 8)

	# Start at center of screen
	var viewport_size = get_viewport_rect().size
	var start_pos = Vector2(viewport_size.x / 2 - 100, viewport_size.y / 2)
	xp_popup.global_position = start_pos

	# Add to root so it appears above everything
	get_tree().root.add_child(xp_popup)

	# Get XP bar position (where we want to animate to)
	var xp_bar_pos = global_position + Vector2(size.x / 2, size.y / 2)

	# Animate: scale up, move to XP bar, fade out
	var tween = create_tween()
	tween.set_parallel(true)

	# Scale animation: start small, grow, then shrink
	xp_popup.scale = Vector2(0.5, 0.5)
	tween.tween_property(xp_popup, "scale", Vector2(1.2, 1.2), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_property(xp_popup, "scale", Vector2(0.5, 0.5), 0.5).set_ease(Tween.EASE_IN)

	# Move to XP bar
	tween.tween_property(xp_popup, "global_position", xp_bar_pos, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	# Fade out at the end
	tween.tween_property(xp_popup, "modulate:a", 0.0, 0.3).set_delay(0.5)

	tween.chain().tween_callback(xp_popup.queue_free)
