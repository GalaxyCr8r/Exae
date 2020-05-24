extends ObjShip

export(Array, Resource) var onlyTradeTheseWares = []

func _ready():
	._ready()
	if destination == null:
		print("ERROR")
	
	# TODO validate "onlyTradeTheseWares"
	
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
			if isWareValidToTrade(destStation._produces):
				tmpStat = findStationWithBestDeal(destStation._produces.name)
				if destStation.hasWareToSell() and tmpStat != null:
					buyFromStation(destStation)
					destination = tmpStat
					state = ShipState.GOING_TO_DEAL
					return
			
			### Otherwise, try to find the most needed ware to supply this station.
			var tmpWare:R_Ware = destStation.mostNeededRequiredWare()
			if tmpWare != null:
				# And sometimes, pick a random ware instead
				if randi() % 10 < 5 or !isWareValidToTrade(tmpWare):
					tmpWare = destStation.pickRandomRequiredWare()
			
			if tmpWare != null && isWareValidToTrade(tmpWare):
				wareName = tmpWare.name
				tmpStat = findCheapestStation(wareName)
		
		# Pick a random ware in our inventory to sell
		if wareName == "":
			wareName = cargoBay.getRandomWareName()
			if wareName != "": # Don't need to check if its valid to trade since its already in our cargobay!
				tmpStat = findStationWithBestDeal(wareName)
		
		# If we got here without finding a station that means we should go find
		# a new station on our own.
		if tmpStat == null:
			if onlyTradeTheseWares.size() == 1:
				# Find a station that has the ware we trade in.
				tmpStat = findStationWithBestDeal(onlyTradeTheseWares[0].name)
			elif onlyTradeTheseWares.size() > 0:
				# Find a station that has a random ware we trade in.
				tmpStat = findStationWithBestDeal(onlyTradeTheseWares[randi() % onlyTradeTheseWares.size()].name)
			else:
				# Just find the closest station.
				tmpStat = findClosestStation()
		
		if tmpStat != null:
			# If we found a station to buy or sell at, go to it!
			destination = tmpStat
			state = ShipState.GOING_TO_DEAL
		else:
			print("ERROR: Cannot find place to sell!") # Currently this should never happen.

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
				if !destStation.doesStationWantWare(reqWare):
					continue
				
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

func findNewStationToSellTo():#### TODO: Determine if this is OBE??
	### Its assumed that whomever calls this actually HAS the ware that destination._produces!
	#if !cargoBay.has(destination._produces):
		#return
		
	### Find a station that needs the ware we just purchased
	var targetStation = null
	var entity:Node2D
	var highestPrice : int = 0 ### TODO: Find ALL stations with the highest price and then pick one randomly.
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

func isWareValidToTrade(tradeWare:R_Ware) -> bool:
	if onlyTradeTheseWares.size() == 0:
		return true
	for ware in onlyTradeTheseWares:
		if ware.name == tradeWare.name:
			return true
	return false
