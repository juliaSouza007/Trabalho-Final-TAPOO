extends Node2D

# Referências aos nós da UI (conecte no Inspector!)
@onready var protagonista_fala_label = $CanvasLayer/PersonagemPanel/PersonagemLabel
@onready var coelho_fala_label = $CanvasLayer/CoelhoPanel/CoelhoLabel
@onready var next_button = $CanvasLayer/ProximaFalaButton # O botão que avança a fala (diálogo)
@onready var next_scene_button = $CanvasLayer/NextSceneButton # O botão que vai para a próxima cena (NOVO)
@onready var protagonista_panel = $CanvasLayer/PersonagemPanel # Painel pai para esconder/mostrar tudo
@onready var coelho_panel = $CanvasLayer/CoelhoPanel

# Sprites (Opção 1: AnimatedSprite2D com animação "idle" e "speaking")
@onready var protagonista_sprite = $PersonagemAnimated
@onready var coelho_sprite = $CoelhoAnimated


# O Diálogo: Array de Dicionários
const DIALOGO = [
	{"personagem": "Protagonista", "fala": "…Onde estou? Tudo parece parado… e silencioso."},
	{"personagem": "Coelho do Tempo", "fala": "Você está entre o que foi… e o que ainda pode ser."},
	{"personagem": "Coelho do Tempo", "fala": "O tempo travou — e com ele, você."},
	{"personagem": "Coelho do Tempo", "fala": "Suas memórias estão espalhadas pelos cantos da sua vida. Precisamos encontrá-las."},
	{"personagem": "Protagonista", "fala": "E quem é você?"},
	{"personagem": "Coelho do Tempo", "fala": "Sou o que resta quando o tempo cansa. Pode me chamar de Coelho do Tempo."},
	{"personagem": "Coelho do Tempo", "fala": "Vamos voltar ao início… antes que tudo se perca de vez."}
]

var indice_atual = 0
const PROXIMA_CENA = "res://scenes/dialogue_scene2.tscn" 

# --- FUNÇÕES INTERNAS ---

func _ready():
	# Inicialmente, esconde todos os painéis de diálogo
	protagonista_panel.hide()
	coelho_panel.hide()
	
	# Garante que o botão de transição para a próxima cena esteja escondido no início
	next_scene_button.hide()
	
	# Conecta o sinal 'pressed' do botão de avanço de fala (diálogo)
	next_button.pressed.connect(avancar_fala)
	
	# Conecta o sinal 'pressed' do botão de transição de cena
	next_scene_button.pressed.connect(mudar_de_cena)
	
	# Exibe a primeira fala ao iniciar
	exibir_fala_atual()

func _reset_ui_focus():
	# Esconde os painéis de fala
	protagonista_panel.hide()
	coelho_panel.hide()
	
	# Reseta o foco visual (modulate e animação idle)
	protagonista_sprite.modulate = Color(0.7, 0.7, 0.7) # Cor cinza para quem não fala
	coelho_sprite.modulate = Color(0.7, 0.7, 0.7)
	
	# Garante que as animações parem no estado "idle"
	protagonista_sprite.play("idle")
	coelho_sprite.play("idle")


func exibir_fala_atual():
	if indice_atual < DIALOGO.size():
		var fala = DIALOGO[indice_atual]
		
		# 1. Reseta o estado de todos os elementos de UI/Sprites
		_reset_ui_focus()
		
		# 2. Foca no Personagem
		if fala.personagem == "Protagonista":
			protagonista_panel.show()
			protagonista_fala_label.text = fala.fala
			
			# Foco visual e animação
			protagonista_sprite.modulate = Color.WHITE
			protagonista_sprite.play("idle") 
			
		elif fala.personagem == "Coelho do Tempo":
			coelho_panel.show()
			coelho_fala_label.text = fala.fala
			
			# Foco visual e animação
			coelho_sprite.modulate = Color.WHITE
			coelho_sprite.play("idle")
			
	else:
		# Se o diálogo acabou
		finalizar_cutscene()

func avancar_fala():
	indice_atual += 1
	exibir_fala_atual()

func finalizar_cutscene():
	print("Fim do Diálogo! Exibindo botão de próxima cena.")
	
	# Esconde a UI de diálogo (botão de próxima fala e painéis)
	_reset_ui_focus()
	next_button.hide()
	
	# --- EXIBE O BOTÃO DE TRANSIÇÃO PRÉ-EXISTENTE ---
	next_scene_button.show() 

func mudar_de_cena():
	var erro = get_tree().change_scene_to_file(PROXIMA_CENA)
	if erro != OK:
		print("ERRO ao carregar a cena: Código ", erro)
