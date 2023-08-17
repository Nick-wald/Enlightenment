extends GUIModel
class_name Transition

### 常量
# 提示文字控件
@onready var Tip:RichTextLabel = $TopVBoxContainer/TopRect/Container/VBoxContainer/Tip
# 进度条控件
@onready var Bar:ProgressBar = $ButtomVBoxContainer/ButtomRect/VBoxContainer/ProgressBar
# 底部文字控件
@onready var ButtomText:RichTextLabel = $ButtomVBoxContainer/ButtomRect/VBoxContainer/ButtomText
# 动画
@onready var Anim:AnimationPlayer = $AnimationPlayer
# 加载状态
enum LOADSTATE {START, PREPARE, PREPARE_CHILD, LOADED, FINISHED}
# 默认提示持续时间
const duration:float = 6
### 变量
# 加载队列
var LoadList:Array = []
# 加载总数
var total:int = 0
# 已加载
var count:int = 0
# 迭代器
var current:int = 0
var current_child:int = 0
# 当前加载路径
var current_loading_path:String = "null"
# 当前加载状态
var load_state:LOADSTATE = LOADSTATE.START
# 当前加载进度
var prograss:Array = [0]
# 结束后等待按键继续
var pressButtomToContinue:bool = false
# 结束后切换场景
var gotoScene:String = "null"
var gotoScenePath:String = "null"
var gotoSceneLayer = "0"
# 提示
var Tips:Dictionary = {}

func _draw():
	pass

func _ready():
	RANDOMTIP()

func _process(_delta):
	if not visible and not Global.USENODE("TOP").Anim.current_animation == "TOPMaskTranIn":
		set_visible(true)
	# 加载
	if load_state == LOADSTATE.PREPARE:
		Bar.set_value(float((count + prograss[0])/total))
		if prograss[0]:
			ButtomText.set_text("[center][color=#F5F5DC]%d/%d: 当前正在加载 %s （%d %%）[/color][/center]" % [count, total, current_loading_path, prograss[0]*100])
		else:
			ButtomText.set_text("[center][color=#F5F5DC]%d/%d: 当前正在加载 %s[/color][/center]" % [count, total, current_loading_path])
		# 迭代
		match LoadList[current].state:
			LOADSTATE.START:
				if LoadList[current].has("child"):
					LoadList[current].state = LOADSTATE.PREPARE_CHILD
				else:
					LoadList[current].state = LOADSTATE.PREPARE
					count += 1
					current_loading_path = LoadList[current].path + LoadList[current].name + ".tscn"
					ResourceLoader.load_threaded_request(current_loading_path)
			LOADSTATE.PREPARE_CHILD:
				if LoadList[current]["child"][current_child].state == LOADSTATE.START:
					LoadList[current]["child"][current_child].state = LOADSTATE.PREPARE
					count += 1
					current_loading_path = LoadList[current].path + LoadList[current]["child"][current_child].name + ".tscn"
					ResourceLoader.load_threaded_request(current_loading_path)
				if ResourceLoader.load_threaded_get_status(current_loading_path, prograss) == ResourceLoader.THREAD_LOAD_LOADED:
					LoadList[current]["child"][current_child].state = LOADSTATE.LOADED
					if current_child + 1 < LoadList[current]["child"].size():
						current_child += 1
					else:
						current_child = 0
						LoadList[current].state = LOADSTATE.PREPARE
						count += 1
						current_loading_path = LoadList[current].path + LoadList[current].name + ".tscn"
						ResourceLoader.load_threaded_request(current_loading_path)
			LOADSTATE.PREPARE:
				if ResourceLoader.load_threaded_get_status(current_loading_path, prograss) == ResourceLoader.THREAD_LOAD_LOADED:
					LoadList[current].state = LOADSTATE.LOADED
					if current + 1 < LoadList.size():
						current += 1
					else:
						load_state = LOADSTATE.LOADED
						if pressButtomToContinue:
							LOAD()
							PRESSTOCONTINUE()
						else:
							LOAD()
							Global.USENODE("TOP").RECTMASKTRAN(Callable(self, "GOTO"))
	elif load_state == LOADSTATE.LOADED and pressButtomToContinue and Input.is_anything_pressed():
		Global.USENODE("TOP").RECTMASKTRAN(Callable(self, "GOTO"))
		load_state = LOADSTATE.FINISHED

# 随机提示
func RANDOMTIP() -> void:
	var i:int
	randomize()
	Global.TransitionTip["Tips"].shuffle()
	while true:
		if not i < Global.TransitionTip["Tips"].size():
			i = 0
			randomize()
			Global.TransitionTip["Tips"].shuffle()
		var tip:Dictionary = Global.TransitionTip["Tips"][i]
		var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(Tip, "modulate:a", 0, 0.5)
		tween.chain().tween_callback(Callable(self, "set_tip").bind(tip.text))
		tween.chain().tween_property(Tip, "modulate:a", 1, 0.5)
		if tip.has("duration"):
			await get_tree().create_timer(float(tip.duration)).timeout
		else:
			await get_tree().create_timer(float(duration)).timeout
		i += 1

