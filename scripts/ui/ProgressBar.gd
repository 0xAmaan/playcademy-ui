extends Control

## Progress bar showing "X/Y words" or similar progress
## Usage: Set current and total, component updates automatically

var current: int = 0:
	set(value):
		current = value
		_update_display()

var total: int = 10:
	set(value):
		total = value
		_update_display()

var label: Label

func _ready() -> void:
	_setup_ui()
	_update_display()

func _setup_ui() -> void:
	custom_minimum_size = Vector2(200, 40)

	# Background bar
	var bg = Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color("#E0E0E0")
	bg_style.corner_radius_top_left = 20
	bg_style.corner_radius_top_right = 20
	bg_style.corner_radius_bottom_left = 20
	bg_style.corner_radius_bottom_right = 20
	bg.add_theme_stylebox_override("panel", bg_style)
	add_child(bg)

	# Progress fill
	var fill = Panel.new()
	fill.name = "Fill"
	fill.anchor_top = 0.0
	fill.anchor_bottom = 1.0
	fill.anchor_left = 0.0
	fill.anchor_right = 0.5  # Will update based on progress
	fill.offset_right = 0
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color("#4ECDC4")  # Teal
	fill_style.corner_radius_top_left = 20
	fill_style.corner_radius_top_right = 20
	fill_style.corner_radius_bottom_left = 20
	fill_style.corner_radius_bottom_right = 20
	fill.add_theme_stylebox_override("panel", fill_style)
	add_child(fill)

	# Label
	label = Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("#333333"))
	add_child(label)

func _update_display() -> void:
	if not is_node_ready():
		return

	# Update label text
	label.text = "%d / %d" % [current, total]

	# Update fill width
	var fill = get_node_or_null("Fill")
	if fill:
		var progress = float(current) / float(total) if total > 0 else 0.0
		fill.anchor_right = progress
