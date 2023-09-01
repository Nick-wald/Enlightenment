extends Node
class_name AutoLoad # 初始化、自动载入

### 常量
# 场景资源根目录
const ScenesPath:String = "res://scenes/"
# 系统资源根目录
const SystemsPath:String = "res://AutoLoad/"
# 用户数据根目录
const UserDataPath:String = "user://"
# 鼠标精灵表
const CursorList:Dictionary = {
	"default": "res://sources/GUI/cursor_default.png"
}
### 全局变量
# 场景列表
var ScenesList:Dictionary
# 系统列表
var SystemsList:Dictionary
# DEBUG
var DEBUG:bool = false:
	set(value):
		DEBUG = value
		(Global.USENODE("TOP") as TOP).switchDEBUGmsg()

func _ready():
	# 初始化
	if not FileAccess.file_exists(Global.AutoLoad.UserDataPath + "config.ini"):
		INITSETTING()
	
	START()
	
	# 载入队列构建
	var InitList:Dictionary = {
		SystemsPath: [],
		ScenesPath: []
	}
	for item in (SystemsList["systems"] as Array):
		if (SystemsList["Start"] as Array).has((item.name as String)):
			(InitList[SystemsPath] as Array).push_back((item as Dictionary))
	for item in (ScenesList["scenes"] as Array):
		if (ScenesList["Beginning"] as String) == (item.name as String):
			(InitList[ScenesPath] as Array).push_back((item as Dictionary))
	(Global.USENODE(ScenesList["Transition"]) as Transition).TRANSITION(InitList, ScenesList["Beginning"], true)

func _process(_delta):
	# DEBUG
	if Input.is_action_just_pressed("ui_debug"):
		DEBUG = !DEBUG
		if DEBUG:
			(Global.USENODE("TOP") as TOP).TIP("[b][color=yellow]DEBUG ON[/color][/b]")
		else:
			(Global.USENODE("TOP") as TOP).TIP("[b][color=yellow]DEBUG OFF[/color][/b]")
	if not Global.UnpausableScenesList.has(Global.current_scene) and Input.is_action_just_pressed("ui_menu"):
		pass

# 退出时操作
func _exit_tree():
	WRITEINI()

# 退出游戏
func QUITGAME() ->void:
	print_tree_pretty()
	get_tree().quit()

# 暂停游戏
func PAUSEGAME() -> void:
	pass

# 唤出主菜单
func MENU() -> void:
	pass

# 读取文本文件
func READFILE(path:String) -> String:
	if FileAccess.file_exists(path):
		var file:FileAccess = FileAccess.open(path, FileAccess.READ)
		var content:String = file.get_as_text()
		return content
	else:
		return "null"

# 读取JSON文件
func READJSON(path: String) -> Dictionary:
	return JSON.parse_string(READFILE(path))

# 读取ini配置文件
func READINI(path:String = Global.AutoLoad.UserDataPath + "config.ini") -> void:
	var config:ConfigFile = ConfigFile.new()
	if config.load(path) == OK:
		Global.Setting["version"] = config.get_value("Basic", "version", "1.0.0")
		Global.Setting["savetime"] = Time.get_datetime_dict_from_datetime_string(config.get_value("Basic", "savetime"), false)
		for section in Global.Setting["config"].keys():
			if config.has_section(section):
				for key in Global.Setting["config"][section].keys():
					if config.has_section_key(section, key):
						Global.Setting["config"][section][key] = config.get_value(section, key)
	else:
		WRITEINI(path)

# 写入ini配置文件
func WRITEINI(path: String = Global.AutoLoad.UserDataPath + "config.ini") -> void:
	var config:ConfigFile = ConfigFile.new()
	for section in Global.Setting["config"].keys():
			for key in Global.Setting["config"][section].keys():
				config.set_value(section, key, Global.Setting["config"][section][key])
	config.set_value("Basic", "version", Global.Setting["version"])
	config.set_value("Basic", "savetime", Time.get_datetime_string_from_system())
	Global.Setting["savetime"] = Time.get_datetime_dict_from_system()
	config.save(path)

# 写入文件
func WRITEFILE(path:String, content:String) -> void:
	var file:FileAccess = FileAccess.open(path, FileAccess.READ_WRITE)
	file.store_string(content)

