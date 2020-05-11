extends Resource
class_name Ware

enum CargoType { CONTAINER, SOLID, LIQUID, META }

export var name = "tbd"
export(CargoType) var type
export var timeToProduceSec = 1.0
export var volumePerUnitMetersCubed = 10.0

func _init():
	pass
