# HiddenObjectItem.gd
extends Area2D

# Sinais e Exportação
signal found(item_id: String)
@export var item_id: String = "pinceis"
@export var is_active: bool = false # Novo controle para ativação

func _ready() -> void:
	# Inicializa o 'input_pickable' baseado no estado inicial de 'is_active'
	input_pickable = is_active 
	monitoring = true 
	input_event.connect(_on_input_event)
	
	# Debug de carregamento
	print("READY: Item ID carregado:", item_id, " | Pickable Inicial:", input_pickable)

# Novo método chamado pela cena principal para ativar o item
func set_active(active: bool) -> void:
	is_active = active
	input_pickable = active # Ativa/desativa o clique do Godot
	if active:
		print(">>> Item '%s' ATIVADO e agora é clicável." % item_id)


# A função de clique deve ser 'async' para o 'await' funcionar.
func _on_input_event(viewport, event, shape_idx):
	# Garante que só processa o clique esquerdo (pressionado)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# Apenas clica se o item estiver ativo (is_active == true)
		if not is_active:
			# Não faz nada se não for o item do enigma atual
			print("Item Inativo Clicado:", item_id)
			return

		print("Item clicado:", item_id)
		
		# 1. Emite o sinal
		emit_signal("found", item_id)
		
		# 2. SINCRONIZAÇÃO: Espera um frame para garantir que o sinal seja entregue antes de destruir
		await get_tree().process_frame 
		
		# 3. Libera o item
		queue_free()
