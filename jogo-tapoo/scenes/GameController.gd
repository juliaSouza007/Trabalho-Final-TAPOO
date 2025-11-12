# GameController.gd - Controla a lógica de enigmas e a ordem de coleta na fase "Escola".

extends Node

# Mapeamento do ID (ordem) para o nome do objeto (para referência de debug)
const OBJECT_NAMES = {
	1: "Bola",
	2: "Mochila",
	3: "Pincel",
	4: "Livro",
	5: "Ábaco"
}

# Lista de enigmas, na ordem de coleta (ID 1 a 5).
const ENIGMAS = [
	# ID 1: Bola
	"Redonda e leve, corro sem os pes e tiro risos de quem me joga. Onde os jogos e as crianças se encontram, me encontraras. O que sou?",
	# ID 2: Mochila
	"Levo tudo o que precisa, nas suas costas vou, tenho bolsos secretos e um ziper amigo. Procura-me onde quem parte se prepara. O que sou?",
	# ID 3: Pincel
	"Sou instrumento de cor: venho em fios que bebem tinta. Procure-me no lugar onde telas e folhas viram mundos. O que sou?",
	# ID 4: Livro
	"Fico em prateleiras, mas viajo o mundo. Quem me le, conhece o que nunca viu. Sou aberto para aprender e fechado para guardar. O que sou?",
	# ID 5: Ábaco
	"Tenho bolinhas que andam em linha, sou de madeira e contas. Deslizo para somar e parar para pensar. O que sou?"
]

# Mapa dos objetos: ID (ordem) -> Nó do Objeto
var objects = {}

# O índice do enigma/objeto que o jogador precisa encontrar agora.
var current_enigma_index: int = 1 # Começa no ID 1

# Referências
@export var enigma_label_path: NodePath
var enigma_label: Label

# -------------------- Inicialização --------------------
func _ready():
	# 1. Tenta encontrar o nó de texto para exibir o enigma
	if not enigma_label_path.is_empty():
		enigma_label = get_node(enigma_label_path)
	
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
		if id == 1:
			print("DEBUG: Bola (ID 1) recebe set_collectable(", is_target, ")")

	print("Enigma Atual: ", current_enigma_index, " - Procurando por: ", OBJECT_NAMES.get(current_enigma_index))

# -------------------- Processamento do Clique --------------------
func object_collected(object_id: int):
	# Confirma que o objeto clicado é o que está sendo procurado no momento
	if object_id == current_enigma_index:
		print(OBJECT_NAMES[object_id], " coletado. Fragmento de Memória obtido!")
		
		# Exibe a cutscene curta (fragmento de memória)
		var fragment_text = get_memory_fragment(object_id)
		print(">> Fragmento: ", fragment_text) 
		
		# Prepara o próximo enigma
		current_enigma_index += 1
		start_next_enigma()
	
# -------------------- Lógica da Narrativa --------------------
func get_memory_fragment(object_id: int) -> String:
	match object_id:
		1: return "O recreio era um relógio. Eu só via a próxima aula." # Bola
		2: return "O peso não eram os livros, mas as expectativas." # Mochila
		3: return "A cor que importava era a nota, não a da tela." # Pincel
		4: return "Folheava as páginas, sem nunca ler a mim mesma." # Livro
		5: return "Contava os minutos, sem perceber que os perdia." # Ábaco
		_: return ""

# -------------------- Fim da Fase --------------------
func end_level():
	if enigma_label:
		enigma_label.text = "Fase Escola Concluída. Peça do Puzzle Liberada. O coelho espera..."
	
	# Lógica de transição: carregar a próxima cena, exibir o puzzle, etc.
