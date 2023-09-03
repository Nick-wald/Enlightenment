extends EntityCharacter
class_name CharacterBasic # 人物基本模型

### 角色卡 Character Sheet
# 种族
var Race:Dictionary = {
	"race": "null", # 主种族
	"subrace": "null" # 亚种
}
# 职业
var Class
# 等级
var Level:int = 1
# 修正值
var Modifiers:Dictionary = {
	"Level": 0 # 来自等级的修正值
}
# 经验
var XP:int = 0:
	set(new_value):
		XP = new_value
		var LvAndMd = (Global.USENODE("CharacterManager") as CharacterManager).XPtoLvAndMd(XP)
		Level = LvAndMd[0]
		Modifiers["Level"] = LvAndMd[1]
# 体型（单位：尺）
var Size:int
# 年龄
var Age:int
# 速度
var Speed:int
# 属性
var Ability:Dictionary = {
	"Strength": 1, # 力量
	"Dexterity": 1, # 敏捷
	"Constitution": 1, # 体质
	"Intelligent": 1, # 智力
	"Wisdom": 1, # 感知
	"Charisma": 1 # 魅力
}

func _ready():
	super()

func _process(delta):
	pass

# 角色创建器
func CharacterBuilder():
	pass
