extends Control

func _ready():
	(Global.USENODE("GUIManager") as GUIManager).GUIModelBuilder("CharacterCreateGUI")

func _process(delta):
	pass
