extends GUIModel
# 设置GUI界面处理

### 常量
# 设置Tab
@onready var ConfigTab:HBoxContainer = self.get_node("SettingBox/TextureRect/MarginContainer/VBoxContainer/Tabs")
# 设置显示区
@onready var Config:VBoxContainer = self.get_node("SettingBox/TextureRect/MarginContainer/VBoxContainer/ConfigContainer/Configs")
# 解释区
@onready var Description:Label = self.get_node("SettingBox/TextureRect/MarginContainer/VBoxContainer/Description")
# 应用按钮
@onready var Apply:Button = self.get_node("SettingBox/TextureRect/MarginContainer/VBoxContainer/Buttoms/Apply")
### 变量
# 设置副本
var SettingCopy:Dictionary

func _GUI_init():
	# 创建副本
	SettingCopy = Global.Setting.duplicate(true)
	for tab in (SettingCopy["config"] as Dictionary).keys():
		var SettingTab:Button = Button.new()
		SettingTab.set_text(tab)
		SettingTab.set_meta("ConfigTab", tab)
		SettingTab.set_meta("ButtomType", "page")
		SettingTab.pressed.connect(updateConfigArea.bind(tab))
		ConfigTab.add_child(SettingTab)
	updateConfigArea(ConfigTab.get_child(0).get_meta("ConfigTab"))
	super()

func _on_apply_pressed() -> void:
	Global.Setting = SettingCopy
	(Global.AutoLoad as AutoLoad).WRITEINI()
	queue_free()

func _on_cancel_pressed() -> void:
	(Global.USENODE("GUIManager") as GUIManager).changeShowmode(
		Global.Setting["config"]["Video"]["Showmode"][0],
		Rect2i(
			0,
			0,
			int((Global.Setting["config"]["Video"]["Size"][0] as String).get_slice("x", 0)),
			int((Global.Setting["config"]["Video"]["Size"][0] as String).get_slice("x", 1))
		)
		)
	for item in (Global.Setting["config"]["Audio"] as Dictionary).keys():
		(Global.USENODE("AudioManager") as AudioManager).set_vol(item, Global.Setting["config"]["Audio"][item])
	queue_free()

# 更新设置区内容
func updateConfigArea(tab:String) -> void:
	if not Config.get_children().is_empty():
		for item in Config.get_children():
			item.queue_free()
	if (SettingCopy["config"] as Dictionary).has(tab):
		for item in (SettingCopy["config"][tab] as Dictionary).keys():
			var configGroup = HBoxContainer.new()
			var configText = Label.new()
			configText.set_text(item)
			configText.set_custom_minimum_size(Vector2(300, 0))
			configGroup.add_child(configText)
			match typeof(SettingCopy["config"][tab][item]):
				TYPE_BOOL:
					var i:CheckButton = CheckButton.new()
					i.button_pressed = SettingCopy["config"][tab][item]
					configGroup.add_child(i)
					Config.add_child(configGroup)
				TYPE_ARRAY:
					var i = OptionButton.new()
					var index = 1
					while index < (SettingCopy["config"][tab][item] as Array).size():
						i.add_item(str(SettingCopy["config"][tab][item][index]), index - 1)
						if SettingCopy["config"][tab][item][index] == SettingCopy["config"][tab][item][0]:
							i.select(index - 1)
						index += 1
					i.set_meta("tab", tab)
					i.set_meta("item", item)
					i.item_selected.connect(updateSetting.bind(tab, item, i).unbind(1))
					configGroup.add_child(i)
					Config.add_child(configGroup)
				TYPE_STRING:
					var i = LineEdit.new()
					i.set_custom_minimum_size(Vector2(300, 0))
					i.text = SettingCopy["config"][tab][item]
					configGroup.add_child(i)
					Config.add_child(configGroup)
				TYPE_INT:
					continue
				TYPE_FLOAT:
					var i:HSlider = HSlider.new()
					i.set_custom_minimum_size(Vector2(300, 0))
					i.max_value = 1
					i.step = 0.01
					i.value = SettingCopy["config"][tab][item]
					i.set_meta("tab", tab)
					i.set_meta("item", item)
					i.value_changed.connect(updateSetting.bind(tab, item, i).unbind(1))
					configGroup.add_child(i)
					Config.add_child(configGroup)

# 更新设置&预览
func updateSetting(tab:String, item:String, value) -> void:
	if (Global.AutoLoad as AutoLoad).DEBUG:
		(Global.USENODE("TOP") as TOP).CONSOLE(str(tab) + " " + str(item) + " " + str(value))
	match typeof(SettingCopy["config"][tab][item]):
		TYPE_BOOL:
			SettingCopy["config"][tab][item] = value
		TYPE_ARRAY:
			SettingCopy["config"][tab][item][0] = (value as OptionButton).get_item_text((value as OptionButton).selected)
			if (tab == "Video" and item == "Showmode") or (tab == "Video" and item == "Size"):
				(Global.USENODE("GUIManager") as GUIManager).changeShowmode(SettingCopy["config"]["Video"]["Showmode"][0], Rect2i(0, 0, int((SettingCopy["config"]["Video"]["Size"][0] as String).get_slice("x", 0)), int((SettingCopy["config"]["Video"]["Size"][0] as String).get_slice("x", 1))))
		TYPE_STRING:
			SettingCopy["config"][tab][item] = value
		TYPE_INT:
			SettingCopy["config"][tab][item] = (value as HSlider).value
			if tab == "Audio":
				(Global.USENODE("AudioManager") as AudioManager).set_vol(item, (value as HSlider).value)
		TYPE_FLOAT:
			SettingCopy["config"][tab][item] = (value as HSlider).value
			if tab == "Audio":
				(Global.USENODE("AudioManager") as AudioManager).set_vol(item, (value as HSlider).value)
