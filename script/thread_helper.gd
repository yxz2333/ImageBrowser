@tool
class_name ThreadHelper

extends RefCounted

var _thread = Thread.new()
var _functions : Array[Callable] = []
var _holder : Node   # TH类被使用的节点


func _init(holder : Node):
	_holder = holder
	_holder.tree_exited.connect(end)  # 节点退出进程树后，使用end函数结束进程


func join_function(function : Callable):
	_functions.append(function)


func join_functions(functions : Array[Callable]):
	_functions.append_array(functions)


func start():
	if _thread.is_alive():       # 已经开启进程
		return
	
	if _thread.is_started():     # 确保当前进程跑完
		_thread.wait_to_finish()
	
	_thread.start(_start_thread) # 跑新进程


func end():
	_end_thread()


func is_running() -> bool:
	return _thread.is_alive()


## 按列表顺序跑函数
func _start_thread():
	while _functions:
		var function = _functions.pop_front()
		function.call()


## 清空函数与进程
func _end_thread():
	_functions = []
	if _thread.is_alive():
		_thread.wait_to_finish()
