extends Node
# 全局变量、函数

### 全局常量
const DefaultSceneLayer:int = 0
### 全局变量
# 默认包
var DefaultPackage:String = "Enlightenment"
# 默认启动包
var MainPackage:String = DefaultPackage
# 过渡界面提示
var TransitionTip:Dictionary = {
	"Tips": []
}
# 实例ID表（系统 + 场景）
var InstIDList:Dictionary = {}
# 设置
var Setting:Dictionary = {
	"config": {}
}
# 音频总线索引
var busindex:int = 1
# 音频文件汇总
var AudioList:Dictionary = {}
# AutoLoad
@onready var AutoLoad:AutoLoad = get_node("/root/AutoLoad")
# 当前场景
signal currentSceneChange
var current_scene:Dictionary = {
	"package": "",
	"name": ""
}:
	set(value):
		current_scene = value
		emit_signal("currentSceneChange", value)

var SceneStack:Array = []

func _ready():
	pass

func _process(_delta):
	pass

# 添加过渡界面提示
func addTransitionTips(TipsList:Dictionary) -> void:
	(TransitionTip["Tips"] as Array).append_array(TipsList["Tips"])

# 添加设置项
func addSetting(SettingList:Dictionary, package:String = DefaultPackage) -> void:
	if not (Setting["config"] as Dictionary).has(package):
		Setting["config"][package] = Dictionary()
	Setting["config"][package] = SettingList["config"]
# 修改设置项
func setSetting(tab:String, key:String, val, package:String = DefaultPackage) -> void:
		Setting["config"][package][tab][key] = val
# 获取设置项
func getSetting(tab:String = "", key:String = "", package:String = DefaultPackage):
	if (Setting["config"] as Dictionary).has(package):
		if tab.is_empty():
			return Setting["config"][package]
		if (Setting["config"][package] as Dictionary).has(tab):
			if key.is_empty():
				return Setting["config"][package][tab]
			if (Setting["config"][package][tab] as Dictionary).has(key):
				return Setting["config"][package][tab][key]
			else:
				(USENODE("TOP") as TOP).CONSOLEWARN("Cannot find key in Setting/" + package + "/" + tab, "Global.getSetting()")
				return "null"
		else:
			(USENODE("TOP") as TOP).CONSOLEWARN("Cannot find tab in Setting/" + package, "Global.getSetting()")
			return "null"
	else:
		(USENODE("TOP") as TOP).CONSOLEWARN("Cannot find package in Setting", "Global.getSetting()")
		return "null"

# 添加音频索引表
func addAudioList(list:Dictionary, package:String = DefaultPackage) -> void:
	for item in list.keys():
		if not item == "version":
			for audio in (list[item] as Dictionary).keys():
				audioRegister(item, audio, list[item][audio], package)

# 音频资源注册
func audioRegister(audioType:String, audioName:String, val, package:String = DefaultPackage) -> void:
	if not AudioList.has(audioType):
		AudioList[audioType] = Dictionary()
		if not audioType == "Master":
			# 添加音频总线
			AudioServer.add_bus(busindex)
			AudioServer.set_bus_name(busindex, audioType)
			set_vol(audioType, getSetting("Audio", audioType, package))
			busindex += 1
	if not (AudioList[audioType] as Dictionary).has(package):
		AudioList[audioType][package] = Dictionary()
	(AudioList[audioType][package] as Dictionary)[audioName] = val

# 音频资源获取
func audioGet(audioType:String, audioName:String, package:String = DefaultPackage):
	var packAddress:String = AutoLoad.PackageAddress(package)
	if AudioList.has(audioType):
		if (AudioList[audioType] as Dictionary).has(package):
			if (AudioList[audioType][package] as Dictionary).has(audioName):
				var result = AudioList[audioType][package][audioName]
				match typeof(result):
					TYPE_STRING:
						return packAddress + result
					TYPE_ARRAY:
						result[0] = packAddress + result[0]
						return result
			else:
				(USENODE("TOP") as TOP).CONSOLEWARN("Cannot find audioName: " + audioName +" in AudioList/" + audioType + "/" + package, "Global.audioGet()")
				return "null"
		else:
			(USENODE("TOP") as TOP).CONSOLEWARN("Cannot find package in AudioList/" + audioType, "Global.audioGet()")
			return "null"
	else:
		(USENODE("TOP") as TOP).CONSOLEWARN("Cannot find audioType in AudioList/" + audioType, "Global.audioGet()")
		return "null"

