extends Node

# ==============================================================================
# 1. FLUXO DE CENA
# ==============================================================================

# O Caminho do arquivo da próxima cena que deve ser carregada.
# ESTE CAMPO DEVE SER PREENCHIDO NO INSPECTOR PARA ESTA CENA 
@export var next_scene_path: String = "res://scenes/escritorio_scene.tscn"

# REFERÊNCIA AO BOTÃO DE TRANSIÇÃO 
@export var transition_button_path: NodePath
var transition_button: Button

# ==============================================================================
# 2. CONSTANTES DE JOGO E ENIGMAS (CENA ESCOLA)
# ==============================================================================

# Mapeamento do ID (ordem) para o nome do objeto (para referência de debug)
const OBJECT_NAMES = {
	1: "Bola",
	2: "Mochila",
	3: "Pincel",
	4: "Livro",
	5: "Abaco"
}

# Lista de enigmas, na ordem de coleta (ID 1 a 5).
const ENIGMAS = [
	# ID 1: bola
	"Redonda e leve, corro sem os pés e tiro risos de quem me lança. Onde os jogos e as crianças se encontram, me encontrarás. O que sou?",
	# ID 2: mochila
	"Levo tudo o que precisa, nas suas costas vou, tenho bolsos secretos e um zíper amigo. Procura-me onde quem parte se prepara. O que sou?",
	# ID 3: pincel
	"Sou instrumento de cor: venho em fios que bebem tinta. Procure-me no lugar onde telas e folhas viram mundos. O que sou?",
	# ID 4: livros
	"Fico em prateleiras, mas viajo o mundo. Quem me lê, conhece o que nunca viu. Sou aberto para aprender e fechado para guardar.  O que sou?",
	# ID 5: abaco
	"Tenho bolinhas que andam em linha, sou de madeira e contas. Deslizo para somar e parar para pensar. O que sou?"
]

# Mapa dos objetos: ID (ordem) -> Nó do Objeto
var objects = {}

# O índice do enigma/objeto que o jogador precisa encontrar agora.
var current_enigma_index: int = 1 # Começa no ID 1

# Referências
@export var enigma_label_path: NodePath
var enigma_label: Label

# ==============================================================================
# 3. INICIALIZAÇÃO E LÓGICA
# ==============================================================================

func _ready():
	print("--- INICIANDO GAME CONTROLLER (Cena Escola) ---")
	
	# 1. Tenta encontrar o nó de texto para exibir o enigma
	if not enigma_label_path.is_empty():
		enigma_label = get_node(enigma_label_path)
		if enigma_label: enigma_label.hide()
	
	# 1b. Novo: Inicializa o botão de transição e conecta o sinal
	if not transition_button_path.is_empty():
		transition_button = get_node(transition_button_path)
		if transition_button:
			transition_button.hide()
			# Conecta o sinal 'pressed' à função de manipulação
			transition_button.pressed.connect(_on_transition_button_pressed)
		else:
			push_error("ERRO: Botão de Transição não encontrado no caminho: " + str(transition_button_path))
	
	# 2. Mapeia todos os objetos (Otimização para garantir que todos comecem desabilitados)
	var container = get_parent().find_child("ObjectContainer")
	if container:
		for child in container.get_children():
			# Verifica se o nó tem o script Object.gd anexado
			if child.has_method("set_collectable"):
				var obj_id = child.object_id
				if obj_id > 0:
					objects[obj_id] = child
					# GARANTE: Todos os objetos começam NÃO CLICÁVEIS.
					child.set_collectable(false)
	
	# 3. Verifica a consistência
	if objects.size() != ENIGMAS.size():
		push_error("ERRO CRÍTICO: Mismatch entre objetos mapeados (" + str(objects.size()) + ") e enigmas (" + str(ENIGMAS.size()) + ").")
		return
		
	# 4. Inicia o jogo
	start_next_enigma()

# -------------------- Lógica do Enigma --------------------
func start_next_enigma():
	if current_enigma_index > ENIGMAS.size():
		# Todos os objetos coletados. Fim da fase!
		end_level()
		return

	# 1. Exibe o enigma
	if enigma_label:
		enigma_label.text = ENIGMAS[current_enigma_index - 1]
		enigma_label.show()
	
	# 2. Torna APENAS o objeto correspondente clicável
	for id in objects:
		var is_target = (id == current_enigma_index)
		# Chama set_collectable(true) para o objeto atual, e (false) para os outros
		objects[id].set_collectable(is_target)

	print("Enigma Atual: ", current_enigma_index, " - Procurando por: ", OBJECT_NAMES.get(current_enigma_index))

# -------------------- Processamento do Clique --------------------
func object_collected(object_id: int):
	# Confirma que o objeto clicado é o que está sendo procurado no momento
	if object_id == current_enigma_index:
		print(OBJECT_NAMES[object_id], " coletado.")
		
		# Prepara o próximo enigma
		current_enigma_index += 1
		start_next_enigma()
	
# -------------------- Fim da Fase e Exibe Botão --------------------
func end_level():
	# 1. Desabilita todos os objetos clicáveis restantes
	for id in objects:
		if objects[id]:
			objects[id].set_collectable(false)
			
	# 2. Esconde o enigma_label
	if enigma_label:
		enigma_label.hide()
	
	# 3. Exibe o Botão de Transição
	if transition_button:
		transition_button.text = "Próxima fase"
		transition_button.show()
	else:
		push_error("ERRO: Botão de transição não configurado. Impossível continuar.")
		
# -------------------- Manipulador do Botão --------------------
func _on_transition_button_pressed():
	perform_transition()
	
# -------------------- Executa a Transição de Cena --------------------
func perform_transition():
	print("Executando transição de cena...")
	
	if next_scene_path.is_empty():
		push_error("ERRO: O caminho da próxima cena ('next_scene_path') não foi definido. Não é possível transicionar.")
		# Aconselhável parar o jogo aqui
		return
	
	# Transição principal
	var error = get_tree().change_scene_to_file(next_scene_path)
	if error != OK:
		push_error("ERRO: Falha ao carregar a cena: " + next_scene_path)
