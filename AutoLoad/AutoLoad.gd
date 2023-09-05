extends Node
class_name AutoLoad # 初始化、自动载入

### 常量
# 系统资源根目录
const AutoLoadPath:String = "res://AutoLoad/"
# 用户数据根目录
const UserDataPath:String = "user://"
# 鼠标精灵表
const CursorList:Dictionary = {
	"default": "res://sources/GUI/cursor/cursor_default.png"
}
### 全局变量
# 场景列表
var Beginning:Dictionary = {
	"package": "",
	"name": ""
}
var Tran:Dictionary = {
	"package": "",
	"name": ""
}
# 系统列表

# 包路径
var PackagePath:Array[String] = ["res://Package/", "user://Package/"]
# 包池
var PackPool:Dictionary = {}
var LoadedPackage:Array[String] = []
var enablePack:Dictionary = {}
# DEBUG
var DEBUG:bool = false:
	set(value):
		DEBUG = value
		(Global.USENODE("TOP") as TOP).switchDEBUGmsg()

func _ready():
	# 初始化
	if not FileAccess.file_exists(UserDataPath + "config.ini"):
		INITSETTING()
	
	START()
	
	# 载入开始界面
	TRANSITION(Beginning, )

func _process(_delta):
	# DEBUG
	if Input.is_action_just_pressed("ui_debug"):
		DEBUG = !DEBUG
		if DEBUG:
			(Global.USENODE("TOP") as TOP).TIP("[b][color=yellow]DEBUG ON[/color][/b]")
		else:
			(Global.USENODE("TOP") as TOP).TIP("[b][color=yellow]DEBUG OFF[/color][/b]")

# 退出时操作
func _exit_tree():
	# 保存设置
	Global.saveSetting()

# 退出游戏
func QUITGAME() ->void:
	saveEnablePack()
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
func READINI(path:String = UserDataPath + "config.ini") -> void:
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
func WRITEINI(path: String = UserDataPath + "config.ini") -> void:
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
	var file:FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)

# 写入JSON
func WRITEJSON(path:String, content:Dictionary) -> void:
	WRITEFILE(path, JSON.stringify(content, "\t"))

# 节点导入
func NODELOAD(node:Dictionary, target:Node = get_node("/root/AutoLoad")) -> void:
	
	if Global.InstIDList.has(node.package + "/" + node.name):
		(Global.USENODE("TOP") as TOP).CONSOLEWARN(node.package + "/" + node.name + " had already in the InstIDList.", "AutoLoad.NODELOAD()")
		return
	
	var loadNode:PackedScene = load(loadingPath(node) + node.name + ".tscn")
	
	if loadNode and loadNode.can_instantiate():
		var item = loadNode.instantiate()
		if item is CanvasItem:
			(item as CanvasItem).set_z_index(int(node.layer))
		if node.has("child") and not (node["child"] as Array).is_empty():
			for child in node["child"]:
				if typeof(child) == TYPE_STRING:
					child = {
						"package": node.package,
						"name": child,
						"type": "subcomponent"
					}
				if typeof(child) == TYPE_DICTIONARY:
					child["type"] = "subcomponent"
				var childNode:PackedScene = load(loadingPath(child) + child.name + ".tscn")
				if childNode and childNode.can_instantiate():
					item.add_child(childNode.instantiate())
		if not item.has_method("_GUI_init"):
			if node.has("target"):
				if node.target is Node:
					(node.target as Node).add_child(item)
				elif typeof(node.target) == TYPE_DICTIONARY:
					Global.USENODE(node.target.name, node.target.package).add_child(item)
				elif typeof(node.target) == TYPE_STRING:
					Global.USENODE(node.target, node.package).add_child(item)
			else:
				(target as Node).add_child(item)
		else:
			(Global.USENODE("GUIManager") as GUIManager).GUIRegister(item)
		Global.InstIDList[node.package + "/" + node.name] = item.get_instance_id()
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEERROR(node.package + "/" + node.name + " is not found or cannot be instantiated.", "AutoLoad.NODELOAD()")

# 获取加载路径
func loadingPath(node:Dictionary) -> String:
	if node.has("path"):
		return node.path
	elif node.has("type"):
		match node.type:
			"scene":
				return PackageAddress(node.package) + getPackageCig(node.package, "scenesPath")
			"component":
				return PackageAddress(node.package) + getPackageCig(node.package, "componentsPath")
			"subcomponent":
				return PackageAddress(node.package) + getPackageCig(node.package, "componentsPath")
			"PackageAutoLoad":
				return PackageAddress(node.package)
			_:
				return PackageAddress(node.package)
	else:
		return PackageAddress(node.package)

