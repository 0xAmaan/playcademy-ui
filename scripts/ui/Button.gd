extends Button

## Reusable kid-friendly button component
## Usage: Just set the text property and connect to pressed signal

var original_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	_setup_styling()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	original_scale = scale

func _setup_styling() -> void:
	# Size
	custom_minimum_size = Vector2(200, 60)

	# Set cursor to pointing hand when hovering
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Create StyleBoxFlat for normal state
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color("#4ECDC4")  # Teal
	style_normal.corner_radius_top_left = 12
	style_normal.corner_radius_top_right = 12
	style_normal.corner_radius_bottom_left = 12
	style_normal.corner_radius_bottom_right = 12
	style_normal.content_margin_left = 20
	style_normal.content_margin_right = 20
	style_normal.content_margin_top = 15
	style_normal.content_margin_bottom = 15

	# Shadow effect
	style_normal.shadow_color = Color(0, 0, 0, 0.2)
	style_normal.shadow_size = 4
	style_normal.shadow_offset = Vector2(0, 2)

	add_theme_stylebox_override("normal", style_normal)

	# Hover state
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color("#45B8AC")  # Slightly darker teal
	add_theme_stylebox_override("hover", style_hover)

	# Pressed state
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color("#3DA399")  # Even darker teal
	style_pressed.shadow_size = 2
	style_pressed.shadow_offset = Vector2(0, 1)
	add_theme_stylebox_override("pressed", style_pressed)

	# Text styling
	add_theme_font_size_override("font_size", 28)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_hover_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", Color.WHITE)

func _on_mouse_entered() -> void:
	# Gentle scale up on hover for kid-friendly feedback
	Anima.Node(self).anima_scale(original_scale * 1.05, 0.2).anima_easing(AnimaEasing.EASING.EASE_OUT_BACK).play()

func _on_mouse_exited() -> void:
	# Scale back to normal
	Anima.Node(self).anima_scale(original_scale, 0.2).anima_easing(AnimaEasing.EASING.EASE_OUT).play()

func _on_button_down() -> void:
	# Squish down when pressed - satisfying tactile feedback
	Anima.Node(self).anima_scale(original_scale * 0.95, 0.1).anima_easing(AnimaEasing.EASING.EASE_OUT).play()

func _on_button_up() -> void:
	# Bounce back up
	Anima.Node(self).anima_scale(original_scale * 1.05, 0.15).anima_easing(AnimaEasing.EASING.EASE_OUT_BACK).play()
