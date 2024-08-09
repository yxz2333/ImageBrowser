@tool
class_name ThreadPool

extends RefCounted

var max_threads : int = 4

var _threads   := [] as Array[ThreadHelper]
var _functions := [] as Array[Callable]
var _mutex     := Mutex.new() as Mutex
var _holder : Node   # TP类被使用的节点


func set_max_threads(num : int):
	max_threads = num


func _init(holder : Node):
	_holder = holder
	_holder.tree_exited.connect(end)  # 节点退出进程树后，使用end函数结束进程池
	
	for i in range(max_threads):
		var thread_helper = ThreadHelper.new(_holder)
		_threads.append(thread_helper)


## 清空线程池
func _end_thread_pool():
	for i in range(max_threads):
		_threads[i].end()


func start():
	while _functions:
		for i in range(max_threads):
			_threads[i].join_function(_functions.pop_front())
			
			if not _functions:
				break
				
	for i in range(max_threads):
		_mutex.lock()
		_threads[i].start()
		_mutex.unlock()


func end():
	_mutex.unlock()
	_end_thread_pool()


func join_function(function : Callable):
	_functions.append(function)


func join_functions(functions : Array[Callable]):
	_functions.append_array(functions)