# 模块加载（不带过渡）
func NODELOADLIST(node_array:Array) -> void:
	for item in node_array:
		if typeof(item) == TYPE_DICTIONARY and (item as Dictionary).has("package"):
			Global.USENODE(item.name, item.package)
		elif typeof(item) == TYPE_DICTIONARY:
			Global.USENODE(item.name)
		elif typeof(item) == TYPE_STRING:
			Global.USENODE(item)

# 场景切换（带过渡）
func TRANSITION(gotoScene, Scenes:Array = [], Components:Array = [], Resources:Array = [], pressToContinue:bool = false) -> void:
	# 转化gotoScene格式
	if typeof(gotoScene) == TYPE_STRING:
		gotoScene = {
			"package": Global.DefaultPackage,
			"name": gotoScene
		}
	elif typeof(gotoScene) == TYPE_DICTIONARY and not (gotoScene as Dictionary).has("package"):
			gotoScene["package"] = Global.DefaultPackage
	
	var checkGoto:bool = false
	for index in range(Scenes.size()):
		# 转化Scenes格式
		if typeof(Scenes[index]) == TYPE_STRING:
			Scenes[index] = {
				"package": Global.DefaultPackage,
				"name": Scenes[index]
			}
		elif typeof(Scenes[index]) == TYPE_DICTIONARY and not (Scenes[index] as Dictionary).has("package"):
			Scenes[index]["package"] = Global.DefaultPackage
		if not checkGoto and Scenes[index]["package"] == gotoScene.package and Scenes[index]["name"] == gotoScene.name:
			checkGoto = true
	# 如果Scenes没有gotoScene则补充
	if not checkGoto:
		Scenes.append(gotoScene)
	
	for index in range(Components.size()):
		# 转化Components格式
		if typeof(Components[index]) == TYPE_STRING:
			Components[index] = {
				"package": Global.DefaultPackage,
				"name": Components[index]
			}
		elif typeof(Components[index]) == TYPE_DICTIONARY and not (Components[index] as Dictionary).has("package"):
			Components[index]["package"] = Global.DefaultPackage
	
	# 构建加载列表
	var InitList:Dictionary = {
		"gotoScene": gotoScene,
		"Scenes": Scenes,
		"Components": Components,
		"Resources": Resources,
		"pressToContinue": pressToContinue
	}
	
	(Global.USENODE("TOP") as TOP).RECTMASKTRAN(Callable(Global.USENODE(Tran.name, Tran.package), Tran.enterFunc), [InitList])

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
	DisplayServer.window_set_title("Enlightenment")
	# 注册AutoLoad实例ID
	Global.InstIDList["AutoLoad"] = get_instance_id()
	# 载入包
	var registerItem:Array[String] = []
	if FileAccess.file_exists(UserDataPath + "package.json"):
		# 获取包的激活状态
		enablePack = READJSON(UserDataPath + "package.json")
		for item in enablePack.keys():
			if enablePack[item]:
				registerItem.append(item)
		registerItem.push_front(Global.MainPackage)
	PackageScanner()
	activePack(registerItem)
	
	# 读取设置
	Global.readSetting()
	
	# 设置鼠标
	(Global.USENODE("GUIManager") as GUIManager).setCursor("default", CursorList["default"])
	
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

# 保存包的启动列表
func saveEnablePack():
	(Global.AutoLoad as AutoLoad).WRITEJSON(Global.AutoLoad.UserDataPath + "package.json", enablePack)

# 包扫描器
func PackageScanner() -> void:
	for item in PackagePath:
		var PackageDir:DirAccess = DirAccess.open(item)
		if PackageDir:
			for pack in PackageDir.get_directories():
				var PackDir:DirAccess = DirAccess.open(item + pack)
				if PackDir.file_exists("PackageConfig.json") and PackDir.file_exists("PackageAutoLoad.gd"):
					var PackCig:Dictionary = READJSON(item + pack + "/PackageConfig.json")
					if PackCig.has("name") and PackCig.has("version") and PackCig.has("type") and PackDir.dir_exists("./source"):
						PackCig["address"] = item + pack + "/"
						PackPool[pack] = PackCig
						if not enablePack.has(pack):
							enablePack[pack] = false
					else:
						(Global.USENODE("TOP") as TOP).CONSOLEERROR("Unreconigized package: " + pack + " in " + item, "AutoLoad.PackageScanner()")

