# EXAE
![EXAE](/icon.png "EXAE Logo")

Inspired by the X-Series by Egosoft.
This is just a gameplay prototype for managing a trading empire with/against AI controlled trading empires.

## Gameplay

This limited gameplay prototype is based off the sector map for X2/X3, stations will require wares to produce wares.

They will rely on merchants to move the goods.

## Galaxy

The game is broken up into sectors.

### Economy

The overview of the economy looks like:

* Raw goods (Ore, Gas, Energy)
* Refined goods (Metal, Food, Wiring, etc.)
* Intermediate Wares (Mechanical Components, Electrical Components, Food Rations, Medical Supplies, etc.)
* End-products (Ships, Stations, and Satellite components)

Generally, stations that produce one type of good, requires goods above it. Raw goods are generated from the environment.

Goods that are higher tier should require the product of at least two stations below it. (i.e. a Metal Refinery would take two Ore Mines to fully supply it..)
This will mean that the highest tier is always desiring resources.

### Station Types

Most stations produce one type of good, however there are types of special stations that don't produce wares.

* Trading Stations
  * They attempt to aggregate excess goods from this system/sector
  
# Minimum Viable Demo

I say "Demo" instead of "Product" because what I have envisioned requires no player input.

It will be four simple sectors/systems that exercises a stripped down version of the economy to see how well it works.

The economy must work towards a goal. Otherwise it will stagnate and everything will fill up.

This is why there must be conflict, to destroy ships so that new ones must be built. And if not conflict, then war with entropy such as gradual wear and tear.

In this MVD it will be war, a second faction that is hositle will be inbetween the first faction and will destroy ships going between their sectors.

## Super MVD

Single sector, even more limited wares. Goal is to just test freighters ferrying goods around.

Shipyard will produce endless battleships as a resource sink.

## Wares

It will only include the following wares:

* Raw Goods
  * Ore
  * Gas
* Intermediate Goods
  * Metal
  * Coolant
  * Silicon
* End-Products
  * Electronics
  * Armor Plating
  * Structure

### Ware Generation

Raw goods must be procured by miners which will be limited later by mining speed and transit times.

## Stations

* Metal Refinery
* Coolant Distillery
* Silicon Refinery
* Electronics Factory
* Armor Plating Factory
* Structure Factory
* Shipyard

## Ships

There will only be a few types of ships at the beginning:

* Miner
* Freighter
* Builder
* Battleship

Freighters will most likely be broken up into multiple AI focui:
* Energy Traders
* Ore Traders
* Raw Goods Traders
* Intermediate Traders
And so on. Having a single AI to service all the stations will make the AI extremely unwieldly and
will most likely cause some very bad gaps in the economy if they all decide to do one thing.

## Sectors

Four sectors should be plenty to experiment with the inter-sector AI decision making. The first two sectors should be friendly,
the third should be occupied with an enemy faction. The fourth should be resource plentiful but forces you to go through the third sector.

1. Alpha sector
1. Beta sector
1. Gamma sector
1. Delta sector

