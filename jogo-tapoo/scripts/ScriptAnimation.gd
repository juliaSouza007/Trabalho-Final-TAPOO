# Este script pertence ao nó AnimatedSprite2D
extends AnimatedSprite2D

func _ready():
	# Isso garante que a animação comece assim que a cena for carregada.
	play("idle")
