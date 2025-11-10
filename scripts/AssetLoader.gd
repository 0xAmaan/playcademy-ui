extends Node

## AssetLoader - Centralized asset management for Word Warriors
## Loads fonts, sprites, and provides easy access throughout the app

# Fonts
var header_font: Font
var body_font: Font

# Sprites
var warrior_idle: Texture2D
var warrior_celebrate: Texture2D

# UI Icons (using emoji for now, can replace with sprites later)
const STAR_EMOJI = "⭐"
const SWORD_EMOJI = "⚔️"
const SHIELD_EMOJI = "🛡️"
const TROPHY_EMOJI = "🏆"
const WARRIOR_EMOJI = "🛡️"  # Placeholder warrior icon
const COIN_EMOJI = "🪙"
const FIRE_EMOJI = "🔥"
const GIFT_EMOJI = "🎁"
const CLOUD_EMOJI = "☁️"

# Character emojis (matching Figma design)
const WIZARD_EMOJI = "🧙‍♂️"
const KNIGHT_EMOJI = "⚔️"
const ARCHER_EMOJI = "🏹"
const GUARDIAN_EMOJI = "🛡️"

# Medieval color palette (Figma design colors)
const COLORS = {
	# Original colors (keeping for backward compatibility)
	"stone_dark": Color("#4A3728"),
	"stone_light": Color("#8B7355"),
	"gold": Color("#D4AF37"),
	"gold_dark": Color("#B8860B"),
	"parchment": Color("#F4E4C1"),
	"success": Color("#4CAF50"),
	"danger": Color("#8B0000"),
	"info": Color("#4A90E2"),
	"text_dark": Color("#2C1810"),
	"text_light": Color("#F5F5DC"),

	# Figma design colors
	"figma_bg": Color("#E8DBBB"),  # Warm beige/parchment background
	"figma_gold": Color("#C4A54A"),  # Primary gold for titles, highlights
	"figma_gold_light": Color("#D4B55A"),  # Lighter gold for hover states
	"figma_dark_brown": Color("#3A2D1D"),  # Main UI containers, text
	"figma_medium_brown": Color("#6B5944"),  # Borders, secondary containers
	"figma_light_brown": Color("#8B7355"),  # Tertiary text, borders
	"figma_darker_brown": Color("#1A1612"),  # Progress bar backgrounds
	"figma_dark_red": Color("#7A1E1E"),  # Logo accent
	"figma_darker_red": Color("#5A1616"),  # Logo accent darker
	"figma_orange": Color("#E8864A"),  # Streak indicator

	# Character/mode colors from Figma
	"char_blue": Color("#3498DB"),  # Wizard/Story mode
	"char_blue_dark": Color("#2980B9"),
	"char_purple": Color("#9B59B6"),  # Speed mode
	"char_purple_dark": Color("#8E44AD"),
	"char_green": Color("#27AE60"),  # Archer
	"char_green_light": Color("#2ECC71"),
	"char_red": Color("#E74C3C"),  # Knight/Arena mode
	"char_red_dark": Color("#C0392B")
}

func _ready() -> void:
	_load_fonts()
	_load_sprites()
	print("AssetLoader: All assets loaded!")

func _load_fonts() -> void:
	# Header font (Press Start 2P - pixel style)
	header_font = load("res://assets/fonts/PressStart2P-Regular.ttf")
	if not header_font:
		push_error("Failed to load header font!")

	# Body font (Nunito - readable)
	body_font = load("res://assets/fonts/Nunito-VariableFont_wght.ttf")
	if not body_font:
		push_error("Failed to load body font!")

func _load_sprites() -> void:
	# Load swordsman spritesheet and extract single frame
	var idle_sheet = load("res://assets/swordsman/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Idle_without_shadow.png")

	if idle_sheet:
		# Spritesheet is 768x256
		# Likely 6 frames across (768/6=128px) and 2 rows (256/2=128px)
		# Extract just the FIRST frame (top-left)
		var atlas = AtlasTexture.new()
		atlas.atlas = idle_sheet
		atlas.region = Rect2(0, 0, 128, 128)  # First frame only
		warrior_idle = atlas
	else:
		push_warning("Failed to load warrior idle sprite")

	# For celebration, use attack sprite first frame
	var attack_sheet = load("res://assets/swordsman/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_attack_without_shadow.png")

	if attack_sheet:
		var atlas = AtlasTexture.new()
		atlas.atlas = attack_sheet
		atlas.region = Rect2(0, 0, 128, 128)  # First frame
		warrior_celebrate = atlas
	else:
		push_warning("Failed to load warrior celebrate sprite")

# Helper functions to apply fonts (works with Label, Button, etc.)
func apply_header_font(control: Control, size: int = 32) -> void:
	if header_font:
		control.add_theme_font_override("font", header_font)
		control.add_theme_font_size_override("font_size", size)

func apply_body_font(control: Control, size: int = 24) -> void:
	if body_font:
		control.add_theme_font_override("font", body_font)
		control.add_theme_font_size_override("font_size", size)

# Helper to get a color from the palette
func get_color(color_name: String) -> Color:
	if COLORS.has(color_name):
		return COLORS[color_name]
	push_warning("Color '%s' not found in palette!" % color_name)
	return Color.WHITE
