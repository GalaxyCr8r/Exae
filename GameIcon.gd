extends Sprite

export(Resource) var produces


# Called when the node enters the scene tree for the first time.
func _ready():
	if is_instance_valid(produces) and typeof(produces) != typeof(Ware):
		printerr("GAME OBJECT GIVEN INVALID 'PRODUCES'")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
