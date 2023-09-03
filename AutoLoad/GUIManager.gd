extends Node
class_name GUIManager # GUI和显示效果管理、用户界面

### 常量
## UI绘图层
@onready var UILayer:CanvasLayer = $UILayer
## GUIModel
@onready var GUIModels:GUIModel = $GUIModel
## 对话
# 计时对话默认时长
const ChattingTimeLimiter:float = 5
### 变量
## 显示设置
# 窗口模式
var showmode:String = Global.Setting["config"]["Video"]["Showmode"][0]
# 窗口大小
var windowSize:Vector2i = DisplayServer.screen_get_size()
# 窗口刷新率
var windowReflashRate:int = 60
# 语言
var lang:String = OS.get_locale_language()
# GUI对象池
var GUIHandlers:Array = []
func _ready():
	windowReflashRate = int(DisplayServer.screen_get_refresh_rate())
	if windowReflashRate < 0:
		windowReflashRate = 60
	Engine.max_fps = windowReflashRate
	changeShowmode(Global.Setting["config"]["Video"]["Showmode"][0], Rect2i(0, 0, int((Global.Setting["config"]["Video"]["Size"][0] as String).get_slice("x", 0)), int((Global.Setting["config"]["Video"]["Size"][0] as String).get_slice("x", 1))))

func _process(_delta):
	pass

# 对话框构建器
func DialogBoxCreator(type:String, arg:Array):
	if has_node("./GUIModel/Dialog/" + type):
		GUIModelBuilder("/Dialog/" + type, arg)
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEWARN("Unfound DialogBox " + type, "GUIManager.DialogBoxCreator()")

# 更改显示模式
func changeShowmode(mode:String = "null", size:Rect2i = Rect2i(Vector2i(0, 0), windowSize), title:String = "Enlightenment"):
	showmode = Global.Setting["config"]["Video"]["Showmode"][0]
	if mode.is_empty():
		mode = showmode
	match mode:
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			showmode = mode
		"window_fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			showmode = mode
		"window":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			showmode = mode
		"null":
			pass
		"":
			pass
		_:
			(Global.USENODE("TOP") as TOP).CONSOLEWARN("Unexpected showmode string: " + mode, "GUIManager.changeShowmode()")
	if not size == Rect2i():
		ProjectSettings.set_setting("display/window/size/viewport_width", size.size.x)
		ProjectSettings.set_setting("display/window/size/viewport_height", size.size.y)
		DisplayServer.window_set_size(size.size)
	if not title == "null":
		DisplayServer.window_set_title(title)
	DisplayServer.window_set_position(DisplayServer.get_display_safe_area().size/2)
	DisplayServer.window_request_attention()

# 设置鼠标样式
func setCursor(mode:String = "null", custom_img_path:String = "null"):
	if not custom_img_path == "null":
		match mode:
			"default":
				Input.set_custom_mouse_cursor(load(custom_img_path))
	else:
		match mode:
			"default":
				pass

# GUI注册器
func GUIRegister(node:Node, arg:Array = Array()) -> void:
	if node.has_method("_GUI_init"):
		GUIHandlers.append(node.get_instance_id())
		UILayer.add_child(node)
		if arg.is_empty():
			node.call("_GUI_init")
		else:
			node.callv("_GUI_init", arg)
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEERROR("Cannot find method:_GUI_init() in " + node.name + ".", "GUIManager.GUIRegister()")

#GUI模型调取
func GUIModelBuilder(type:String, arg:Array = Array()):
	var model:Node = get_node("./GUIModel/" + type)
	if not model == null:
		var modelCopy:Control = model.duplicate()
		if not (modelCopy as Control).visible:
			(modelCopy as Control).set_visible(true)
		GUIRegister(modelCopy, arg)
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEERROR("Unknown typename " + type + " in GUIModel.", "GUIManager.GUIModelBuilder()")
