extends Node2D
class_name ParticleEffect

## Simple particle effect for celebrations
## Creates emoji/star particles that float up and fade away

var particles: Array = []
const PARTICLE_COUNT = 10
const PARTICLE_LIFETIME = 1.5

func _ready() -> void:
	_create_particles()

func _create_particles() -> void:
	var particle_emojis = ["⭐", "✨", "🌟", "💫"]

	for i in range(PARTICLE_COUNT):
		var particle = Label.new()
		particle.text = particle_emojis[randi() % particle_emojis.size()]
		particle.add_theme_font_size_override("font_size", 32 + randi() % 32)

		# Random position around center
		var angle = randf() * TAU
		var distance = randf() * 50
		particle.position = Vector2(cos(angle), sin(angle)) * distance

		add_child(particle)
		particles.append(particle)

		# Animate particle
		var tween = create_tween()
		tween.set_parallel(true)

		# Float up
		var float_distance = 100 + randf() * 100
		tween.tween_property(particle, "position:y", particle.position.y - float_distance, PARTICLE_LIFETIME)

		# Float sideways
		var drift = (randf() - 0.5) * 100
		tween.tween_property(particle, "position:x", particle.position.x + drift, PARTICLE_LIFETIME)

		# Fade out
		tween.tween_property(particle, "modulate:a", 0.0, PARTICLE_LIFETIME)

		# Clean up when done
		tween.finished.connect(_on_particle_finished.bind(particle))

func _on_particle_finished(particle: Label) -> void:
	particle.queue_free()
	particles.erase(particle)

	# If all particles are done, remove self
	if particles.is_empty():
		queue_free()

# Static helper to create particle effect at a position
static func create_at(parent: Node, pos: Vector2) -> void:
	var effect = ParticleEffect.new()
	effect.position = pos
	parent.add_child(effect)

# Gold particle effect for level ups
static func create_gold_effect(parent: Node, pos: Vector2) -> void:
	var effect = Node2D.new()
	effect.position = pos
	parent.add_child(effect)

	var gold_emojis = ["💰", "🏆", "👑", "⭐"]

	for i in range(15):
		var particle = Label.new()
		particle.text = gold_emojis[randi() % gold_emojis.size()]
		particle.add_theme_font_size_override("font_size", 40 + randi() % 40)
		particle.modulate = Color(1, 0.84, 0)  # Gold tint

		var angle = randf() * TAU
		var distance = randf() * 80
		particle.position = Vector2(cos(angle), sin(angle)) * distance

		effect.add_child(particle)

		var tween = effect.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position:y", particle.position.y - 200, 2.0)
		tween.tween_property(particle, "position:x", particle.position.x + (randf() - 0.5) * 150, 2.0)
		tween.tween_property(particle, "modulate:a", 0.0, 2.0)
		tween.tween_property(particle, "rotation", randf() * TAU, 2.0)

	# Clean up after 2 seconds
	await effect.get_tree().create_timer(2.0).timeout
	effect.queue_free()
