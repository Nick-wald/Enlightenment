extends Control
class_name GUIModel

func _GUI_init() -> void:
	# 绑定
	if not get_children().is_empty():
		var NodeList:Array = get_children()
		for child in NodeList:
			NodeList.append_array(child.get_children())
			if child is BaseButton:
				if child.has_meta("ButtomType"):
					match child.get_meta("ButtomType"):
						"cancel":
							(Global.USENODE("AudioManager") as AudioManager).bindUISound((child as BaseButton).pressed, "ButtomCancel")
						"apply":
							(Global.USENODE("AudioManager") as AudioManager).bindUISound((child as BaseButton).pressed, "ButtomApply")
						"select":
							(Global.USENODE("AudioManager") as AudioManager).bindUISound((child as BaseButton).mouse_entered, "ButtomOK")
							(Global.USENODE("AudioManager") as AudioManager).bindUISound((child as BaseButton).pressed, "ButtomSelect")
						"page":
							(Global.USENODE("AudioManager") as AudioManager).bindSFXSound((child as BaseButton).pressed, "Paper")
						_:
							(Global.USENODE("AudioManager") as AudioManager).bindUISound((child as BaseButton).pressed, "ButtomClick")
				else:
					(Global.USENODE("AudioManager") as AudioManager).bindUISound((child as BaseButton).pressed, "ButtomClick")

func _ready():
	# GUI模型默认关闭
	if get_parent().name == "GUIManager":
		visible = false

func _process(_delta):
	pass
