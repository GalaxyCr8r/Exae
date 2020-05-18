extends Resource
class_name R_Ware

enum CargoType { CONTAINER, SOLID, LIQUID, META }

export var name = "tbd"
export(CargoType) var type
export var timeToProduceSec = 1.0
export(int) var volumePerUnitMetersCubed = 10

### MUST be the same length as 'requiredAmt'
export(Array, Resource) var requiredWares = []
### MUST be the same length as 'requiredWares'
export(Array, int) var requiredAmt = []

### X is the lowest price, Y is the highest price
export(Vector2) var warePrice

""" This should be called as soon as possible whereever R_Ware is used. """
func validate():
	if requiredWares.size() != requiredAmt.size():
		print("ERROR: Ware " + self.get_class() + " doesn't have matching required amounts!")
	if warePrice.x > warePrice.y:
		print("ERROR: Highest price for ware is lower than the lowest price!")

"""############################################################################
		tt    iii lll iii tt           
uu   uu tt        lll     tt    yy   yy
uu   uu tttt  iii lll iii tttt  yy   yy
uu   uu tt    iii lll iii tt     yyyyyy
 uuuu u  tttt iii lll iii  tttt      yy
								 yyyyy 
#############################################################################"""

""" Its assumed ratio is a decimal within [0.0, 1.0] """
func getAdjustedSellPrice(ratio:float) -> float:
	var adjusted = warePrice.y - warePrice.x
	adjusted *= 1.0 - ratio
	return warePrice.x + adjusted

""" Its assumed ratio is a decimal within [0.0, 1.0] """
func getAdjustedBuyPrice(ratio:float) -> float:
	var adjusted = warePrice.y - warePrice.x
	adjusted *= 1.0 - ratio
	return warePrice.x + adjusted

""" Does the given cargo dictionary fulfill this ware's production requirements? """
func isSatisfiedBy(dict:Dictionary) -> bool:
	validate()
	
	if requiredWares.size() == 0:
		return true
	
	for i in range(0, requiredWares.size()):
		var ware : R_Ware = requiredWares[i]
		# Check if the given cargo dictionary contains one of the required wares
		if dict.has(ware.name):
			if dict[ware.name] < requiredAmt[i]:
				# If it doesn't have enough, fail it
				return false
		else:
			# If it doesn't have the ware type at all, fail it
			return false
	
	# If we got here, then all requirements were satsified!
	return true

### Does this ware require the given ware to be produced?
func requires(ware:R_Ware) -> bool:
	for i in range(0, requiredWares.size()):
		if requiredWares[i] == ware:
			return true
	return false

func getAllRequired() -> Dictionary:
	validate()
	
	var newDict = {}
	for i in range(0, requiredWares.size()):
		newDict[requiredWares[i]] = requiredAmt[i]
	return newDict
