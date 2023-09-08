extends GUIModel

### 常量
# 控件
@onready var PackageList:ItemList = $DLCBox/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/PackageList
@onready var PackageIcon:TextureRect = $DLCBox/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Detail/AspectRatioContainer/PackageIcon
@onready var Author:RichTextLabel = $DLCBox/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Detail/Author
@onready var Website:RichTextLabel = $DLCBox/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Detail/Website
@onready var Description:RichTextLabel = $DLCBox/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Detail/Description
@onready var Active:CheckButton = $DLCBox/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Detail/ActiveButtom
### 变量
var choosePak:String = ""
func _GUI_init():
	Author.text = "点选左侧包列表了解详情……"
	Description.text = " "
	Website.text = " "
	for package in (Global.AutoLoad as AutoLoad).PackPool.keys():
		var ItemIndex:int = PackageList.add_item((Global.AutoLoad as AutoLoad).getPackageCig(package, "name") + " " + (Global.AutoLoad as AutoLoad).getPackageCig(package, "version"))
		PackageList.set_item_metadata(ItemIndex, Global.AutoLoad.PackPool[package])
		if (Global.AutoLoad.PackPool[package] as Dictionary).has("icon") and FileAccess.file_exists(Global.AutoLoad.PackPool[package]["address"] + Global.AutoLoad.PackPool[package]["icon"]):
			PackageList.set_item_icon(ItemIndex, load(Global.AutoLoad.PackPool[package]["address"] + Global.AutoLoad.PackPool[package]["icon"]))
		var tooltip:String = "包名：" + package
		tooltip += "\n类型：" + (Global.AutoLoad as AutoLoad).getPackageCig(package, "type")
		if (Global.AutoLoad as AutoLoad).enablePack.has(package) and (Global.AutoLoad as AutoLoad).enablePack[package]:
			tooltip += "\n【已启用】"
		else:
			tooltip += "\n【未启用】"
		PackageList.set_item_tooltip(
			ItemIndex,
			tooltip
			)

func _ready():
	PackageList.item_clicked.connect(showPakDetail)
	Website.meta_clicked.connect(_richtextlabel_on_meta_clicked)
	Website.tooltip_text = "点击网址打开"
	Active.pressed.connect(Pakenable)

func _process(_delta):
	pass

# 取消
func _on_cancel_pressed():
	queue_free()

# 确认
func _on_apply_pressed():
	queue_free()

# 显示包详情
func showPakDetail(index: int, _at_position: Vector2, _mouse_button_index: int):
	PackageIcon.texture = PackageList.get_item_icon(index)
	var packageCig:Dictionary = PackageList.get_item_metadata(index)
	choosePak = packageCig["PackPoolID"]
	if packageCig.has("website"):
		Website.text = "网址：[url=" + packageCig["website"] + "]" + packageCig["website"] + "[/url]"
	if packageCig.has("author"):
		Author.text = "作者：" + packageCig["author"]
	else:
		Author.text = "作者：未知"
	if packageCig.has("description"):
		Description.text = "描述：" + packageCig["description"]
	else:
		Description.text = "描述：此包没有相关描述……"
	if (Global.AutoLoad as AutoLoad).enablePack.has(packageCig["PackPoolID"]) and (Global.AutoLoad as AutoLoad).enablePack[packageCig["PackPoolID"]]:
		Active.button_pressed = true
		Active.text = "【已启用】"
	else:
		Active.button_pressed = false
		Active.text = "【未启用】"
	if packageCig["PackPoolID"] == Global.MainPackage:
		Active.disabled = true
		Active.text = "【主体包】"
	else:
		Active.disabled = false

func Pakenable():
	pass

func _richtextlabel_on_meta_clicked(meta):
	OS.shell_open(str(meta))