# 设置提示文字
func set_tip(text:String):
	Tip.set_use_bbcode(true)
	Tip.set_fit_content(true)
	Tip.set_autowrap_mode(TextServer.AUTOWRAP_OFF)
	Tip.set_text("[center][color=#F5F5DC]" + text + "[/color][/center]")

# 载入节点
func NODELOAD(path:String, nodename:String, node:Node = get_node("/root/AutoLoad"), layer = 0, childlist:Array = []) -> void:
	match ResourceLoader.load_threaded_get_status(path + nodename + ".tscn"):
		ResourceLoader.THREAD_LOAD_LOADED:
			var scene:PackedScene = ResourceLoader.load_threaded_get(path + nodename + ".tscn")
			if scene and scene.can_instantiate():
				var child = scene.instantiate()
				if child is CanvasItem:
					child.set_z_index(int(layer))
				if not childlist.is_empty():
					for item in childlist:
						if ResourceLoader.load_threaded_get_status(path + item.name + ".tscn") == ResourceLoader.THREAD_LOAD_LOADED:
							var childscene:PackedScene = ResourceLoader.load_threaded_get(path + item.name + ".tscn")
							if childscene and childscene.can_instantiate():
								child.add_child(childscene.instantiate())
				if not child.has_method("_GUI_init"):
					node.add_child(child)
				else:
					(Global.USENODE("GUIManager") as GUIManager).GUIRegister(child)
				Global.InstIDList[nodename] = child.get_instance_id()
			else:
				Global.USENODE("TOP").CONSOLEERROR(path + nodename + " cannot be instantiated.", "Transition.NODELOAD()")
		ResourceLoader.THREAD_LOAD_FAILED:
			Global.USENODE("TOP").CONSOLEERROR(path + nodename + " load failed.", "Transition.NODELOAD()")
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			Global.USENODE("TOP").CONSOLEERROR(path + nodename + " is invalid.", "Transition.NODELOAD()")
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			Global.USENODE("TOP").CONSOLEERROR(path + nodename + " is still in loading.", "Transition.NODELOAD()")

# 加载入口
func TRANSITION(ReceivedLoadList:Dictionary, goto:String = "null", pressAnyButtom:bool = false) -> void:
	# 初始化
	LoadList.clear()
	gotoScene = goto
	pressButtomToContinue = pressAnyButtom
	
	# 卸载之前的场景
	Global.AutoLoad.NODEREMOVE(Global.current_scene)
	
	# 更新场景信息
	Global.current_scene = self.name
	
	# 计算加载项目总数，初始化加载队列
	for path in ReceivedLoadList.keys():
		if typeof(ReceivedLoadList[path]) != TYPE_ARRAY:
			Global.USENODE("TOP").CONSOLEERROR("Unexpected format in LoadList."+path, "Transition.TRANSITION()")
			continue
		for item in ReceivedLoadList[path]:
			if not item.has("layer"):
				item["layer"] = Global.DefaultSceneLayer
			if typeof(item) != TYPE_DICTIONARY:
				Global.USENODE("TOP").CONSOLEERROR("Unexpected format in LoadList."+path+".item", "Transition.TRANSITION()")
				continue
			if item.has("child"):
				LoadList.append({"path": path , "name": item.name , "layer": item.layer, "state": LOADSTATE.START})
				LoadList.back().child = []
				for child in item["child"]:
					LoadList.back().child.append({"name": child, "state": LOADSTATE.START})
				total += item["child"].size() + 1
			else:
				LoadList.append({"path": path , "name": item.name , "layer": item.layer, "state": LOADSTATE.START})
				total += 1
	PREPARE()

# 载入
func LOAD() -> void:

	for item in LoadList:
		if not item.name == gotoScene:
			if not Global.InstIDList.has(item.name):
				if not item.has("layer"):
					item["layer"] = Global.DefaultSceneLayer
				if not item.has("child"):
					NODELOAD(item.path, item.name, get_node("/root/AutoLoad"), item.layer)
				else:
					NODELOAD(item.path, item.name, get_node("/root/AutoLoad"), item.layer, item.child)
			else:
				Global.USENODE("TOP").CONSOLEWARN(item.name + " already existed in InstIDList.", "Transition.LOAD()")
		else:
			gotoScenePath = item.path
			gotoSceneLayer = item.layer

# 切换场景
func GOTO() -> void:
	if gotoScene != "null" and gotoScenePath != "null":
		NODELOAD(gotoScenePath, gotoScene, get_node("/root/AutoLoad"), gotoSceneLayer)
		Global.current_scene = gotoScene
		Global.SceneStack.push_back(gotoScene)

		Global.AutoLoad.NODEREMOVE(self.name)
		print("\nTree: \n")
		get_node("/root/AutoLoad").print_tree_pretty()
	else:
		Global.USENODE("TOP").CONSOLEERROR("gotoScene or gotoScenePath is null.", "Transition.GOTO()")
		if not Global.SceneStack.is_empty():
			Global.USENODE(Global.SceneStack.back())

# 预读取
func PREPARE() -> void:
	load_state = LOADSTATE.PREPARE
	
# 任意键继续
func PRESSTOCONTINUE() -> void:
	Anim.queue("pressAnyKeyToContinue")
	Anim.queue("pressAnyKeyToContinueFlash")
	Input.flush_buffered_events()
