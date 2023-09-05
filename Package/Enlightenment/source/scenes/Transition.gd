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
var gotoScene:Dictionary = {}
# 提示
var Tips:Dictionary = {}

func _draw():
	pass

func _ready():
	RANDOMTIP()

func _process(_delta):
	if not visible and not (Global.USENODE("TOP") as TOP).Anim.current_animation == "TOPMaskTranIn":
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
					current_loading_path = loadingPath(LoadList[current])
					ResourceLoader.load_threaded_request(current_loading_path)
			LOADSTATE.PREPARE_CHILD:
				if LoadList[current]["child"][current_child].state == LOADSTATE.START:
					LoadList[current]["child"][current_child].state = LOADSTATE.PREPARE
					count += 1
					current_loading_path = loadingPath(LoadList[current]["child"][current_child])
					ResourceLoader.load_threaded_request(current_loading_path)
				if ResourceLoader.load_threaded_get_status(current_loading_path, prograss) == ResourceLoader.THREAD_LOAD_LOADED:
					LoadList[current]["child"][current_child].state = LOADSTATE.LOADED
					if current_child + 1 < LoadList[current]["child"].size():
						current_child += 1
					else:
						current_child = 0
						LoadList[current].state = LOADSTATE.PREPARE
						count += 1
						current_loading_path = loadingPath(LoadList[current])
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
							(Global.USENODE("TOP") as TOP).RECTMASKTRAN(Callable(self, "GOTO"))
							load_state = LOADSTATE.FINISHED
	elif load_state == LOADSTATE.LOADED and pressButtomToContinue and Input.is_anything_pressed():
		(Global.USENODE("TOP") as TOP).RECTMASKTRAN(Callable(self, "GOTO"))
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

# 加载入口
func TRANSITION(ReceivedLoadList:Dictionary) -> void:
	# 初始化
	LoadList.clear()
	gotoScene = ReceivedLoadList["gotoScene"]
	pressButtomToContinue = ReceivedLoadList["pressToContinue"]
	
	# 卸载之前的场景
	Global.NODEREMOVE(Global.current_scene.name, Global.current_scene.package)
	
	# 更新场景信息
	Global.setCurrentScene(self.name)
	
	# 计算加载项目总数，初始化加载队列
	if not (ReceivedLoadList["Resources"] as Array).is_empty():
		pass
	
	if not (ReceivedLoadList["Components"] as Array).is_empty():
		for component in ReceivedLoadList["Components"]:
			if typeof(component) != TYPE_DICTIONARY:
				(Global.USENODE("TOP") as TOP).CONSOLEERROR("Unexpected format in LoadList.", "Transition.TRANSITION()")
				continue
			
			if not component.has("layer"):
				component["layer"] = Global.DefaultSceneLayer
			if not component.has("target"):
				component["target"] = Global.AutoLoad
			LoadList.append({
				"package": component.package,
				"path": (Global.AutoLoad as AutoLoad).PackageAddress(component.package) + (Global.AutoLoad as AutoLoad).getPackageCig(component.package, "componentsPath"),
				"name": component.name,
				"layer": component.layer,
				"target": component.target,
				"state": LOADSTATE.START,
				"type": "component",
				})
			if component.has("child"):
				LoadList.back()["child"] = Array()
				for child in component["child"]:
					(LoadList.back()["child"] as Array).append({
						"package": component.package,
						"path": LoadList.back()["path"],
						"name": child,
						"state": LOADSTATE.START,
						"target": component.name,
						"type": "subcomponent"
					})
				total += component["child"].size() + 1
			else:
				total += 1
	
	if not (ReceivedLoadList["Scenes"] as Array).is_empty():
		for scene in ReceivedLoadList["Scenes"]:
			if typeof(scene) != TYPE_DICTIONARY:
				(Global.USENODE("TOP") as TOP).CONSOLEERROR("Unexpected format in LoadList.", "Transition.TRANSITION()")
				continue
			
			if not scene.has("layer"):
				scene["layer"] = Global.DefaultSceneLayer
			if not scene.has("target"):
				scene["target"] = Global.AutoLoad
			LoadList.append({
				"package": scene.package,
				"path": (Global.AutoLoad as AutoLoad).PackageAddress(scene.package) + (Global.AutoLoad as AutoLoad).getPackageCig(scene.package, "scenesPath"),
				"name": scene.name,
				"layer": scene.layer,
				"target": scene.target,
				"state": LOADSTATE.START,
				"type": "scene",
				})
			total += 1
	
	PREPARE()

# 载入
func LOAD() -> void:
	for item in LoadList:
		if item["type"] == "component":
			(Global.AutoLoad as AutoLoad).NODELOAD(item)
		if item["type"] == "scene" and not item["name"] == gotoScene.name and not item["package"] == gotoScene.package:
			(Global.AutoLoad as AutoLoad).NODELOAD(item)
		else:
			gotoScene = item

# 切换场景
func GOTO() -> void:
	if not gotoScene.is_empty():
		(Global.AutoLoad as AutoLoad).NODELOAD(gotoScene)
		Global.setCurrentScene(gotoScene.name, gotoScene.package)
		Global.SceneStack.push_back(gotoScene)

		Global.NODEREMOVE(self.name)
		print_tree_pretty()
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEERROR("gotoScene.", "Transition.GOTO()")
		if not Global.SceneStack.is_empty():
			var scene:Dictionary = Global.SceneStack.pop_back()
			Global.USENODE(scene.name, scene.package)

# 预读取
func PREPARE() -> void:
	load_state = LOADSTATE.PREPARE
	
# 任意键继续
func PRESSTOCONTINUE() -> void:
	Anim.queue("pressAnyKeyToContinue")
	Anim.queue("pressAnyKeyToContinueFlash")
	Input.flush_buffered_events()

# 加载路径构造器
func loadingPath(item:Dictionary) -> String:
	var fileType:String = ".tscn"
	match item.type:
		"scene":
			fileType = ".tscn"
		"component":
			fileType = ".tscn"
		"subcomponent":
			fileType = ".tscn"
		_:
			fileType = ".tscn"
	return item.path + item.name + fileType
