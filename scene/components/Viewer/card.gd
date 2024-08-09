@icon("res://resource/icons/TdesignCard.svg")

class_name Card

extends PanelContainer

@onready var _button = %Button
@onready var _already_pic = %AlreadyPic as TextureRect
@onready var _unready_pic = %UnreadyPic as TextureRect
@onready var _title = %Title as Label

signal pressed(card : Card)


func _ready():
	_button.pressed.connect(func(): pressed.emit(self)) # button 按下后发送 pressed 信号 


func set_title(text : String):
	_title.text = text


func set_image(texture : Texture2D):
	if not texture:
		_unready_pic.show()
		_already_pic.hide()
	else:
		_unready_pic.hide()
		_already_pic.show()
	
	_already_pic.texture = texture