# 包挂载器
func PackRegister(PackageName:Array[String]) -> void:
	for package in PackageName:
		if PackPool.keys().has(package):
			if not LoadedPackage.has(package):
				if Global.USENODE("PackageAutoLoad", package).has_method("_Package_ready"):
					Global.USENODE("PackageAutoLoad", package).call("_Package_ready")
				enablePack[package] = true
				if (PackPool[package] as Dictionary).has("start"):
					for item in PackPool[package]["start"]:
						Global.USENODE(item, package)
				LoadedPackage.append(package)
		else:
			enablePack[package] = false
			(Global.USENODE("TOP") as TOP).CONSOLEERROR("Unknown package: " + package, "AutoLoad.PackRegister()")

# 包路径获取
func PackageAddress(packageName:String = Global.DefaultPackage) -> String:
	if PackPool.keys().has(packageName):
		return PackPool[packageName]["address"]
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEERROR("Cannot find " + packageName, "AutoLoad.PackageAddress()")
		return "null"

# 获取包信息
func getPackageCig(packageName:String, key:String):
	if PackPool.has(packageName):
		if (PackPool[packageName] as Dictionary).has(key):
			return PackPool[packageName][key]
		else:
			(Global.USENODE("TOP") as TOP).CONSOLEERROR("Cannot find package Cig key: " + key, "AutoLoad.getPackageCig()")
			return null
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEERROR("Cannot find package: " + packageName, "AutoLoad.getPackageCig()")
		return null

# 引导项设置
func setBeginning(beginning:String, package:String = Global.DefaultPackage) -> void:
	if PackPool.has(package) and (PackPool[package] as Dictionary).has("scenes"):
		for item in PackPool[package]["scenes"]:
			if item.name == beginning:
				Beginning = {
					"package": package,
					"name": beginning
				}

func setTransition(transition:String, package:String = Global.DefaultPackage, enterFunc:String = "TRANSITION") -> void:
	if PackPool.has(package) and (PackPool[package] as Dictionary).has("scenes"):
		for item in PackPool[package]["scenes"]:
			if item.name == transition:
				Tran = {
					"package": package,
					"name": transition,
					"enterFunc": enterFunc
				}

# 启动包
func activePack(packageName:Array[String]) -> void:
	for package in packageName:
		if not LoadedPackage.has(package) and (PackPool as Dictionary).keys().has(package):
			if (PackPool[package] as Dictionary).has("require") and not (PackPool[package]["require"] as Array).is_empty():
				PackRegister(PackPool[package]["require"])
			PackRegister([package])
		if not (PackPool as Dictionary).keys().has(package):
			enablePack[package] = false

# 禁用包
func disablePack(packageName:Array[String]) -> void:
	for package in packageName:
		if LoadedPackage.has(packageName) and PackPool.has(packageName):
			for pack in PackPool:
				if (PackPool[pack] as Dictionary).has("require") and (PackPool[package]["require"] as Array).has(package):
					disablePack([pack])
			if (PackPool[package] as Dictionary).has("components"):
				for item in PackPool[package]["components"]:
					Global.NODEREMOVE(item.name, package)
				LoadedPackage.erase(package)

# 添加翻译表
func addTranslation(translationCSVpath:String, delim:String = ","):
	var result:Dictionary = READCSV(translationCSVpath, delim)

# 读取CSV
func READCSV(path:String, delim:String = ",") -> Dictionary:
	if FileAccess.file_exists(path) and path.get_extension().to_lower() == "csv":
		var CSV:FileAccess = FileAccess.open(path, FileAccess.READ)
		var CSVhead:PackedStringArray = CSV.get_csv_line(delim)
		var result:Dictionary = {}
		for item in CSVhead:
			result[item] = []
		while CSV.get_position() < CSV.get_length():
			var temp:PackedStringArray = CSV.get_csv_line(delim)
			for index in range(CSVhead.size()):
				if index >= temp.size():
					(result[CSVhead[index]] as Array).append(null)
				else:
					(result[CSVhead[index]] as Array).append(temp[index])
		return result
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEERROR("Cannot open csv file: " + path, "AutoLoad.READCSV()")
		return {}
