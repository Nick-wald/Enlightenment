extends Node
class_name Enlightenment

### 常量
const PackageName:String = "Enlightenment"

# 包结束载入函数
func _Package_ready():
	# 引导项
	(Global.AutoLoad as AutoLoad).setBeginning((Global.AutoLoad as AutoLoad).getPackageCig(PackageName, "Beginning"))
	(Global.AutoLoad as AutoLoad).setTransition((Global.AutoLoad as AutoLoad).getPackageCig(PackageName, "Transition"))
	Global.addSetting((Global.AutoLoad as AutoLoad).READJSON((Global.AutoLoad as AutoLoad).getPackageCig(PackageName, "address") + (Global.AutoLoad as AutoLoad).getPackageCig(PackageName, "Setting")))
	Global.addTransitionTips((Global.AutoLoad as AutoLoad).READJSON((Global.AutoLoad as AutoLoad).getPackageCig(PackageName, "address") + (Global.AutoLoad as AutoLoad).getPackageCig(PackageName, "TransitionTip")))
	Global.addAudioList((Global.AutoLoad as AutoLoad).READJSON((Global.AutoLoad as AutoLoad).getPackageCig(PackageName, "address") + (Global.AutoLoad as AutoLoad).getPackageCig(PackageName, "AudioList")))
	queue_free()

# 包载入函数
func _ready():
	Global.setDefaultPackage(PackageName)
