extends Node
class_name GameManager

### 常量
# 主相机
@onready var Camera:Camera2D = $Node2D/SceneCamera
### 变量
# 游戏模式
enum GAMEMODE {Story, Balance, Strategy}
var gamemode:GAMEMODE = GAMEMODE.Balance
# 包路径
var PackagePath:Array[String] = ["res://Package/", "user://Package/"]
# 包池
var PackPool:Dictionary = {}
var LoadedPackage:Array[String] = []
var enablePack:Dictionary = {}

func _ready():
	# 载入包
	PackageScanner()
	if FileAccess.file_exists(Global.AutoLoad.UserDataPath + "package.json"):
		enablePack = (Global.AutoLoad as AutoLoad).READJSON(Global.AutoLoad.UserDataPath + "package.json")
		var registerItem:Array[String] = []
		for item in enablePack.keys():
			if enablePack[item]:
				registerItem.append(item)
		PackRegister(registerItem)

func _process(_delta):
	pass

# 保存包的启动列表
func saveEnablePack():
	(Global.AutoLoad as AutoLoad).WRITEJSON(Global.AutoLoad.UserDataPath + "package.json", enablePack)

# 包扫描器
func PackageScanner():
	var registerItem:Array[String] = []
	for item in PackagePath:
		var PackageDir:DirAccess = DirAccess.open(item)
		if PackageDir:
			print(PackageDir.get_directories())
			for pack in PackageDir.get_directories():
				var PackDir:DirAccess = DirAccess.open(item + pack)
				if PackDir.file_exists("PackageConfig.json"):
					var PackCig:Dictionary = (Global.AutoLoad as AutoLoad).READJSON(item + pack + "/PackageConfig.json")
					if PackCig.has("name") and PackCig.has("version") and PackCig.has("type") and PackDir.dir_exists("source"):
						PackPool[pack] = PackCig
						if PackCig["type"] == "main":
							registerItem.append(pack)
					else:
						(Global.USENODE("TOP") as TOP).CONSOLEERROR("Unreconigized package: " + pack + " in " + item, "GameManager.PackageScanner()")
	PackRegister(registerItem)

# 包挂载器
func PackRegister(PackageName:Array[String]):
	if PackPool.has_all(PackageName):
		for item in PackageName:
			match PackPool[item]["type"]:
				"main":
					enablePack[item] = true
					if not LoadedPackage.has(item):
						LoadedPackage.append(item)
	else:
		for item in PackageName:
			if not PackPool.has(item):
				enablePack[item] = false
				(Global.USENODE("TOP") as TOP).CONSOLEERROR("Unknown package: " + item, "GameManager.PackRegister()")
			

# 更改游戏模式
func setGameMode(mode:GAMEMODE = GAMEMODE.Balance):
	gamemode = mode

# 投掷骰子
func Dice(ndn:String = "1d20"):
	var times:int = int(ndn.get_slice("d", 0))
	var dice:int = int(ndn.get_slice("d", 1))
	var result:int = 0
	while times:
		times -= 1
		randomize()
		match dice:
			100:
				var ans = Dice("1d10")*10 + Dice("1d10")
				if ans:
					result += 100
				else:
					result += ans
			10:
				result += randi_range(0, 9)
			_:
				result += randi_range(1, dice)
	return result

# 相机聚焦
func CameraFocus():
	pass