# player挂载器
func playerRegister(audioType:String, player, target:Node = self) -> void:
	if not AudioServer.get_bus_index(audioType) < 0:
		if typeof(player) == TYPE_STRING:
			player = AudioStreamPlayer.new()
			player.set_name(audioType + "Player")
		player.set_bus(audioType)
		
		if not target.has_node("PlayerList"):
				var PlayerListNode:Node = Node.new()
				PlayerListNode.set_name("PlayerList")
				target.add_child(PlayerListNode)
		if not audioType == "Master":
			if not target.has_node("PlayerList/" + audioType + "_GROUP") == null:
				var GroupNode:Node = Node.new()
				GroupNode.set_name(audioType + "_GROUP")
				target.get_node("PlayerList").add_child(GroupNode)
			target.get_node("PlayerList/" + audioType + "_GROUP").add_child(player)
		else:
			target.get_node("PlayerList").add_child(player)
	else:
		(USENODE("TOP") as TOP).CONSOLEWARN("Cannot find bus " + audioType, "Global.playerRegister()")

# 获取player
func getPlayer(audioType:String, playerName:String, target:Node = self):
	if not AudioServer.get_bus_index(audioType) < 0:
		if not audioType == "Master":
			if target.has_node("PlayerList/" + audioType + "_GROUP/" + playerName):
				return target.get_node("PlayerList/" + audioType + "_GROUP/" + playerName)
			else:
				playerRegister(audioType, audioType, target)
				return getPlayer(audioType, audioType + "Player")
		else:
			if target.has_node("PlayerList/" + playerName):
				return target.get_node("PlayerList/" + playerName)
			else:
				playerRegister(audioType, audioType, target)
				return getPlayer(audioType, audioType + "Player")
	else:
		(USENODE("TOP") as TOP).CONSOLEWARN("Cannot find bus " + audioType, "Global.getPlayer()")

# 使用节点
func USENODE(nodename:String, package:String = DefaultPackage, target:Node = self.AutoLoad) -> Object:
	if InstIDList.has(package + "/" + nodename):
		if is_instance_id_valid(InstIDList[package + "/" + nodename]):
			return instance_from_id(InstIDList[package + "/" + nodename])
		else:
			InstIDList.erase(package + "/" + nodename)
			return USENODE(nodename, package)
	else:
		if self.AutoLoad.PackPool.keys().has(package):
			var node:Dictionary = {
							"package": package,
							"name": nodename,
							"layer": DefaultSceneLayer
						}
			if (self.AutoLoad.PackPool[package] as Dictionary).has("scenes"):
				for scene in self.AutoLoad.PackPool[package]["scenes"]:
					if scene.name == nodename:
						if scene.has("layer"):
							node["layer"] = scene["layer"]
						node["type"] = "scene"
						self.AutoLoad.NODELOAD(node, target)
						return instance_from_id(InstIDList[package + "/" + nodename])
			if (self.AutoLoad.PackPool[package] as Dictionary).has("components"):
				for component in self.AutoLoad.PackPool[package]["components"]:
					if component.name == nodename:
						if component.has("layer"):
							node["layer"] = component["layer"]
						if component.has("child"):
							node["child"] = component["child"]
						node["type"] = "component"
						self.AutoLoad.NODELOAD(node, target)
						return instance_from_id(InstIDList[package + "/" + nodename])
			if nodename == "PackageAutoLoad":
				node["type"] = "PackageAutoLoad"
				self.AutoLoad.NODELOAD(node, target)
				return instance_from_id(InstIDList[package + "/" + nodename])
		(USENODE("TOP") as TOP).CONSOLEERROR(package + "/" + nodename + " cannot be founded.", "Global.USENODE()")
		return null

# 节点销毁
func NODEREMOVE(nodename:String, package:String = DefaultPackage) -> void:
	if nodename != "null" and Global.InstIDList.has(package + "/" + nodename):
		var inst:Object = instance_from_id(Global.InstIDList[package + "/" + nodename])
		if inst.has_method("queue_free"):
			inst.call("queue_free")
		else:
			inst.free()
		Global.InstIDList.erase(package + "/" + nodename)

# 设置默认包
func setDefaultPackage(package:String) -> void:
	if (AutoLoad.PackPool as Dictionary).has(package):
		DefaultPackage = package
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEWARN("Cannot find package" + package, "Global.setDefaultPackage()")

# 设置音量
func set_vol(audioType:String, vol:float = 0.5) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audioType), linear_to_db(clamp(vol, 0, 1)))

# 设置当前场景
func setCurrentScene(nodename:String, package:String = DefaultPackage):
	if AutoLoad.PackPool.has(package) and (AutoLoad.PackPool[package] as Dictionary).has("scenes"):
		for scene in AutoLoad.PackPool[package]["scenes"]:
			if nodename == scene.name:
				current_scene = {
					"package": package,
					"name": nodename
				}
				return
	(USENODE("TOP") as TOP).CONSOLEERROR("Cannot find scene: " + package + "/" + nodename, "Global.setCurrentScene()")

# 保存设置
func saveSetting(path:String = AutoLoad.UserDataPath + "Setting.json"):
	AutoLoad.WRITEJSON(path, Setting)
	
# 读取设置
func readSetting(path:String = AutoLoad.UserDataPath + "Setting.json"):
	if FileAccess.file_exists(path):
		Setting = AutoLoad.READJSON(path)
