extends Node
class_name EntityModel # 实体基本模型

### 变量
# 名称
var Name:String = ""
# 生命值
var Health:int = 0
# 物理护甲Armor
var ARM:int = 0
# 魔法护甲Magic Resistance
var MR:int = 0
# tag池
var tag:Dictionary = {}
# 阵营
var Team:Array = []

func _ready():
	pass

func _process(_delta):
	pass

# 2D模型获取
func model2D():
	pass
# 3D模型获取
func model3D():
	pass

# tag添加
func tagAdd(section:String, key:String):
	if not tag.has(section):
		tag[section] = Array()
		(tag[section] as Array).append(key)
	elif not (tag[section] as Array).has(key):
		(tag[section] as Array).append(key)

# tag移除
func tagRemove(section:String, key:String):
	if tag.has(section):
		(tag[section] as Array).erase(key)
