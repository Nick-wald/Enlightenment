extends GUIModel

func _ready():
	pass

func _process(_delta):
	pass

# 取消
func _on_cancel_pressed():
	queue_free()

# 确认
func _on_apply_pressed():
	queue_free()
