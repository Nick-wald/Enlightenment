extends Node
class_name CharacterManager

### 常量
# 角色模型（Tag）
@onready var CharacterModel = $CharacterModel
# 角色外观
@onready var CharacterAppear = $CharacterAppear
# 属性值与调整值
const Modifiers:Dictionary = {
	"1-1": -5,
	"2-3": -4,
	"4-5": -3,
	"6-7": -2,
	"8-9": -1,
	"10-11": 0,
	"12-13": 1,
	"14-15": 2,
	"16-17": 3,
	"18-19": 4,
	"20-21": 5,
	"22-23": 6,
	"24-25": 7,
	"26-27": 8,
	"28-29": 9,
	"30-30": 10
}
# 经验值到等级和修正值
const XPtoLevelAndModifiers:Dictionary = {
	"0-299": [1, 2],
	"300-899": [2, 2],
	"900-2_699": [3, 2],
	"2_700-6_499": [4, 2],
	"6_500-13_999": [5, 3],
	"14_000-22_999": [6, 3],
	"23_000-33_999": [7, 3],
	"34_000-47_999": [8, 3],
	"48_000-63_999": [9, 4],
	"64_000-84_999": [10, 4],
	"85_000-99_999": [11, 4],
	"100_000-119_999": [12, 4],
	"120_000-139_999": [13, 5],
	"140_000-164_999": [14, 5]
}
# 随机人物数据库
var RandomCharacterDatabase = (Global.AutoLoad as AutoLoad).READJSON(Global.AutoLoad.SystemsPath + "RandomCharacter.json")
### 变量
# 玩家队伍
var Party:Array = []

func _ready():
	pass

func _process(_delta):
	pass

# 玩家队伍管理
func addToParty(Character:CharacterBasic) -> void:
	Party.append(Character)
func removeFromParty(Character:CharacterBasic) -> void:
	if Party.has(Character):
		Party.remove_at(Party.find(Character))

# 调整值计算
func Modifier(AbilityScore:int) -> int:
	AbilityScore = clampi(AbilityScore, 1, 30)
	for i in Modifiers.keys():
		if AbilityScore in range( int((i as String).get_slice("-",0)) , int((i as String).get_slice("-",1)) + 1 ):
			return Modifiers[i]
	return -999

# 等级到经验值和修正值转换（数组：等级、熟练修正值）
func XPtoLvAndMd(XP:int) -> Array[int]:
	XP = clampi(XP, 1, 355_000)
	for i in XPtoLevelAndModifiers.keys():
		if XP in range( int((i as String).get_slice("-",0)) , int((i as String).get_slice("-",1)) + 1 ):
			return XPtoLevelAndModifiers[i]
	return [-999,-999]

# 随机姓名生成器
func RandomNameBuilder() -> String:
	return "null"
