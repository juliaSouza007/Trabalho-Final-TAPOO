# TestClick.gd — minimalista, para depuração
extends Area2D

signal found(item_id: String)

@export var item_id: String = "item_teste"
@onready var sprite: Sprite2D = $Sprite
var clicked: bool = false

func _ready() -> void:
	# garante que o Area2D responde a eventos
	monitoring = true
	# conecta de forma segura usando callable
	self.input_event.connect(_on_input_event)
	print("READY ->", self.name, "item_id:", item_id)

func _on_input_event(viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if clicked:
				print("Já clicado:", item_id)
				return
			clicked = true
			print("CLICADO:", item_id, "nó:", self.name)
			# visual simples
			if sprite:
				sprite.modulate = Color(1, 1, 1, 0.5)
			emit_signal("found", item_id)
