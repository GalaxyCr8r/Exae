extends Sprite
class_name ObjStation

export(Resource) var produces
export(int) var startingHealth : int = 1000
export var cargoSpaceMetersCubed : int = 1000

var _produces:R_Ware
onready var health := startingHealth
var cargo = {}
var currentWork : int = -1
var currentCargoSpaceMC : int = 0

func _ready():
	if is_instance_valid(produces) and typeof(produces) != typeof(R_Ware):
		printerr("GAME OBJECT GIVEN INVALID 'PRODUCES'")
	else:
		_produces = produces
		_produces.validate()
		cargo[_produces.name] = 0

"""
Do one tick of station logic.
"""
func tick():
	print("ticktock!")
	if _produces:
		print("produces is valid! cw: " + String(currentWork))
		if currentWork < 0:
			if _produces.isSatisfiedBy(cargo):
				currentWork = 0
			else:
				print("Cargo bay doesn't satisfy production requirements.")
		else:
			currentWork += 1
		
		if currentWork >= _produces.timeToProduceSec:
			currentWork = -1
			addCargo(_produces.name, _produces.volumePerUnitMetersCubed, 1)
			print("Production happened!!!")
			print(String(cargo))

""" Attempts to add cargo safely.
Returns -1 if given irrational arguments.
Returns -2 if it would exceed 'cargoSpaceMetersCubed'
"""
func addCargo(cargoName, cargoVolume, cargoAmount):
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

""" Attempts to remove cargo safely.
Returns -1 if given irrational arguments.
Returns -2 if it would make 'currentCargoSpaceMC' go below 0.
Returns -3 if the requested cargo to remove doesn't exist.
"""
func removeCargo(cargoName, cargoVolume, cargoAmount):
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
	
