# escola_scene.gd
extends Control

# Identificador da cena
@export var scene_id: String = "escola"

@onready var items_container: Node2D = $ItemsContainer
@onready var found_label: Label = $UI/HUD/FoundLabel
@onready var next_button: Button = $UI/NextButton

var item_scenes: Dictionary = {
	"bola": "res://scenes/objects/bola.tscn",
	"globo": "res://scenes/objects/globo.tscn",
	"livros": "res://scenes/objects/livros.tscn",
	"poteTinta": "res://scenes/objects/pote_tinta.tscn",
	"relogio": "res://scenes/objects/relogio.tscn"
}
var total_items: int = 0
var found_items: Array[String] = []

func _ready() -> void:
	# Esconde o botão Next no início
	next_button.visible = false
	next_button.pressed.connect(_on_next_pressed)

	# Instancia TODOS os itens
	_spawn_all_items()
	
	# Atualiza o total de itens e o HUD
	total_items = item_scenes.size()
	update_hud()

# NOVO: Função para instanciar todos os itens
func _spawn_all_items() -> void:
	for item_id in item_scenes.keys():
		var scene_path = item_scenes[item_id]
		_spawn_item(scene_path)


func _spawn_item(scene_path: String) -> void:
	var scene_res = load(scene_path)
	
	if scene_res:
		var item = scene_res.instantiate()
		
		# REMOVIDO: item.position = Vector2(x, y) 
		# A posição original salva na cena .tscn será usada automaticamente!
		
		items_container.add_child(item)
		item.found.connect(_on_item_found)
		print("Instanciado item:", item.item_id, "em", item.position)
	else:
		print("ERRO: Não foi possível carregar a cena:", scene_path)


func _on_item_found(item_id: String) -> void:
	if item_id in found_items:
		return
	found_items.append(item_id)
	print("Item encontrado na cena:", item_id)
	update_hud()
	
	if found_items.size() >= total_items:
		_on_all_found()

func update_hud() -> void:
	# Usa a variável 'total_items' atualizada
	found_label.text = "Encontrados: %d / %d" % [found_items.size(), total_items]

func _on_all_found() -> void:
	print("Todos os itens encontrados!")
	next_button.visible = true

func _on_next_pressed() -> void:
	# Substitua "res://scenes/puzzle_scene.tscn" pelo caminho correto da sua próxima cena, se necessário
	if FileAccess.file_exists("res://scenes/puzzle_scene.tscn"):
		get_tree().change_scene_to_file("res://scenes/puzzle_scene.tscn")
	else:
		print("ERRO: Cena de destino 'puzzle_scene.tscn' não encontrada.")
