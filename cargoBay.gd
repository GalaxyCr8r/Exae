extends Object

var cargo : Dictionary = {}
var cargoSpaceMetersCubed : int = 100
var currentCargoSpaceMC : int = 0

var debugLabel : Node2D

func updateDebug(debugText:String):
	print("New current cargo space: "+String(currentCargoSpaceMC))
	
	if debugLabel:
		debugLabel.text = String(cargo)

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
	updateDebug(String(cargo))
	
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
		updateDebug(String(cargo))
	else:
		print("ERROR: Something stupid happened.")
		return -3
	
	return 0
	
""" Removes from our cargo the contents of the given dictionary. Is atomic. """
func removeAllWaresFromCargo(cargoDict : Dictionary):
	var ret
	var cargoBackup = cargo
	for key in cargoDict:
		var ware:R_Ware = key
		ret = removeCargo(ware.name, ware.volumePerUnitMetersCubed, cargoDict[key])
		if ret < 0:
			cargo = cargoBackup
			return ret
	
	return 0
