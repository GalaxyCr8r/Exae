extends Object
class_name CargoBay

var cargo : Dictionary = {}
var maxSpaceMC : int = 100
var usedSpaceMC : int = 0

var debugLabel : Label

func _init(maxCargoSpaceMC):
	maxSpaceMC = maxCargoSpaceMC

func updateDebugWithCargo():
	updateDebug(String(cargo))

func updateDebug(debugText:String):
	#print("New current cargo space: "+String(usedSpaceMC))
	
	if debugLabel:
		debugLabel.text = String(cargo)

func has(ware:R_Ware):
	return cargo.has(ware.name)

func wareAmount(ware:R_Ware):
	if !cargo.has(ware.name):
		return 0
	return cargo[ware.name]

func wareNameAmount(wareName:String):
	if !cargo.has(wareName):
		return 0
	return cargo[wareName]

func spaceAvailable() -> int:
	return maxSpaceMC - usedSpaceMC

""" Make sure the given ware is at least set to 0 in the dictionary. """
func touchWare(ware:R_Ware):
	if !cargo.has(ware.name):
		cargo[ware.name] = 0

""" Attempts to add cargo safely. Is atomic.
Returns -1 if given irrational arguments.
Returns -2 if it would exceed 'maxSpaceMC'
"""
func addWare(cargoWare:R_Ware, amount:int) -> int:
	return addWareName(cargoWare.name, cargoWare.volumePerUnitMetersCubed, amount)
func addWareName(cargoName:String, cargoVolume:int, cargoAmount:int) -> int:
	if cargoAmount < 0:
		print("ERROR")
		return -1
	if cargoVolume < 0:
		print("ERROR")
		return -1
	
	var totalAddedVolume = cargoVolume * cargoAmount
	
	if usedSpaceMC + totalAddedVolume > maxSpaceMC:
		return -2
	
	if cargo.has(cargoName):
		cargo[cargoName] = cargo[cargoName]+cargoAmount
	else:
		cargo[cargoName] = cargoAmount
	
	usedSpaceMC += totalAddedVolume
	updateDebugWithCargo()
	
	return 0

""" Attempts to remove cargo safely. Is atomic.
Returns -1 if given irrational arguments.
Returns -2 if it would make 'usedSpaceMC' go below 0.
Returns -3 if the requested cargo to remove doesn't exist.
"""
func removeWare(cargoWare:R_Ware, amount:int) -> int:
	return removeWareName(cargoWare.name, cargoWare.volumePerUnitMetersCubed, amount)
func removeWareName(cargoName:String, cargoVolume:int, cargoAmount:int) -> int:
	if cargoAmount < 0:
		print("ERROR")
		return -1
	if cargoVolume < 0:
		print("ERROR")
		return -1
	
	var totalAddedVolume = cargoVolume * cargoAmount
	
	if usedSpaceMC - totalAddedVolume < 0:
		print("ERROR: Something stupid happened.")
		return -2
	
	if cargo.has(cargoName):
		cargo[cargoName] = cargo[cargoName] - cargoAmount
		usedSpaceMC -= totalAddedVolume
		updateDebugWithCargo()
	else:
		print("ERROR: Something stupid happened.")
		return -3
	
	return 0
	
""" Removes from our cargo the contents of the given dictionary. Is atomic. """
func removeSelectWares(cargoDict : Dictionary):
	var ret
	var cargoBackup = cargo
	for key in cargoDict:
		var ware:R_Ware = key
		ret = removeWare(ware, cargoDict[key])
		if ret < 0:
			cargo = cargoBackup
			return ret
	
	return 0

"""
Returns a random ware that exists in the inventory.
Returns an empty string if none can be found.
"""
func getRandomWareName() -> String:
	### First, find all the cargo wares that actually have amounts
	var tmpCargo = {}
	for wareName in cargo.keys():
		if cargo[wareName] > 0:
			tmpCargo[wareName] = 1
	
	# Then, return nothing or the only ware.
	if tmpCargo.size() == 0:
		return ""
	if tmpCargo.size() == 1:
		return tmpCargo[tmpCargo.keys().front()]
	
	# Otherwise, pick a random one.
	var wareNum = randi() % tmpCargo.size()
	var i = 0
	for wareName in tmpCargo.keys():
		if i == wareNum:
			return wareName
	return ""

