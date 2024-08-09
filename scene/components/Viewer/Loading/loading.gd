extends Control

@onready var loading_label = %LoadingLabel
@onready var animation_player = %AnimationPlayer


func _ready():
	stop()


func start():
	show()
	animation_player.play("Label")
	loading_label.show()


func stop():
	hide()
	animation_player.play("RESET")
	loading_label.hide()
