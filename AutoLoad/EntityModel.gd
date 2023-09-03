extends Node
class_name EntityModel # 实体基本模型

### 变量
# 名称
var Name:String = ""
# 生命值
var Health:int = 0
# tag池
var tag:Dictionary = {}
# 阵营
var Team:Array = []
# 贴图
var sprites:Dictionary = {}

func _ready():
	tagAdd(["Entity"])

func _process(_delta):
	pass

# tag添加
func tagAdd(key:Array[String], section:String = "System") -> void:
	if not tag.has(section):
		tag[section] = Array()
		(tag[section] as Array).append_array(key)
	else:
		for item in key:
			if not (tag[section] as Array).has(item):
				(tag[section] as Array).append(item)

# tag移除
func tagRemove(key:Array[String], section:String = "System") -> Array[String]:
	var result:Array[String] = []
	if tag.has(section):
		for item in key:
			(tag[section] as Array).erase(item)
			result.append(item)
	return result

# tag检测
func has_tag(key:Array[String], section:String = "System") -> bool:
	if not tag.has(section):
		return false
	else:
		for item in key:
			if not (tag[section] as Array).has(item):
				return false
	return true
