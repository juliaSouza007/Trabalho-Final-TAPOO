extends Button

# ==============================================================================
# 1. PROPRIEDADE PARA O CAMINHO DA CENA
# ==============================================================================

# Defina o caminho para a PRIMEIRA CENA do jogo (Ex: HospitalScene.tscn).
# Você deve preencher este campo no Inspector do Godot.
@export var target_scene_path: String = "res://scenes/tela_inicial.tscn" 

# ==============================================================================
# 2. INICIALIZAÇÃO E AÇÃO
# ==============================================================================

func _ready():
	# Conecta o sinal 'pressed' (pressionado) do botão à função de ação.
	self.pressed.connect(_on_pressed)
	
	# Define o texto do botão
	self.text = "REINICIAR JOGO"

func _on_pressed():
	if target_scene_path.is_empty():
		push_error("ERRO: O caminho da cena alvo ('target_scene_path') não foi definido no Inspector. Configure o caminho da primeira fase!")
		return

	# Tenta carregar a cena alvo
	var error = get_tree().change_scene_to_file(target_scene_path)
	
	if error != OK:
		push_error("ERRO: Falha ao carregar a cena: " + target_scene_path + ". Verifique se o caminho do arquivo está correto.")
	else:
		print("Cena carregada com sucesso: " + target_scene_path)
