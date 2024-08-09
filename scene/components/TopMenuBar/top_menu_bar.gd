extends PanelContainer

signal folder_selected(dir_path : String)

@onready var menu_file = %File
@onready var menu_edit = %Edit
@onready var menu_help = %Help

enum MENUFILE { open, }

func _ready():
	init_menu_file()

func init_menu_file():
	menu_file.clear()
	menu_file.add_item("Open", MENUFILE.open)
	menu_file.id_pressed.connect(_call_menu_file)


### Signals

func _call_menu_file(id : int):
	if id == MENUFILE.open:
		DisplayServer.file_dialog_show("Open folder",
										"",
										"",
										false,
										DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, # 选择文件夹目录
										[], # 文件过滤
										_on_folder_selected)

## 文件夹目录选择后回调的函数
func _on_folder_selected(status : bool, selected_paths : PackedStringArray, selected_filter_index : int): # 参数使用文档给出的默认
	if not status: # 是否成功选择文件夹
		return
	
	folder_selected.emit(selected_paths[0])
