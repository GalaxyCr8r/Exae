extends ObjShip


func _ready():
	._ready()
	if destination == null:
		print("ERROR")
	
	## Freighters should find the closest station and start trading
	### TODO: Check if the station is friendly before considering
	var targetStation = findClosestStation()
	
	if !targetStation:
		### TODO: When warpholes get implemented, search through the nearest one to find a station.
		print("WARNING: Couldn't find a destination station to troll.")
	else:
		destination = targetStation
		state = ShipState.GOING_TO_DEAL
	
	cargoBay.debugLabel = $Label

func tick():
	if state == ShipState.SEARCHING:
		### Find a station to trade with that isn't within 10 units of us. TODO
		var tmpStat = findNewStationToSellTo()
		if tmpStat != null:
			destination = tmpStat
			state = ShipState.GOING_TO_DEAL
		else:
			### Try to find a ware at the current station that is needed and try to buy it.
			tmpStat = findClosestStation()
			if tmpStat != null:
				destination = tmpStat
				state = ShipState.GOING_TO_DEAL
			else:
				print("WARNING: Cannot find place to sell!")

func arrivedAtDestination():
	var destStation : ObjStation = destination
	
	if state == ShipState.GOING_TO_DEAL or state == ShipState.SELLING_WARES:
		### Try to sell as much as possible to empty out the cargobay so we can buy the max we can. TODO
		sellCargoToStation(destStation)
		
		### Buy as much as I can that this station produces.
		buyFromStation(destStation)
		
		### Find a station to sell this cargo at for max profits.TODO
		pass
	
	if false: #state == ShipState.SELLING_WARES
		### Try to sell my wares at this station. TODO
		
		### If I still have cargo, find somewhere else to sell for max profits. TODO
		### If not, find the next station
		pass
	
	state = ShipState.SEARCHING

func sellCargoToStation(destStation:ObjStation):
	### Check every ware in our cargo to see if its a required ware of the station.
	for wareName in cargoBay.cargo:
		for i in range(0, destStation._produces.requiredWares.size()):
			var reqWare:R_Ware = destStation._produces.requiredWares[i]
			if reqWare.name == wareName:
				### SELL IT! TODO Make it smarter, this will currently fail if the station can't buy all of it.
				if destStation.cargoBay.addWare(reqWare, cargoBay.wareNameAmount(wareName)) >= 0:
					cargoBay.removeWare(reqWare, cargoBay.wareNameAmount(wareName))

func buyFromStation(destStation:ObjStation):
	var amtOfProducedWareAvailable = destStation.getProducedWareAmount()
	
	if amtOfProducedWareAvailable > 0:
		### If it's close to max price, go to a different station TODO
		### See how much we can buy to fill up our cargo.
		var totalPossibleWaresToBuy = cargoBay.spaceAvailable() / destStation._produces.volumePerUnitMetersCubed
		
		if totalPossibleWaresToBuy > amtOfProducedWareAvailable:
			totalPossibleWaresToBuy = amtOfProducedWareAvailable
		
		if totalPossibleWaresToBuy > 0:
			### Buy them! TODO
			destStation.cargoBay.removeWare(destStation._produces, totalPossibleWaresToBuy)
			cargoBay.addWare(destStation._produces, totalPossibleWaresToBuy)
	pass

func findNewStationToSellTo():
	### Find a station that needs the ware we just purchased
	### Its assumed that whomever calls this actually HAS the ware that destination._produces!
	var targetStation = null
	var entity:Node2D
	for entity in get_parent().get_children():
		if entity.is_in_group("stations"):
			## Ignore it if it's the current destination!
			if destination == entity:
				continue
			if !entity.requires(destination._produces):
				continue
			
			if !targetStation:
				targetStation = entity
			else:
				if position.distance_to(entity.position) < position.distance_to(targetStation.position):
					targetStation = entity
	if !targetStation:
		print("WARNING: Couldn't find any stations in-sector.")
	return targetStation
