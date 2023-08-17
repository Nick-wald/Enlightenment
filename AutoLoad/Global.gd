extends Node
# 全局变量、函数

### 全局常量
const DefaultSceneLayer:int = 0
### 全局变量
# 实例ID表（系统 + 场景）
var InstIDList:Dictionary
# 设置
var Setting:Dictionary
var TransitionTip:Dictionary
# AutoLoad
@onready var AutoLoad:AutoLoad = get_node("/root/AutoLoad")
# 当前场景
var current_scene:String = "null" 
var SceneStack:Array = []
# 禁止暂停列表
var UnpausableScenesList:Array = []

func _ready():
	pass

func _process(_delta):
	pass

# 使用节点
func USENODE(nodename:String) -> Object:
	if InstIDList.has(nodename):
		if is_instance_id_valid(InstIDList[nodename]):
			return instance_from_id(InstIDList[nodename])
		else:
			InstIDList.erase(nodename)
			return USENODE(nodename)
	else:
		for scene in AutoLoad.ScenesList["scenes"]:
			if scene.name == nodename:
				if not scene.has("layer"):
					scene["layer"] = DefaultSceneLayer
				if scene.has("child"):
					AutoLoad.NODELOAD(AutoLoad.ScenesPath, scene.name, get_node("/root/AutoLoad"), scene.layer, scene.child)
				else:
					AutoLoad.NODELOAD(AutoLoad.ScenesPath, scene.name, get_node("/root/AutoLoad"), scene.layer)
				return instance_from_id(InstIDList[nodename])
		
		for system in AutoLoad.SystemsList["systems"]:
			if system.name == nodename:
				if not system.has("layer"):
					system["layer"] = DefaultSceneLayer
				if system.has("child"):
					AutoLoad.NODELOAD(AutoLoad.SystemsPath, system.name, get_node("/root/AutoLoad"), system.layer, system.child)
				else:
					AutoLoad.NODELOAD(AutoLoad.SystemsPath, system.name, get_node("/root/AutoLoad"), system.layer)
				return instance_from_id(InstIDList[nodename])
		instance_from_id(InstIDList["TOP"]).CONSOLEERROR(nodename + " cannot be founded.", "Global.USENODE()")
		return null