# 节点导入
func NODELOAD(path:String, nodename:String, node:Node = get_node("/root/AutoLoad"), layer = 0, childlist:Array = []) -> void:
	if Global.InstIDList.has(nodename):
		(Global.USENODE("TOP") as TOP).CONSOLEWARN(nodename + " had already in the InstIDList.", "AutoLoad.NODELOAD()")
		return
	var scene:PackedScene = load(path + nodename + ".tscn")
	if scene and scene.can_instantiate():
		var item = scene.instantiate()
		if item is CanvasItem:
			(item as CanvasItem).set_z_index(int(layer))
		if not childlist.is_empty():
			for child in childlist:
				var childscene:PackedScene = load(path + child + ".tscn")
				if childscene and childscene.can_instantiate():
					item.add_child(childscene.instantiate())
		if not item.has_method("_GUI_init"):
			(node as Node).add_child(item)
		else:
			(Global.USENODE("GUIManager") as GUIManager).GUIRegister(item)
		Global.InstIDList[nodename] = item.get_instance_id()
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEERROR(path + nodename + " is not found or cannot be instantiated.", "AutoLoad.NODELOAD()")

# 节点销毁
func NODEREMOVE(nodename:String) -> void:
	if nodename != "null" and Global.InstIDList.has(nodename):
		var inst:Object = instance_from_id(Global.InstIDList[nodename])
		if inst.has_method("queue_free"):
			inst.call("queue_free")
		else:
			inst.free()
		Global.InstIDList.erase(nodename)

# 模块加载（不带过渡）
func NODELOADLIST(node_array:Array) -> void:
	for item in node_array:
		Global.USENODE(item)

# 场景切换（带过渡）
func TRANSITION(gotoScene:String, Systems:Array = [], pressToContinue:bool = false) -> void:
	# 加载列表
	var InitList:Dictionary = {
		SystemsPath: [],
		ScenesPath: []
	}
	for item in ScenesList["scenes"]:
		if gotoScene == item.name:
			InitList[ScenesPath].push_back(item)
	for item in SystemsList["systems"]:
		if Systems.has(item.name):
			InitList[SystemsPath].push_back(item)
	if InitList[ScenesPath].is_empty():
		(Global.USENODE("TOP") as TOP).CONSOLEERROR("Cannot find " + gotoScene + " in the ScenesList.", "AutoLoad.TRANSITION()")
		return
	(Global.USENODE("TOP") as TOP).RECTMASKTRAN(Callable((Global.USENODE(ScenesList["Transition"]) as Transition), "TRANSITION"), [InitList, gotoScene, pressToContinue])

# 初始化（第一次进入游戏/设置文件缺失 = "all"）
func INITSETTING(settingFlag:String = "all") -> void:
	if settingFlag == "all":
		pass
	else:
		pass

# 初始化
func START() -> void:
	## 系统级初始化
	OS.set_thread_name("Enlightenment")
	# 注册AutoLoad实例ID
	Global.InstIDList["AutoLoad"] = get_instance_id()
	# 加载配置
	Global.TransitionTip = READJSON(SystemsPath + "Transition.json")
	ScenesList = READJSON(ScenesPath + "ScenesList.json")
	SystemsList = READJSON(SystemsPath + "SystemsList.json")
	Global.Setting = READJSON(SystemsPath + "config.json")
	READINI()
	
	Global.USENODE("EnvManager")
	
	# 设置鼠标
	(Global.USENODE("GUIManager") as GUIManager).setCursor("default", CursorList["default"])
	# 加载禁止暂停列表
	for scene in ScenesList["scenes"]:
		if scene.has("pausable") and !scene.pausable:
			Global.UnpausableScenesList.push_back(scene.name)
	for scene in SystemsList["systems"]:
		if scene.has("pausable") and !scene.pausable:
			Global.UnpausableScenesList.push_back(scene.name)
	
	if updateCheck():
		OS.set_restart_on_exit(true)
		var updatefinishedPopup:Popup = Popup.new()
		updatefinishedPopup.title = "更新完成"
		updatefinishedPopup.popup_centered()
		await updatefinishedPopup.close_requested
		QUITGAME()

# 检查更新
func updateCheck() -> bool:
	return false
