extends GUIModel

func _ready():
	pass

func _process(_delta):
	pass

# 退出按钮
func _on_quit_pressed() -> void:
	Global.AutoLoad.QUITGAME()

# 开始按钮
func _on_begin_pressed() -> void:
	Global.AutoLoad.TRANSITION("Beginning", [], true)

# 设置按钮
func _on_setting_pressed() -> void:
	(Global.USENODE("GUIManager") as GUIManager).GUIModelBuilder("Setting")

# DLC按钮
func _on_dlc_pressed() -> void:
	(Global.USENODE("GUIManager") as GUIManager).GUIModelBuilder("DLC")

# 继续按钮
func _on_continue_pressed() -> void:
	pass # Replace with function body.
