class_name PageManager extends PanelContainer

signal page_changed

@onready var btn_prev = %BtnPrev
@onready var page_info = %PageInfo
@onready var btn_next = %BtnNext
@onready var option_button = %OptionButton
@onready var total_label = %TotalLabel


var total_pages : int = 1 :
	set(value):
		assert(value > 0, "not valid number")
		total_pages = value
		_update_page_info()

var current_page : int = 1 : 
	set(value):
		assert(value > 0, "not valid number")
		current_page = _page_limit(value)
		_update_page_info()
		page_changed.emit()

var each_page_items : int = 50 :
	set(value):
		assert(value > 0, "not valid number")
		each_page_items = value
		_auto_page()

var total_items : int = 0 :
	set(value):
		assert(value >= 0, "not valid number")
		total_items = value
		total_label.text = "Total : " + str(total_items) 
		_auto_page()


func _ready():
	option_button.select(1)
	option_button.item_selected.connect(_on_option_selected)
	btn_prev.pressed.connect(_prev_page)
	btn_next.pressed.connect(_next_page)
	_auto_page()
	_update_page_info()


func _update_page_info():
	page_info.text = "%d / %d" % [current_page, total_pages]
	btn_prev.disabled = (current_page == 1)
	btn_next.disabled = (current_page == total_pages)
	page_changed.emit()


func _page_limit(page : int) -> int:
	return max(1, min(page, total_pages))


func _auto_page():
	current_page = 1
	total_pages = max(1, ceil(total_items * 1.0 / each_page_items))
	_update_page_info()


## 获取当前页应该使用的文件个数，根据当前页应该用的 page_items 范围而定
func get_page_files(all_files : Array) -> Array:
	return all_files.slice(each_page_items * (current_page - 1), min(total_items, each_page_items * current_page))


func set_total_items(value : int):
	total_items = value


### Signals

func _prev_page():
	current_page -= 1


func _next_page():
	current_page += 1


func _on_option_selected(id : int):
	if id == 0:
		each_page_items = 30
	elif id == 1:
		each_page_items = 50
	elif id == 2:
		each_page_items = 75
	elif id == 3:
		each_page_items = 100
