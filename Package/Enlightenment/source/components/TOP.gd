extends Control
class_name TOP

### 常量
## 提示控件
@onready var Tip:RichTextLabel = $MarginContainer/HBoxContainer/Left/TipContainer/Tip
# 右下消息栏
@onready var MessageContainer:VBoxContainer = $MarginContainer/HBoxContainer/Right/MessageContainer
# 左上消息栏
@onready var LeftMessageContainer:VBoxContainer = $MarginContainer/HBoxContainer/Left/TipContainer/LeftMessageContainer
# 调试信息
@onready var DEBUG:VBoxContainer = LeftMessageContainer.get_node("DEBUG")
@onready var StaticMemoryUsage:Label = LeftMessageContainer.get_node("DEBUG/StaticMemoryUsage")
@onready var RenderMemoryUsage:Label = LeftMessageContainer.get_node("DEBUG/RenderMemoryUsage")
@onready var FPS:Label = LeftMessageContainer.get_node("DEBUG/FPS")
@onready var RenderObject:Label = LeftMessageContainer.get_node("DEBUG/RenderObject")
# 屏幕遮罩控件
@onready var RectMask:ColorRect = $RectMask
# 动画播放器控件
@onready var Anim:AnimationPlayer = $AnimationPlayer
# 提示文字持续时间
const TipSec = 3
### 变量
# 内存使用单位
var staticmemoryusage:int = 1
var staticmemoryusagesuffix:String = "Bytes"

# GUI标志
func _GUI_init():
	pass

func _ready():
	switchDEBUGmsg()

func _process(_delta):
	if DEBUG.visible:
		StaticMemoryUsage.text = "内存使用（cur/max）: %.3f %s / %.3f %s" % [Performance.get_monitor(Performance.MEMORY_STATIC) / float(staticmemoryusage), staticmemoryusagesuffix, Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / float(staticmemoryusage) , staticmemoryusagesuffix]
		RenderMemoryUsage.text = "显存使用: %.3f %s" % [Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / float(staticmemoryusage), staticmemoryusagesuffix]
		FPS.text = "FPS（cur/max）: %d / %d" % [Performance.get_monitor(Performance.TIME_FPS), Engine.max_fps]
		RenderObject.text = "%d 个对象, %d / %d 个节点(tol/orp), %d 个资源" % [Performance.get_monitor(Performance.OBJECT_COUNT), Performance.get_monitor(Performance.OBJECT_NODE_COUNT), Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT), Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)]

# 消息栏警告信息
func CONSOLEWARN(text:String, username:String = "") -> void:
	CONSOLE("[color=#FAFAD2]" + text + "[/color]", "[color=yellow][Warning][/color] " + username)

# 消息栏错误信息
func CONSOLEERROR(text:String, username:String = "") -> void:
	CONSOLE("[color=#FA8072]" + text + "[/color]", "[color=red][Error][/color] " + username)

# 消息栏信息
func CONSOLE(text:String, username = null) -> void:
	var msg:RichTextLabel = RichTextLabel.new()
	msg.set_use_bbcode(true)
	msg.set_fit_content(true)
	msg.set_autowrap_mode(TextServer.AUTOWRAP_OFF)
	if username:
		msg.set_text("%s: %s" % [username, text])
	else:
		msg.set_text(text)
	MessageContainer.add_child(msg)
	TIMETODELETE(msg, TipSec)

# 提示
func TIP(text:String) -> void:
	Tip.set_use_bbcode(true)
	Tip.set_fit_content(true)
	Tip.set_autowrap_mode(TextServer.AUTOWRAP_OFF)
	Tip.set_text(text)
	await get_tree().create_timer(TipSec).timeout
	Tip.clear()

# 节点定时自毁
func TIMETODELETE(node:Node, sec = 3) -> void:
	await get_tree().create_timer(float(sec)).timeout
	node.queue_free()

# 屏幕遮罩进入
func RECTMASKTRAN(function:Callable, arg:Array = []) -> void:
	Anim.play("TOPMaskTranIn")
	await Anim.animation_finished
	Anim.play("TOPMaskTranOut")
	function.callv(arg)

func switchDEBUGmsg() -> void:
	DEBUG.visible = (Global.AutoLoad as AutoLoad).DEBUG
	staticmemoryusageChangesuffix()

# 内存单位处理
func staticmemoryusageChangesuffix():
	while (Global.AutoLoad as AutoLoad).DEBUG:
		await get_tree().create_timer(3).timeout
		match staticmemoryusage:
			1:
				staticmemoryusage = 8
				staticmemoryusagesuffix = "Bits"
			8:
				staticmemoryusage = staticmemoryusage*1024
				staticmemoryusagesuffix = "KBs"
			8*1024:
				staticmemoryusage = staticmemoryusage*1024
				staticmemoryusagesuffix = "MBs"
			8*1024*1024:
				staticmemoryusage = staticmemoryusage*1024
				staticmemoryusagesuffix = "GBs"
			8*1024*1024*1024:
				staticmemoryusage = 1
				staticmemoryusagesuffix = "Bytes"
