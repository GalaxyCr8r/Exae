extends Sprite
class_name ObjShip

enum ShipState {
	SEARCHING, GOING_TO_DEAL, SELLING_WARES, RUNNING_AWAY
}

export var hull = 10
export(R_Ware.CargoType) var type
export(int) var cargoSpaceMetersCubed = 100
var currentCargoSpaceMC = 0
var cargo = {}

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

""" Attempts to add cargo safely.
Returns -1 if given irrational arguments.
Returns -2 if it would exceed 'cargoSpaceMetersCubed'
"""
func addCargoWare(cargoWare:R_Ware, amount:int) -> int:
	return addCargo(cargoWare.name, cargoWare.volumePerUnitMetersCubed, amount)
func addCargo(cargoName:String, cargoVolume:int, cargoAmount:int) -> int:
	if cargoAmount < 0:
		print("ERROR")
		return -1
	if cargoVolume < 0:
		print("ERROR")
		return -1
	
	var totalAddedVolume = cargoVolume * cargoAmount
	
	if currentCargoSpaceMC + totalAddedVolume > cargoSpaceMetersCubed:
		return -2
	
	if cargo.has(cargoName):
		cargo[cargoName] = cargo[cargoName]+cargoAmount
	else:
		cargo[cargoName] = cargoAmount
	currentCargoSpaceMC += totalAddedVolume
	print("New current cargo space: "+String(currentCargoSpaceMC))
	if $Label:
		$Label.text = String(cargo)
	return 0

""" Attempts to remove cargo safely.
Returns -1 if given irrational arguments.
Returns -2 if it would make 'currentCargoSpaceMC' go below 0.
Returns -3 if the requested cargo to remove doesn't exist.
"""
func removeCargoWare(cargoWare:R_Ware, amount:int) -> int:
	return removeCargo(cargoWare.name, cargoWare.volumePerUnitMetersCubed, amount)
func removeCargo(cargoName:String, cargoVolume:int, cargoAmount:int) -> int:
	if cargoAmount < 0:
		print("ERROR")
		return -1
	if cargoVolume < 0:
		print("ERROR")
		return -1
	
	var totalAddedVolume = cargoVolume * cargoAmount
	
	if currentCargoSpaceMC - totalAddedVolume < 0:
		print("ERROR: Something stupid happened.")
		return -2
	
	if cargo.has(cargoName):
		cargo[cargoName] = cargo[cargoName] - cargoAmount
		currentCargoSpaceMC -= totalAddedVolume
		print("New current cargo space: "+String(currentCargoSpaceMC))
		if $Label:
			$Label.text = String(cargo)
	else:
		print("ERROR: Something stupid happened.")
		return -3
	return 0
