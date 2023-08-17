extends Node
class_name GameManager

### 常量
# 主相机
@onready var Camera:Camera2D = $Node2D/SceneCamera

func _ready():
	pass

func _process(delta):
	pass

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