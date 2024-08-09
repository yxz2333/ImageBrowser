extends Control

@onready var top_menu_bar = %TopMenuBar
@onready var files_manager = %FilesManager
@onready var viewer = %Viewer

const IMAGE_EXTENSIONS = ["png", "jpg", "svg"]


func _ready():
	## 初始化信号
	files_manager.directory_changed.connect(_on_directory_changed)     # 选择的子路径发生改变
	top_menu_bar.folder_selected.connect(files_manager.set_file_path)  # 打开的目录发生改变
	init.call_deferred()


func init():
	Globals.load_data()
	
	var file_path = Globals.user_data.file_path
	if DirAccess.dir_exists_absolute(file_path):
		files_manager.set_file_path(file_path)
	
	var selected_directory = Globals.user_data.selected_directory
	files_manager.select_directory(selected_directory)



### Signals

## 从 FilesManager 里获取当前目录所有文件
func _on_directory_changed():
	var files = files_manager.get_current_directory_files()
	var images = _filter_images(files)
	viewer.init_cards_from_files(images)

## 文件过滤，只要图片格式的
func _filter_images(files : Array[String]) -> Array[String]:
	if not files:
		return []
	
	var res_files = [] as Array[String]
	for file in files:
		if file.get_extension() in IMAGE_EXTENSIONS:
			res_files.append(file)
	
	return res_files
 
