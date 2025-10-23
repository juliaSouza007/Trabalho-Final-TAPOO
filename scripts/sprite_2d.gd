# HiddenObjectItem.gd 
extends Area2D
signal found(item_id: String)

@export var item_id: String = ""
@export var display_name: String = ""

@onready var sprite: Sprite2D = $Sprite
var found_flag: bool = false

func _ready() -> void:
	input_event.connect(_on_input_event)
	# animação inicial opcional
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("idle")

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if not found_flag:
			found_flag = true
			_on_found()

func _on_found() -> void:
	# feedback visual
	if sprite:
		sprite.modulate = Color(1, 1, 1, 0.5)
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("found")
	# desativa colisão para não reapertar
	monitoring = false
	emit_signal("found", item_id)
