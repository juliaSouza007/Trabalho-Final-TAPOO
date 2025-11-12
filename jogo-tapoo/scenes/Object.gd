# Object.gd - Controla a interatividade de um objeto escondido.

extends Area2D

## Propriedades (Configuradas no Inspector)
@export var object_id: int = 0         # ID do objeto (deve corresponder à ordem do enigma)
@export var game_controller_path: NodePath # Caminho para o nó controlador (ex: ../GameController)

## Variáveis Internas
var game_controller: Node
var visual_component: CanvasItem        # Referência ao Sprite2D/TextureRect filho
var is_collectable: bool = false        # Se o objeto pode ser clicado no momento

# --- Configuração Inicial ---
func _ready():
	# 1. Encontra e armazena a referência ao GameController
	game_controller = get_node(game_controller_path)
	
	# 2. Encontra o componente visual (presume ser o primeiro filho, o Sprite/TextureRect)
	if get_child_count() > 0:
		visual_component = get_child(0) as CanvasItem
	
	if visual_component:
		# 3. Conecta o sinal de input (clique)
		connect("input_event", _on_input_event)
		
		# 4. Inicializa: o objeto é visível, mas não clicável até que o GameController o habilite
		set_collectable(false)
	else:
		push_error("ERRO: O nó Area2D '", name, "' não tem um componente visual filho.")
	
	if object_id == 1: # Testando apenas o primeiro objeto (Bola)
		set_collectable(true) 
		print("FORÇANDO OBJETO ", object_id, " A SER CLICÁVEL.")

# --- Lógica de Interatividade ---
## Função chamada pelo GameController para habilitar ou desabilitar o clique.
func set_collectable(can_collect: bool):
	is_collectable = can_collect
	# Habilita ou desabilita o Area2D para receber input de mouse.
	set_process_input(can_collect)

# --- Detecção de Clique ---
## Função chamada quando um evento de input ocorre dentro da área de colisão.
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	# Verifica se o evento foi um clique do botão esquerdo do mouse
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# Verifica se este objeto está habilitado para ser coletado
		if is_collectable:
			
			# 1. Notifica o controlador da coleta bem-sucedida
			game_controller.object_collected(object_id)
			
			# 2. Desativa a interatividade imediatamente
			set_collectable(false)
			
			# 3. Torna o objeto visualmente invisível
			if visual_component:
				visual_component.visible = false
			
			# Se você preferir remover o objeto completamente da cena, descomente a linha abaixo:
			# queue_free()
