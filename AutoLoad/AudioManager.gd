extends Node
class_name AudioManager

### 常量
# 播放器控件
@onready var UIPlayer:AudioStreamPlayer = $UI_GROUP/UI_Player
@onready var BGMPlayer:AudioStreamPlayer = $BGM_GROUP/BGM_Player
@onready var SFXPlayer:AudioStreamPlayer = $SFX_GROUP/SFX_Player
# 音频文件路径
const AudioPath:String = "res://sources/audio/"
# 操作标识符
# BGM背景音乐 BGS环境 SFX特效 UI用户界面 BATTLE战斗 TRANSITION过场 TALK对话

### 变量
# 音频文件汇总
var AudioList:Dictionary = {}
# BGM播放列表
var BGMPlayList:Array = []

func _ready():
	var busindex:int = 1
	# 载入音频文件列表
	AudioList = Global.AutoLoad.READJSON(AudioPath + "Audio.json")
	# 初始化音频总线
	for i in get_children():
		var busname:String = i.name.get_slice("_", 0)
		if not busname == "Master":
			AudioServer.add_bus(busindex)
			AudioServer.set_bus_name(busindex, busname)
			busindex += 1
		set_vol(busname, Global.Setting["config"]["Audio"][busname])
		for j in i.get_children():
			if j is AudioStreamPlayer:
				(j as AudioStreamPlayer).set_bus(StringName(busname))
			elif j is AudioStreamPlayer2D:
				(j as AudioStreamPlayer2D).set_bus(StringName(busname))
	# BGM播放初始化
	BGMPlayer.finished.connect(Callable(self, "BGMtran"))

func _process(_delta):
	pass

# player挂载器
func playerRegister():
	pass

# 设置音量
func set_vol(MusicManagerflag:String, vol:float = 0.5) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MusicManagerflag), linear_to_db(clamp(vol, 0, 1)))

# 播放声音
func play(player, path:String) -> void:
	if not path.get_extension() in ["mp3", "wav", "ogg"]:
		(Global.USENODE("TOP") as TOP).CONSOLEERROR("Unknown audio file extension: " + path.get_extension(), "AudioManager.play()")
		return
	if player is AudioStreamPlayer:
		(player as AudioStreamPlayer).stream = ResourceLoader.load(path)
		(player as AudioStreamPlayer).play()

# UI声音播放
func UISound(type:String) -> void:
	if (AudioList["UI"] as Dictionary).has(type):
		play(UIPlayer, AudioPath + AudioList["UI"][type])
	else:
		(Global.USENODE("TOP") as TOP).CONSOLEWARN("Unknown UI sound name: " + type, "AudioManager.UISound()")

# UI音效绑定
func bindUISound(nodeSignal:Signal, type:String) -> void:
	nodeSignal.connect(UISound.bind(type))

# UI音效绑定
func bindSFXSound(nodeSignal:Signal, type:String, random:int = -1, player = SFXPlayer) -> void:
	nodeSignal.connect(SFXSound.bind(type, random, player))

# SFX声音播放
func SFXSound(type:String, random:int = -1, player = SFXPlayer) -> void:
	if (AudioList["SFX"] as Dictionary).has(type):
		if random < 0 and typeof(AudioList["SFX"][type]) == TYPE_ARRAY:
			randomize()
			play(player, AudioPath + AudioList["SFX"][type][0] + str( randi_range(int(AudioList["SFX"][type][1]), int(AudioList["SFX"][type][2])) ) + "." + AudioList["SFX"][type][3] )
		elif typeof(AudioList["SFX"][type]) == TYPE_ARRAY:
			play(player, AudioPath + AudioList["SFX"][type][0] + str( clampi(random, int(AudioList["SFX"][type][1]), int(AudioList["SFX"][type][2])) ) + "." + AudioList["SFX"][type][3] )
		else:
			play(player, AudioPath + AudioList["SFX"][type])

# BGM播放处理
func BGMtran(scene:String = "null") -> void:
	if not scene == "null" and (AudioList["BGM"] as Dictionary).has(scene):
		if not BGMPlayList.is_empty() and BGMPlayer.playing:
			BGMPlayList.resize(1)
		else:
			BGMPlayList.clear()
		for item in AudioList["BGM"][scene]:
			if not BGMPlayList.is_empty() and item["song"] == BGMPlayList[0]["song"]:
				BGMPlayList[0]["loop"] = item["loop"]
			else:
				BGMPlayList.append(item)
		if not BGMPlayer.playing and not BGMPlayList.is_empty():
			play(BGMPlayer, AudioPath + BGMPlayList[0]["song"])
	elif not BGMPlayList.is_empty():
		if not BGMPlayList[0]["loop"] == 0:
			BGMPlayList[0]["loop"] -= 1
		else:
			BGMPlayList.pop_front()
		play(BGMPlayer, AudioPath + BGMPlayList[0]["song"])
