extends EntityModel
class_name EntityCharacter # 角色基本实体

### 变量
# 物理护甲Armor
var ARM:int = 0
# 魔法护甲Magic Resistance
var MR:int = 0
# 装备
var equipments:Dictionary = {}

func _ready():
	super()
	tagAdd("Character")

func _process(_delta):
	pass

# 人物生成
func spriteGenerator():
	pass
	
