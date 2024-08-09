extends PanelContainer

signal directory_changed

@export var ICON_FOLDER : Resource

@onready var tree = %Tree # 目录树

var is_loading_saved_dir : bool = true  # 保证第一次加载不会清空 current_directory 

var file_path : String :
	set(value):
		assert(DirAccess.dir_exists_absolute(value), "File path must exist!")
		file_path = value
		
		if is_loading_saved_dir:
			is_loading_saved_dir = false
		else:
			current_directory = ""
		
		Globals.user_data.file_path = value
		if is_inside_tree():  # 进入节点树再调用 （查: godot节点调用顺序）
			_init_file_path()


var current_directory : String : 
	set(value):
		current_directory = value
		Globals.user_data.selected_directory = value
		directory_changed.emit() 


var root : TreeItem  # 整个根节点


func _ready():
	tree.hide_root = true # 隐藏根节点
	tree.item_selected.connect(_on_item_selected) # 按下 tree_item 发送的信号


## 修改文件路径
func set_file_path(path : String):
	file_path = path


func get_current_directory() -> String:
	return current_directory


func select_directory(path : String):
	current_directory = path
	_BFS_select_and_nocollapsed_dir()

## 第一次启动时，选上该选的目录
## 并让该目录的父节点目录取消折叠状态
func _BFS_select_and_nocollapsed_dir():
	var queue := [root] as Array[TreeItem]
	var father := {} as Dictionary
	while queue:
		var front := queue.pop_front() as TreeItem
		if front.get_metadata(0) == current_directory:
			var now = front
			while father.has(now):
				now = father[now]
				now.collapsed = false
			front.select(0)  
			break
		
		for child in front.get_children():
			queue.append(child)
			father[child] = front


## 文件路径(树根)修改后调用
func _init_file_path():
	tree.clear()
	root = tree.create_item()
	
	if not file_path or not DirAccess.dir_exists_absolute(file_path): # 路径是否合法
		return
		
	create_tree_from_dir(root, file_path)


## 初始化目录节点
func create_tree_from_dir(parent : TreeItem, directory : String): # 传入父节点和目录
	## 遍历目录中文件
	var dir := DirAccess.open(directory) as DirAccess
	
	for sub_dir in dir.get_directories():
		var sub_tree_item := tree.create_item(parent) as TreeItem # 当前 tree_item
		
		## 设置 item 属性
		sub_tree_item.set_icon(0, ICON_FOLDER)
		sub_tree_item.set_icon_max_width(0, 21)
		sub_tree_item.set_text(0, sub_dir)
		sub_tree_item.collapsed = true          # 默认关闭
		
		## 递归子节点的子节点
		var sub_dir_path := directory + '/' + sub_dir
		sub_tree_item.set_metadata(0, sub_dir_path) # 设置 tree_item 数据
		
		create_tree_from_dir(sub_tree_item, sub_dir_path)


## 获取当前 tree_item 路径下的所有 文件 的路径
func get_current_directory_files() -> Array[String]:
	if not current_directory or not DirAccess.dir_exists_absolute(file_path): # 路径是否合法
		return [] as Array[String]
	
	## 构造 文件路径 + 文件名
	var res_dir = [] as Array[String]
	for file in DirAccess.get_files_at(current_directory):
		res_dir.append(current_directory + "/" + file)
	
	return res_dir


## 获取当前 tree_item 路径
func _get_directory_from_selection() -> String:
	var current_item := tree.get_selected() as TreeItem
	if current_item:
		return current_item.get_metadata(0)
	
	return ""



### Signals

## 选择的 tree_item 发生改变，激活信号
func _on_item_selected():
	current_directory = _get_directory_from_selection()

