extends GUIModel
### 常量
# 控件
@onready var Anim:AnimationPlayer = $AnimationPlayer
@onready var Title:Label = $MarginContainer/MarginContainer/VBoxContainer/StartGameMenuTitle/Title
@onready var Description:Label = $MarginContainer/MarginContainer/VBoxContainer/StartGameMenu/MarginContainer/VBoxContainer/Description
@onready var StartGameMenuBox:MarginContainer = $MarginContainer/MarginContainer
### 变量
# 开始游戏菜单展开
var startGameMenu:bool = false:
	set(val):
		startGameMenu = val
		if val:
			StartGameMenuBox.visible = true
		else:
			await Anim.animation_finished
			StartGameMenuBox.visible = val

func _ready():
	pass

func _process(_delta):
	pass

# 退出按钮
func _on_quit_pressed() -> void:
	await (Global.USENODE("AudioManager") as AudioManager).UIPlayer.finished
	(Global.AutoLoad as AutoLoad).QUITGAME()

# 开始按钮
func _on_begin_pressed() -> void:
	if not startGameMenu and not Anim.is_playing():
		Anim.play("StartGame")
		startGameMenu = true
	elif not Anim.is_playing():
		Anim.play("StartGame_exit")
		startGameMenu = false

# 设置按钮
func _on_setting_pressed() -> void:
	(Global.USENODE("GUIManager") as GUIManager).GUIModelBuilder("Setting")

# DLC按钮
func _on_dlc_pressed() -> void:
	(Global.USENODE("GUIManager") as GUIManager).GUIModelBuilder("DLC")

# 继续按钮
func _on_continue_pressed() -> void:
	pass # Replace with function body.

# 鼠标移入继续按钮 - 显示详情
func _on_continue_mouse_entered():
	pass # Replace with function body.

# 退出开始游戏菜单
func _on_back_pressed():
	if startGameMenu and not Anim.is_playing():
		Anim.play("StartGame_exit")
		startGameMenu = false


func _on_story_box_mouse_entered():
	Description.text = "轻松、简单的游戏体验，注重探索和剧情"


func _on_balance_box_mouse_entered():
	Description.text = "剧情和策略的平衡，第一次游玩推荐"


func _on_strategy_box_mouse_entered():
	Description.text = "更聪明的敌人，更艰苦的战斗"


func _on_h_box_container_mouse_exited():
	Description.text = " "

func _on_story_pressed():
	Title.text = "已选择：剧情模式"
	(Global.USENODE("GameManager") as GameManager).setGameMode((Global.USENODE("GameManager") as GameManager).GAMEMODE.Story)


func _on_balance_pressed():
	Title.text = "已选择：平衡模式"
	(Global.USENODE("GameManager") as GameManager).setGameMode((Global.USENODE("GameManager") as GameManager).GAMEMODE.Balance)


func _on_strategy_pressed():
	Title.text = "已选择：策略模式"
	(Global.USENODE("GameManager") as GameManager).setGameMode((Global.USENODE("GameManager") as GameManager).GAMEMODE.Strategy)
