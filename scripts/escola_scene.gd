# escola_scene.gd
extends Control

# Identificador da cena
@export var scene_id: String = "escola"

# NÓS DA CENA (GARANTA QUE OS NOMES DA ÁRVORE ESTEJAM CORRETOS)
@onready var items_container: Node2D = $ItemsContainer
@onready var found_label: Label = $UI/HUD/FoundLabel
@onready var next_button: Button = $UI/NextButton
@onready var enigma_label: Label = $UI/HUD/EnigmaLabel # NOVO: Para exibir o enigma

# DICIONÁRIO DE ITENS E ENIGMAS (Ordem define a sequência do jogo)
var enigma_sequence: Dictionary = {
	"bola": "Redonda e leve, corro sem os pés e tiro risos de quem me lança. Onde os jogos e as crianças se encontram, me encontrarás.",
	"mochila": "Levo tudo o que precisa, nas suas costas vou, tenho bolsos secretos e um zíper amigo. Procura-me onde quem parte se prepara.",
	"pinceis": "Sou instrumento de cor: venho em fios que bebem tinta. Procure-me no lugar onde telas e folhas viram mundos.",
	"livros": "Fico em prateleiras, mas viajo o mundo. Quem me lê, conhece o que nunca viu. Sou aberto para aprender e fechado para guardar.",
	"abaco": "Tenho bolinhas que andam em linha, sou de madeira e contas. Deslizo para somar e parar para pensar."
}

# DICIONÁRIO DE ARQUIVOS DE CENA (usado para spawn)
var item_scenes: Dictionary = {
	"abaco": "res://scenes/objects/abaco.tscn",
	"bola": "res://scenes/objects/bola.tscn",
	"livros": "res://scenes/objects/livros.tscn",
	"mochila": "res://scenes/objects/mochila.tscn",
	"pinceis": "res://scenes/objects/pinceis.tscn"
}

# Variáveis de Controle de Jogo
var current_enigma_id: String = "" # O ID do item que deve ser encontrado agora
var total_items: int = 0
var found_items: Array[String] = []
var enigma_ids: Array[String] = [] # Ordem da progressão
var current_enigma_index: int = 0
var item_instances: Dictionary = {} # Para guardar referências das instâncias

func _ready() -> void:
	# 1. Configuração Inicial do UI
	next_button.visible = false
	next_button.pressed.connect(_on_next_pressed)
	
	# ----------------------------------------------------
	print("LOG DE TESTE 1: Entrou no ready da cena principal.")
	# ----------------------------------------------------

	# 2. Configuração da Sequência
	enigma_ids = enigma_sequence.keys()
	total_items = enigma_ids.size()
	
	# 3. Spawning dos Itens
	_spawn_all_items() # ISTO GERA OS LOGS DE ITEM READY
	
	# ----------------------------------------------------
	print("LOG DE TESTE 2: Spawning dos itens concluído. Próximo passo: HUD.")
	# ----------------------------------------------------
	
	# 4. Inicialização do HUD e Jogo
	update_hud()
	start_enigma_sequence() 
	
	# ----------------------------------------------------
	print("LOG DE TESTE 3: Configuração do jogo concluída.")
	# ----------------------------------------------------
# --- FUNÇÕES DE SPAWN E CONEXÃO ---

func _spawn_all_items() -> void:
	print("Iniciando spawn de %d itens..." % item_scenes.size())
	for item_id in item_scenes.keys():
		var scene_path = item_scenes[item_id]
		_spawn_item(item_id, scene_path)

# A função de spawn agora recebe o item_id
func _spawn_item(item_id: String, scene_path: String) -> void:
	var scene_res = load(scene_path)
	
	if scene_res:
		var item = scene_res.instantiate()
		
		# 1. Checa a validade do script e sinal
		if !item.has_signal("found"): 
			print("ERRO CRÍTICO: Item de %s NÃO possui o script HiddenObjectItem.gd/sinal 'found'." % scene_path)
			return
		
		# 2. Conexão do Sinal (Usando self. para garantir que encontra o método)
		var error = item.found.connect(self._on_item_found)
		if error != OK:
			print("ERRO de CONEXÃO: Código %d ao conectar o item!" % error)
			return
			
		# 3. Adiciona à Cena e Salva a Referência
		items_container.add_child(item)
		item_instances[item_id] = item # Salva a referência para ativar/desativar
		
		# Debug: Imprime a posição para confirmar
		print("Instanciado e conectado item:", item.item_id, " em", item.position)
	else:
		print("ERRO: Não foi possível carregar a cena:", scene_path)

# --- FUNÇÕES DE LÓGICA DO ENIGMA ---

func start_enigma_sequence() -> void:
	current_enigma_index = 0
	progress_to_next_enigma()


func progress_to_next_enigma() -> void:
	# 1. Condição de Fim de Jogo
	if current_enigma_index >= enigma_ids.size():
		_on_all_found() 
		return

	# 2. Seleciona o Próximo Enigma
	current_enigma_id = enigma_ids[current_enigma_index]
	
	# 3. Atualiza o UI
	enigma_label.text = enigma_sequence[current_enigma_id]
	
	# 4. Ativa o Item Correto
	if item_instances.has(current_enigma_id):
		var item_to_activate = item_instances[current_enigma_id]
		item_to_activate.set_active(true) # Chama o método set_active no script do item
	else:
		print("ERRO: Instância do item '%s' não encontrada para ativação." % current_enigma_id)
		
	current_enigma_index += 1


func _on_item_found(item_id: String) -> void:
	# Este print DEVE aparecer se a sincronização funcionar!
	print(">>> SUCESSO! Sinal RECEBIDO na cena principal para o ID:", item_id)
	
	# 1. Checa se o item encontrado é o item ATIVO
	if item_id != current_enigma_id:
		print("AVISO: Item errado clicado ou ID errado no sinal:", item_id)
		return
		
	# 2. Adiciona o item à lista de encontrados
	found_items.append(item_id)
	print("Item encontrado na cena:", item_id)
	
	# 3. Remove a referência e avança
	if item_instances.has(item_id):
		item_instances.erase(item_id) # Remove do dicionário de instâncias vivas
	
	# 4. Atualiza o HUD e avança
	update_hud()
	progress_to_next_enigma() # Próximo enigma

# --- FUNÇÕES DE UI E CONCLUSÃO ---

func update_hud() -> void:
	found_label.text = "Encontrados: %d / %d" % [found_items.size(), total_items]

func _on_all_found() -> void:
	enigma_label.text = "TODOS OS ITENS ENCONTRADOS!"
	print("Todos os itens encontrados! Total: %d" % total_items)
	next_button.visible = true

func _on_next_pressed() -> void:
	if FileAccess.file_exists("res://scenes/puzzle_scene.tscn"):
		get_tree().change_scene_to_file("res://scenes/puzzle_scene.tscn")
	else:
		print("ERRO: Cena de destino 'puzzle_scene.tscn' não encontrada.")
