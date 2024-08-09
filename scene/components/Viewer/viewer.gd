extends PanelContainer

@export var PACKSCENE_CARD : PackedScene

@onready var hfc_main = %HFC_Main
@onready var page_manager := %PageManager as PageManager
@onready var loading = %Loading

var _timer : Timer  # 加载缓冲
var image_thread_pool : ThreadPool
var all_files : Array = []

const IMAGE_MAX_SIZE : int = 200

func _ready():
	clear()
	_timer_init()
	page_manager.page_changed.connect(_on_page_changed)
	image_thread_pool = ThreadPool.new(self)


func _timer_init():
	_timer = Timer.new()
	add_child(_timer)
	_timer.wait_time = 0.16
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)


func init_cards_from_files(files : Array):
	all_files = files
	page_manager.set_total_items(len(files))


func create_cards_from_files(files : Array):
	image_thread_pool.end() # 关线程池
	clear()                 # 卸载所有card
	loading.stop()          # 加载画面隐藏
	
	if not files:
		return
	
	for file in files:
		new_card(file)
	image_thread_pool.start() # 加完所有函数开跑多线程


func clear():
	for child in hfc_main.get_children():
		child.queue_free()


func new_card(image_path : String) -> Card:
	var card = PACKSCENE_CARD.instantiate() as Card
	_add_card(card)  # 先加到场景树里再调用方法
	card.set_title(image_path.get_file())
	card.set_meta("image_path", image_path) # ta添加原数据
	card.pressed.connect(_on_card_pressed)  # 连接回调函数
	
	## 使用thread_pool加载图片
	image_thread_pool.join_function(func(): _add_image_from_thread(card, image_path))
	
	return card


func _add_card(card : Card):
	hfc_main.add_child(card)


func _add_image_from_thread(card, image_path):
	var image = Image.load_from_file(image_path)
	
	if image == null:  # 加载出错
		return
	
	_scale_down(image)
	var texture = ImageTexture.create_from_image(image)
	
	## 延迟原场景树的节点使用的函数的时机，在空闲帧进行调用，避免冲突
	## call_deferred()： 当你需要在非主线程中调用主线程的方法时使用
	card.call_deferred("set_image", texture) 


func _scale_down(image : Image):
	var image_size = image.get_size()  # 获得图片大小
	
	if max(image_size.x, image_size.y) <= IMAGE_MAX_SIZE:
		return
	
	var image_aspect = image_size.aspect()  # 获得长宽比
	var new_w = 0
	var new_h = 0
	
	if image_aspect > 1:
		new_w = IMAGE_MAX_SIZE
		new_h = IMAGE_MAX_SIZE / image_aspect
	else:
		new_w = IMAGE_MAX_SIZE * image_aspect
		new_h = IMAGE_MAX_SIZE
	
	image.resize(new_w, new_h)


### Signals

func _on_card_pressed(card : Card):
	var image_path = card.get_meta("image_path")
	OS.shell_open(image_path)


func _on_timer_timeout():
	create_cards_from_files(page_manager.get_page_files(all_files))


func _on_page_changed():
	## 页面切换时
	_timer.start()          # 缓冲timer
	loading.start()         # 显示加载画面
