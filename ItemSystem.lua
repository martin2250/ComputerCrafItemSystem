local fetchQueue = {}		--{name="minecraft:cobblestone", count=3574}
local items = {}			--{name="", alias="", stackSize=0}

local direction, x, y = 0, 0, 0

local compass = peripheral.find("compass")
if not compass then
	print("turtle needs a compass")
	return
end

local function getFacing()
	local directions = {south=0, west=1, north=2, east=3}
	return directions[compass.getFacing()]
end

local function getSideFurnace()
	local furnaceMetadataToSide = {[3]=2, [4]=3, [2]=0, [5]=1}
	
	local sucess, data = turtle.inspectDown()
	
	if not sucess or data.name ~= "minecraft:furnace" then
		error("Turtle not on furnace")
	end
	
	return furnaceMetadataToSide[data.metadata]
end

local requestPort = 65560
local broadcastPort = 65565

local wireless = peripheral.find("modem", function(name, modem) return modem.isWireless() end)

if not wireless then
	error("turtle needs a wireless modem")
	return
end

Wireless.open(requestPort)