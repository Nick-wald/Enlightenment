extends Node
class_name AudioManager

### 常量
# 操作标识符
# BGM背景音乐 BGS环境 SFX特效 UI用户界面 BATTLE战斗 TRANSITION过场 TALK对话
var BGMPlayer:AudioStreamPlayer = AudioStreamPlayer.new()
var SFXPlayer:AudioStreamPlayer = AudioStreamPlayer.new()
var UIPlayer:AudioStreamPlayer = AudioStreamPlayer.new()
### 变量
# BGM播放列表
var BGMPlayList:Array = []

func _ready():
	# player初始化
	BGMPlayer.set_name("BGMPlayer")
	SFXPlayer.set_name("SFXPlayer")
	UIPlayer.set_name("UIPlayer")
	Global.playerRegister("BGM", BGMPlayer)
	Global.playerRegister("SFX", SFXPlayer)
	Global.playerRegister("UI", UIPlayer)
	BGMPlayer.finished.connect(Callable(self, "BGMtran"))
	Global.currentSceneChange.connect(BGMtran)

func _process(_delta):
	pass

# 播放声音
func play(player, path, random:int = -1) -> void:
	match typeof(path):
		TYPE_STRING:
			if not path.get_extension() in ["mp3", "wav", "ogg"]:
				(Global.USENODE("TOP") as TOP).CONSOLEERROR("Unknown audio file extension: " + path.get_extension(), "AudioManager.play()")
				return
			if player is AudioStreamPlayer:
				(player as AudioStreamPlayer).stream = ResourceLoader.load(path)
				(player as AudioStreamPlayer).play()
		TYPE_ARRAY:
			if random < 0:
				pass

# UI声音播放
func UISound(type:String, random:int = -1, package:String = Global.DefaultPackage) -> void:
	var result = Global.audioGet("UI", type, package)
	if not result == "null":
		play(UIPlayer, result, random)
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEWARN("Unknown UI sound name: " + type, "AudioManager.UISound()")

# UI音效绑定
func bindUISound(nodeSignal:Signal, type:String, random:int = -1, package:String = Global.DefaultPackage) -> void:
	nodeSignal.connect(UISound.bind(type, random, package))

# UI音效绑定
func bindSFXSound(nodeSignal:Signal, type:String, random:int = -1, package:String = Global.DefaultPackage, player = SFXPlayer) -> void:
	nodeSignal.connect(SFXSound.bind(type, random, package, player))

# SFX声音播放
func SFXSound(type:String, random:int = -1, package:String = Global.DefaultPackage, player = SFXPlayer) -> void:
	var result = Global.audioGet("SFX", type, package)
	if not result == "null":
		if random < 0 and typeof(result) == TYPE_ARRAY:
			randomize()
			play(player, result[0] + str( randi_range(int(result[1]), int(result[2])) ) + "." + result[3] )
		elif typeof(result) == TYPE_ARRAY:
			play(player, result[0] + str( clampi(random, int(result[1]), int(result[2])) ) + "." + result[3] )
		else:
			play(player, result)

# BGM场景设置获取
func sceneBGM(scene:Dictionary) -> Dictionary:
	if (Global.AudioList["BGM"][scene.package] as Dictionary).has("scenesList"):
		return Global.AudioList["BGM"][scene.package]["scenesList"]
	else:
		return {}

# BGM播放处理
func BGMtran(scene:Dictionary) -> void:
	if not scene.is_empty() and sceneBGM(scene).has(scene.name):
		if not BGMPlayList.is_empty() and BGMPlayer.playing:
			BGMPlayList.resize(1)
		else:
			BGMPlayList.clear()
		for item in (sceneBGM(scene)[scene.name] as Array):
			if not BGMPlayList.is_empty() and item["song"] == BGMPlayList[0]["song"]:
				BGMPlayList[0]["loop"] = item["loop"]
			else:
				BGMPlayList.append(item)
		if not BGMPlayer.playing and not BGMPlayList.is_empty():
			var result
			if (BGMPlayList[0] as Dictionary).has("package"):
				result = Global.audioGet("BGM", BGMPlayList[0]["song"], BGMPlayList[0]["package"])
			else:
				result = Global.audioGet("BGM", BGMPlayList[0]["song"])
			play(BGMPlayer, result)
	elif not BGMPlayList.is_empty():
		if not BGMPlayList[0]["loop"] == 0:
			BGMPlayList[0]["loop"] -= 1
		else:
			BGMPlayList.pop_front()
			var result
			if (BGMPlayList[0] as Dictionary).has("package"):
				result = Global.audioGet("BGM", BGMPlayList[0]["song"], BGMPlayList[0]["package"])
			else:
				result = Global.audioGet("BGM", BGMPlayList[0]["song"])
			play(BGMPlayer, result)
