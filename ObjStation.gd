extends Sprite
class_name ObjStation

export(Resource) var produces
export(int) var startingHealth : int = 1000
export var cargoSpaceMetersCubed : int = 1000

var _produces:R_Ware
onready var health := startingHealth
onready var cargoBay : CargoBay = CargoBay.new(cargoSpaceMetersCubed)
var currentWork : int = -1

var currentSellPrice : int = -1
var requiredBuyPrice : Array = [] ### Array index' should match the array index of the ware's requirements

func _ready():
	#cargoBay.debugLabel = $Label
	
	if is_instance_valid(produces) and typeof(produces) != typeof(R_Ware):
		printerr("GAME OBJECT GIVEN INVALID 'PRODUCES'")
	else:
		_produces = produces
		_produces.validate()
		cargoBay.touchWare(_produces)
		cargoBay.addWare(load("res://wareTypes/R_EnergyCubes.tres"), 125)
		requiredBuyPrice.resize(_produces.requiredWares.size())
		
		updateWarePrice()

"""
Do one tick of station logic.
"""
func tick():
	#print("ticktock!")
	if _produces:
		#print("produces is valid! cw: " + String(currentWork))
		if currentWork < 0:
			if _produces.isSatisfiedBy(cargoBay.cargo):
				currentWork = 0
			else:
				print("Cargo bay doesn't satisfy production requirements.")
		else:
			currentWork += 1
		
		if currentWork >= _produces.timeToProduceSec:
			currentWork = -1
			var tmpCargo = cargoBay.cargo
			if cargoBay.removeSelectWares(_produces.getAllRequired()) >= 0:
				if cargoBay.addWare(_produces, 1) < 0 :
					print("Production didn't happened!!!")
					cargoBay.cargo=tmpCargo
					cargoBay.updateDebugWithCargo()
				
				updateWarePrice()
			else:
				cargoBay.cargo=tmpCargo
	
"""############################################################################
		tt    iii lll iii tt           
uu   uu tt        lll     tt    yy   yy
uu   uu tttt  iii lll iii tttt  yy   yy
uu   uu tt    iii lll iii tt     yyyyyy
 uuuu u  tttt iii lll iii  tttt      yy
								 yyyyy 
#############################################################################"""

func getProducedWareAmount() -> int:
	return cargoBay.wareAmount(_produces)

func getProducedWareVolume() -> int:
	return getWareVolume(_produces)

func getWareVolume(ware:R_Ware) -> int:
	if !cargoBay.has(ware):
		return 0
	
	return cargoBay.wareAmount(ware) * ware.volumePerUnitMetersCubed

func updateWarePrice():
	updateSellPrice()
	updateBuyPrice()

func updateSellPrice():
	### Calculate the ratio of produced wares to cargo size of the station
	var ratio : float = getProducedWareVolume() / float(cargoBay.cargoSpaceMetersCubed)
	### Then calculate how much we should sell it for - the more, the less cost.
	currentSellPrice = _produces.getAdjustedSellPrice(ratio)
	print(String(getProducedWareVolume())+" / "+String(float(cargoBay.cargoSpaceMetersCubed)))
	print(_produces.name + " - ratio: " +String(ratio)+ " : " + String(currentSellPrice))
	
	$Label.text = String(currentSellPrice) + "c\n" + String(cargoBay.cargo)
	
func updateBuyPrice():
	### Go through each ware type and update the buy price for it.
	for i in range(0, requiredBuyPrice.size()):
		var ware : R_Ware = _produces.requiredWares[i]
		var ratio : float = getWareVolume(ware) / float(cargoBay.cargoSpaceMetersCubed)
		requiredBuyPrice[i] = ware.getAdjustedBuyPrice(ratio)

func requires(ware:R_Ware) -> bool:
	return _produces.requires(ware)
