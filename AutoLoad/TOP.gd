extends Control
class_name TOP

### 常量
# 提示控件
@onready var Tip:RichTextLabel = $MarginContainer/TipContainer/Tip
# 右下消息栏
@onready var MessageContainer:VBoxContainer = $MarginContainer/MessageContainer
# 左上消息栏
@onready var LeftMessageContainer:VBoxContainer = $MarginContainer/TipContainer/LeftMessageContainer
# 屏幕遮罩控件
@onready var RectMask:ColorRect = $RectMask
# 动画播放器控件
@onready var Anim:AnimationPlayer = $AnimationPlayer
# 提示文字持续时间
const TipSec = 3

# GUI标志
func _GUI_init():
	pass

func _ready():
	pass

func _process(_delta):
	pass

# 消息栏警告信息
func CONSOLEWARN(text:String, username:String = "") -> void:
	CONSOLE("[color=yellow]" + text + "[/color]", "[color=yellow][Warning][/color] " + username)

# 消息栏错误信息
func CONSOLEERROR(text:String, username:String = "") -> void:
	CONSOLE("[color=red]" + text + "[/color]", "[color=red][Error][/color] " + username)

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
