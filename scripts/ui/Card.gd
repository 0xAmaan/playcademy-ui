extends PanelContainer

## Reusable card component with rounded corners and shadow
## Usage: Add content as children to this container

var animate_on_ready: bool = false  # Set to true to auto-animate

func _ready() -> void:
	_setup_styling()

	# Optional: Add subtle hover animation
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	# Subtle lift on hover
	Anima.Node(self).anima_scale(Vector2(1.02, 1.02), 0.2).anima_easing(AnimaEasing.EASING.EASE_OUT).play()

func _on_mouse_exited() -> void:
	# Return to normal
	Anima.Node(self).anima_scale(Vector2.ONE, 0.2).anima_easing(AnimaEasing.EASING.EASE_OUT).play()

func _setup_styling() -> void:
	# Create StyleBoxFlat for card
	var style = StyleBoxFlat.new()
	style.bg_color = Color.WHITE

	# Rounded corners
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20

	# Padding inside the card
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 30
	style.content_margin_bottom = 30

	# Shadow effect
	style.shadow_color = Color(0, 0, 0, 0.15)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)

	add_theme_stylebox_override("panel", style)
