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
var SettingPool:Dictionary
var Setting:Dictionary = Global.Setting.duplicate(true)

func _GUI_init():
	Description.text = " "
	# 构造设置选项池
	for package in (Global.Setting["config"] as Dictionary).keys():
		for tab in (Global.Setting["config"][package] as Dictionary).keys():
			# 初始化构造
			if not SettingPool.has(tab):
				SettingPool[tab] = Dictionary()
			if not (SettingPool[tab] as Dictionary).has(package):
				SettingPool[tab][package] = Dictionary()
			for key in (Global.Setting["config"][package][tab] as Dictionary).keys():
				SettingPool[tab][package][key] = Global.Setting["config"][package][tab][key]
			
			var SettingTab:Button = Button.new()
			SettingTab.set_text(tab)
			SettingTab.set_meta("ConfigTab", tab)
			SettingTab.set_meta("ButtomType", "page")
			SettingTab.pressed.connect(updateConfigArea.bind(tab))
			ConfigTab.add_child(SettingTab)
	updateConfigArea(ConfigTab.get_child(0).get_meta("ConfigTab"))
	super()

func _on_apply_pressed() -> void:
	for tab in SettingPool.keys():
		for package in (SettingPool[tab] as Dictionary).keys():
			for key in (SettingPool[tab][package] as Dictionary).keys():
				Global.setSetting(tab, key, SettingPool[tab][package][key], package)
	Global.saveSetting()
	queue_free()

func _on_cancel_pressed() -> void:
	Global.Setting = Setting
	(Global.USENODE("GUIManager") as GUIManager).changeShowmode(Global.getSetting("Video", "Showmode")[0], Rect2i(0, 0, int((Global.getSetting("Video", "Size")[0] as String).get_slice("x", 0)), int((Global.getSetting("Video", "Size")[0] as String).get_slice("x", 1))))
	
	for package in (SettingPool["Audio"] as Dictionary).keys():
		for key in (SettingPool["Audio"][package] as Dictionary).keys():
			Global.set_vol(key, Global.getSetting("Audio", key, package))
	
	queue_free()

# 更新设置区内容
func updateConfigArea(tab:String) -> void:
	if not Config.get_children().is_empty():
		for item in Config.get_children():
			item.queue_free()
	for package in (SettingPool[tab] as Dictionary).keys():
		# 分隔各个包的选项
		if not package == Global.MainPackage:
			var packageName:Label = Label.new()
			packageName.set_text(package)
			Config.add_child(packageName)
		for key in (SettingPool[tab][package] as Dictionary).keys():
			var configGroup:HBoxContainer = HBoxContainer.new()
			var configText = Label.new()
			configText.set_text("%s" % [key])
			configText.set_custom_minimum_size(Vector2(200, 0))
			configGroup.add_child(configText)
			configGroup.mouse_entered.connect(bindDescription.bind(tab, key, package))
			configGroup.mouse_exited.connect(removeDescription)
			match typeof(SettingPool[tab][package][key]):
				TYPE_BOOL:
					var i:CheckButton = CheckButton.new()
					i.set_mouse_filter(Control.MOUSE_FILTER_PASS)
					i.button_pressed = SettingPool[tab][package][key]
					configGroup.add_child(i)
					Config.add_child(configGroup)
				TYPE_ARRAY:
					var i = OptionButton.new()
					i.set_mouse_filter(Control.MOUSE_FILTER_PASS)
					var index = 1
					while index < (SettingPool[tab][package][key] as Array).size():
						i.add_item(str(SettingPool[tab][package][key][index]), index - 1)
						if SettingPool[tab][package][key][index] == SettingPool[tab][package][key][0]:
							i.select(index - 1)
						index += 1
					i.item_selected.connect(updateSetting.bind(package, tab, key, i).unbind(1))
					configGroup.add_child(i)
					Config.add_child(configGroup)
				TYPE_STRING:
					var i = LineEdit.new()
					i.set_mouse_filter(Control.MOUSE_FILTER_PASS)
					i.set_custom_minimum_size(Vector2(300, 0))
					i.text = SettingPool[tab][package][key]
					i.text_changed.connect(updateSetting.bind(package, tab, key, i).unbind(1))
					configGroup.add_child(i)
					Config.add_child(configGroup)
				TYPE_INT:
					continue
				TYPE_FLOAT:
					var i:HSlider = HSlider.new()
					i.set_mouse_filter(Control.MOUSE_FILTER_PASS)
					i.set_custom_minimum_size(Vector2(300, 0))
					i.max_value = 1
					i.step = 0.01
					i.value = SettingPool[tab][package][key]
					i.value_changed.connect(updateSetting.bind(package, tab, key, i).unbind(1))
					var numLabel:Label = Label.new()
					numLabel.set_custom_minimum_size(Vector2(100, 0))
					bindNumLabel(i.value, numLabel)
					i.value_changed.connect(bindNumLabel.bind(numLabel))
					configGroup.add_child(i)
					configGroup.add_child(numLabel)
					Config.add_child(configGroup)

# 绑定数字显示
func bindNumLabel(num:float, numLabel:Label):
	numLabel.text = "%d %%" % [num*100]

# 绑定简介
func bindDescription(tab, key, package):
	if (Global.Setting["description"] as Dictionary).keys().has(package):
		if (Global.Setting["description"][package] as Dictionary).keys().has(tab + "/" + key):
			Description.text = Global.Setting["description"][package][tab + "/" + key]

func removeDescription():
	Description.text = " "

# 更新设置&预览
func updateSetting(package:String, tab:String, key:String, item) -> void:
	match typeof(SettingPool[tab][package][key]):
		TYPE_BOOL:
			SettingPool[tab][package][key] = item.value
		TYPE_ARRAY:
			SettingPool[tab][package][key][0] = (item as OptionButton).get_item_text((item as OptionButton).selected)
			if (tab == "Video" and key == "Showmode") or (tab == "Video" and key == "Size"):
				(Global.USENODE("GUIManager") as GUIManager).changeShowmode(SettingPool[tab][package]["Showmode"][0], Rect2i(0, 0, int((SettingPool[tab][package]["Size"][0] as String).get_slice("x", 0)), int((SettingPool[tab][package]["Size"][0] as String).get_slice("x", 1))))
		TYPE_STRING:
			SettingPool[tab][package][key] = item.text
		TYPE_INT:
			SettingPool[tab][package][key] = (item as HSlider).value
			if tab == "Audio":
				Global.set_vol(key, (item as HSlider).value)
		TYPE_FLOAT:
			SettingPool[tab][package][key] = (item as HSlider).value
			if tab == "Audio":
				Global.set_vol(key, (item as HSlider).value)
