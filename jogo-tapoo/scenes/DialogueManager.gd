extends Control
class_name DialogueManager

# Define o sinal que será emitido quando o diálogo terminar
signal dialogue_finished

# --- REFERÊNCIAS DE UI ---
# Estes nomes de nó devem ser filhos diretos da sua DialogueScene
@onready var character_name_label = $CharacterNameLabel
@onready var dialogue_text_label = $DialogueTextLabel
@onready var protagonista_sprite = $ProtagonistaSprite
@onready var coelho_sprite = $CoelhoSprite

var dialogue_queue: Array = []

# ==============================================================================
# 1. FUNÇÕES PÚBLICAS
# ==============================================================================

# Chamada para iniciar um novo diálogo
func start_dialogue(dialogue_array: Array):
	# Pausa o jogo base para focar no diálogo
	get_tree().paused = true 
	
	dialogue_queue = dialogue_array.duplicate()
	
	# Garante que as caixas de texto comecem visíveis
	show()
	protagonista_sprite.hide()
	coelho_sprite.hide()
	
	# Inicia a primeira linha
	next_dialogue_line()

# ==============================================================================
# 2. LÓGICA DE DIÁLOGO E AVANÇO
# ==============================================================================

# Chamado a cada clique do jogador
func advance_line():
	next_dialogue_line()

# Avança para a próxima linha da fila
func next_dialogue_line():
	if dialogue_queue.is_empty():
		end_dialogue()
		return

	var line_data = dialogue_queue.pop_front()
	var char_name = line_data.char
	
	# Gerencia os Sprites
	protagonista_sprite.hide()
	coelho_sprite.hide()
	
	if char_name == "Protagonista":
		protagonista_sprite.show()
	elif char_name == "Coelho do Tempo":
		coelho_sprite.show()
		
	# Atualiza o texto e nome do personagem
	if character_name_label:
		character_name_label.text = char_name
		
	if dialogue_text_label:
		dialogue_text_label.text = line_data.line
		
# Finaliza a cena de diálogo
func end_dialogue():
	get_tree().paused = false
	hide()
	
	# Emite um sinal para avisar ao GameController que é hora de continuar
	emit_signal("dialogue_finished")


# ==============================================================================
# 3. INPUT
# ==============================================================================
# Captura o input quando o painel de diálogo está ativo
func _input(event):
	# Se o painel de diálogo for visível, avança a linha ao clicar/pressionar 'ui_accept'
	if visible and event.is_action_pressed("ui_accept"):
		# Garante que o evento seja consumido para não interagir com o jogo base
		get_viewport().set_input_as_handled() 
		advance_line()
