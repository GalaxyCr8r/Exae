extends Sprite
class_name ObjShip

enum ShipState {
	SEARCHING, GOING_TO_DEAL, SELLING_WARES, RUNNING_AWAY
}

export var hull = 10
export(R_Ware.CargoType) var type ### TODO Use this
export(int) var cargoSpaceMetersCubed = 100
onready var cargoBay : CargoBay = CargoBay.new(cargoSpaceMetersCubed)

export(NodePath) var destinationPosition

var destination : Node2D
export(ShipState) var state = ShipState.SEARCHING

func _ready():
	destination = get_node(destinationPosition)
	if destination == null:
		destination = Node2D.new()
		get_parent().add_child(destination)
		destination.position = position

func _process(delta):
	if destination && state == ShipState.GOING_TO_DEAL:
		position += Vector2.LEFT.rotated(position.angle_to_point(destination.position)) * delta * 10
	
		if position.distance_to(destination.position) < 5:
			arrivedAtDestination()

""" Meant to be overwritten by child classes """
func arrivedAtDestination():
	destination = null
	print("arrived!")

""" Meant to be overwritten by child classes """
func tick():
	pass
	
"""############################################################################
		tt    iii lll iii tt           
uu   uu tt        lll     tt    yy   yy
uu   uu tttt  iii lll iii tttt  yy   yy
uu   uu tt    iii lll iii tt     yyyyyy
 uuuu u  tttt iii lll iii  tttt      yy
								 yyyyy 
#############################################################################"""

func findClosestStation() -> ObjStation:
	var targetStation = null
	var entity:Node2D
	for entity in get_parent().get_children():
		if entity.is_in_group("stations"):
			if destination != null:
				if entity == destination:
					continue
			if !targetStation:
				targetStation = entity
			else:
				if position.distance_to(entity.position) < position.distance_to(targetStation.position):
					targetStation = entity
	if !targetStation:
		print("WARNING: Couldn't find any stations in-sector.")
	return targetStation

