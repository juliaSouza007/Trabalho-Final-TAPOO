extends Area2D

signal found(item_id: String)
@export var item_id: String = "relogio"

func _ready() -> void:
	input_pickable = true
	monitoring = true # Não é estritamente necessário para input_pickable, mas não atrapalha

	# OTIMIZAÇÃO: Use a sintaxe moderna para conectar o sinal
	input_event.connect(_on_input_event) 

	print("READY:", item_id)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Item clicado:", item_id)
		emit_signal("found", item_id)
		queue_free()
