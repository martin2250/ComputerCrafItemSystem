
--check compatibility
if not turtle or not term.isColor() then
	error("only runs on advanced turtles")
end

--Compass Functions
compass = peripheral.find("compass")
if not compass then
	error("turtle needs a compass")
end

function getFacing()
	local directions = {south=0, west=1, north=2, east=3}
	return directions[compass.getFacing()]
end

--moving Functions
function turnTo(direction)

	while direction < 0 do
		direction = direction + 4
	end
	
	direction = direction % 4
	local currentDir = getFacing()
	local turningFunction = turtle.turnRight

	if (direction - currentDir) % 4 > 1 then
		turningFunction = turtle.turnLeft
	end

	while getFacing() ~= direction do
		turningFunction()
	end
end

--Wireless Functions

wireless = peripheral.find("modem", function(name, modem) return modem.isWireless() end)

if not wireless then
	error("turtle needs a wireless modem")
end

wireless.open(requestPort)

--returns the direction of the current slot
function getSideFurnace()
	local furnaceMetadataToSide = {[3]=2, [4]=3, [2]=0, [5]=1}

	local sucess, data = turtle.inspectDown()

	if not sucess or data.name ~= nameFurnace then
		error("Turtle not on furnace")
	end

	return furnaceMetadataToSide[data.metadata]
end

--analyzeFunctions

function blockBelow()
	local sucess, data = turtle.inspectDown()
	if not sucess then return end
	return data.name
end

function getIdFromData(item)
	local id = item.name
	if item.damage ~= 0 then
		id = id .. ":" .. item.damage
	end
	return id
end