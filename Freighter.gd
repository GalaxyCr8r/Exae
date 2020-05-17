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
	var destStation : ObjStation = destination
	var tmpStat : ObjStation = null
	#var ware : R_Ware = null
	var wareName : String = ""
	
	if state == ShipState.SEARCHING:
		### Search for deals!
		if destStation != null:
			### Buy as much as I can that this station produces 
			#   but only IF you can find a place to sell to.
			#tmpStat = findNewStationToSellTo()
			tmpStat = findStationWithBestDeal(destStation._produces.name)
			if destStation.hasWareToSell() and tmpStat != null:
				buyFromStation(destStation)
				destination = tmpStat
				state = ShipState.GOING_TO_DEAL
				return
			
			### Otherwise, try to find the most needed ware to supply this station.
			var tmpWare:R_Ware = destStation.mostNeededRequiredWare()
			# And sometimes, pick a random ware instead
			if randi() % 10 < 5:
				tmpWare = destStation.pickRandomRequiredWare()
			
			if tmpWare != null:
				wareName = tmpWare.name
				tmpStat = findCheapestStation(wareName)
		
		# Pick a random ware in our inventory to sell
		if wareName == "":
			wareName = cargoBay.getRandomWareName()
			if wareName != "":
				tmpStat = findStationWithBestDeal(wareName)
		
		if tmpStat == null:
			# Just find the closest station.
			tmpStat = findClosestStation()
		
		if tmpStat != null:
			# If we found a station to buy or sell at, go to it!
			destination = tmpStat
			state = ShipState.GOING_TO_DEAL
		else:
			print("WARNING: Cannot find place to sell!") # Currently this should never happen.

func arrivedAtDestination():
	var destStation : ObjStation = destination
	
	if state == ShipState.GOING_TO_DEAL or state == ShipState.SELLING_WARES:
		### Try to sell as much as possible to empty out the cargobay so we can buy the max we can. TODO
		sellCargoToStation(destStation)
		
		
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
					destStation.updateWarePrice()

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
			destStation.updateWarePrice()
	pass

func findNewStationToSellTo():
	### Its assumed that whomever calls this actually HAS the ware that destination._produces!
	#if !cargoBay.has(destination._produces):
		#return
		
	### Find a station that needs the ware we just purchased
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
