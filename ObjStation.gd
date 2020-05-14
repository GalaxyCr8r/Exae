extends Sprite
class_name ObjStation

export(Resource) var produces
export(int) var startingHealth : int = 1000
export var cargoSpaceMetersCubed : int = 1000

var _produces:R_Ware
onready var health := startingHealth
var cargo : Dictionary = {"Energy Cubes":150}
var currentWork : int = -1
var currentCargoSpaceMC : int = 150

var currentSellPrice : int = -1
var requiredBuyPrice : Array = [] ### Array index' should match the array index of the ware's requirements

func _ready():
	if is_instance_valid(produces) and typeof(produces) != typeof(R_Ware):
		printerr("GAME OBJECT GIVEN INVALID 'PRODUCES'")
	else:
		_produces = produces
		_produces.validate()
		if !cargo.has(_produces.name):
			cargo[_produces.name] = 0
		requiredBuyPrice.resize(_produces.requiredWares.size())
		
		updateWarePrice()

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
			var tmpCargo = cargo
			if removeAllWaresFromCargo(_produces.getAllRequired()) >= 0:
				if addCargoWare(_produces, 1) >= 0 :
					print("Production happened!!!")
					updateWarePrice()
				else:
					cargo=tmpCargo
					print(String(cargo))
			else:
				cargo=tmpCargo
	
"""############################################################################
		tt    iii lll iii tt           
uu   uu tt        lll     tt    yy   yy
uu   uu tttt  iii lll iii tttt  yy   yy
uu   uu tt    iii lll iii tt     yyyyyy
 uuuu u  tttt iii lll iii  tttt      yy
								 yyyyy 
#############################################################################"""

func getProducedWareAmount() -> int:
	return cargo[_produces.name]
func getProducedWareVolume() -> int:
	if !cargo.has(_produces.name):
		return 0
	
	var wareAmt = cargo[_produces.name]
	return wareAmt * _produces.volumePerUnitMetersCubed
func getWareVolume(ware:R_Ware) -> int:
	if !cargo.has(ware.name):
		return 0
	
	var wareAmt = cargo[ware.name]
	return cargo[ware.name] * ware.volumePerUnitMetersCubed

func updateWarePrice():
	updateSellPrice()
	updateBuyPrice()

func updateSellPrice():
	### Calculate the ratio of produced wares to cargo size of the station
	var ratio = getProducedWareVolume() / cargoSpaceMetersCubed
	### Then calculate how much we should sell it for - the more, the less cost.
	currentSellPrice = _produces.getAdjustedSellPrice(ratio)
	
func updateBuyPrice():
	### Go through each ware type and update the buy price for it.
	for i in range(0, requiredBuyPrice.size()):
		var ware : R_Ware = _produces.requiredWares[i]
		var ratio = getWareVolume(ware) / cargoSpaceMetersCubed
		requiredBuyPrice[i] = ware.getAdjustedBuyPrice(ratio)

func requires(ware:R_Ware) -> bool:
	return _produces.requires(ware)

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
	
func removeAllWaresFromCargo(cargoDict : Dictionary):
	var ret
	
	for key in cargoDict:
		var ware:R_Ware = key
		ret = removeCargo(ware.name, ware.volumePerUnitMetersCubed, cargoDict[key])
		if ret < 0:
			return ret
	return 0
