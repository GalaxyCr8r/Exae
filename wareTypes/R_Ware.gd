extends Resource
class_name R_Ware

enum CargoType { CONTAINER, SOLID, LIQUID, META }

export var name = "tbd"
export(CargoType) var type
export var timeToProduceSec = 1.0
export var volumePerUnitMetersCubed = 10.0

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

func getAllRequired() -> Dictionary:
	validate()
	
	var newDict = {}
	for i in range(0, requiredWares.size()):
		newDict[requiredWares[i]] = requiredAmt[i]
	return newDict
