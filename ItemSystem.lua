--Settings
local maxSlot = 31			--zero based -> 31 means 32 doublechests
local chestHeight = 8
local idleHeight = 12
local idleDirection = 0


--static variables
local fetchQueue = {}		--{name="minecraft:cobblestone", count=3574}
local items = {}			--{name="", alias="", stackSize=0, color=8, slots={[45]=3021}		Name<10
local x, y = 0, 0, 0

--constants
local nameFurnace = "minecraft:furnace"
local nameLapis = "minecraft:lapis_block"

--check compatibility
 if not turtle or not term.isColor() then
	error("only runs on advanced turtles")
end

--Compass Functions
local compass = peripheral.find("compass")
if not compass then
	error("turtle needs a compass")
end

function getFacing()
	local directions = {south=0, west=1, north=2, east=3}
	return directions[compass.getFacing()]
end

--moving Functions
function turnTo(direction)
	local currentDir = getFacing()
	local turningFunction = turtle.turnRight

	if (direction - currentDir) % 4 > 1 then
		turningFunction = turtle.turnLeft
	end

	while getFacing() ~= direction do
		turningFunction()
	end
end

function gotoY(destination)
	local moveFunc = turtle.up
	local increment = 1

	if y > destination then
		moveFunc = turtle.down
		increment = -1
	end

	while y ~= destination do
		if moveFunc() then
			y = y + increment
		else
			sleep(0.1)
		end
	end
end

--Wireless Functions

local requestPort = 65530
local broadcastPort = 65535

local wireless = peripheral.find("modem", function(name, modem) return modem.isWireless() end)

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

--Item functions

function getItemStock(item)
	if not item then return end

	local stock = 0

	for slot, count in pairs(item.slots) do
		stock = stock + count
	end
	return stock
end


--Homing

local debugSkipHoming = true

if not debugSkipHoming then
	print("Initializing Homing sequence")

	while true do
		local block = blockBelow()
		if block == nameFurnace or block == nameLapis then
			break
		end
		turtle.down()
	end

	if blockBelow() == nameFurnace then
		turnTo(getSideFurnace())
	end

	while blockBelow() ~= nameLapis do
		turtle.back()
	end

	turnTo(idleDirection)
	gotoY(idleHeight)

	print("Homed")
end

--Debug

for i=1, 153 do
	table.insert(items, {name = "name" .. i, alias = "TestItem" .. i, stackSize = 64, color = math.pow(2, math.random(1, 15)), slots={[i]=math.random(1, 3600)}})
end

--Displaying Items

local displayStartLine = 0
local displayMenu = nil		--{name="", count="", stock=0}
local termWidth, termHeight = term.getSize()

local defaultBackgroundColor = colors.black
local menuBackgroundColor = colors.gray
local requestCountValidCharsNum = {["0"]=true, ["1"]=true, ["2"]=true, ["3"]=true, ["4"]=true, ["5"]=true, ["6"]=true, ["7"]=true, ["8"]=true, ["9"]=true}
local requestCountValidCharsOperator = {["*"]=true, ["/"]=true, ["+"]=true, ["-"]=true}

function printRequestMenu()
	term.setBackgroundColor(menuBackgroundColor)
	for y=4, 10 do
		term.setCursorPos(9, y)
		term.write("                     ")
	end
	term.setCursorPos(10, 5)
	term.write("Request " .. displayMenu.name)
	term.setCursorPos(14, 6)
	term.write("Stock: " .. displayMenu.stock)
	
	term.setCursorPos(10, 10)
	term.setTextColor(colors.orange)
	term.write("[  OK  ]   [CANCEL]")
	term.setTextColor(colors.white)
	
	updateRequestMenu()
end

function updateRequestMenu(message)
	term.setCursorPos(13, 7)
	term.setBackgroundColor(colors.cyan)
	term.write("             ")
	term.setCursorPos(14, 7)
	term.write(displayMenu.count)
	
	term.setBackgroundColor(menuBackgroundColor)
	if message then
		term.setCursorPos(10, 9)
		term.setTextColor(colors.red)
		term.write(message)
		term.setTextColor(colors.white)
	else
		term.setCursorPos(9, 9)
		term.write("                     ")
	end
end

function printDisplay()
	local lineCount = math.ceil(#items / 2)

	if displayStartLine < 0 then
		displayStartLine = 0
	end

	if displayStartLine > (math.ceil(#items / 2) - termHeight) then
		displayStartLine = math.ceil(#items / 2) - termHeight
	end

	term.setBackgroundColor(defaultBackgroundColor)
	term.clear()

	for line=1, termHeight do
		local itemIndex = (line + displayStartLine) * 2 - 1

		local item = items[itemIndex]

		if not item then
			break
		end

		term.setCursorPos(1, line)
		term.setBackgroundColor(item.color)
		term.write(item.alias)

		term.setCursorPos(13, line)
		term.setBackgroundColor(defaultBackgroundColor)
		term.write(getItemStock(item))

		local item = items[itemIndex + 1]

		if not item then
			break
		end

		term.setCursorPos(20, line)
		term.setBackgroundColor(item.color)
		term.write(item.alias)

		term.setCursorPos(32, line)
		term.setBackgroundColor(defaultBackgroundColor)
		term.write(getItemStock(item))
	end

	local scrollBarHeight = math.ceil(termHeight * termHeight / math.ceil(#items / 2))
	local scrollBarBegin = math.floor((termHeight - scrollBarHeight)* displayStartLine / (math.ceil(#items / 2) - termHeight))

	for i=1, scrollBarHeight do
		term.setCursorPos(termWidth, i + scrollBarBegin)
		term.write("#")
	end
end

function executeMenuRequest()

--FLOOR RESULT


end

--Receiving events

function eventListen()
	while true do
		local eventData = {os.pullEvent()}

		if eventData[1] == "mouse_scroll" then
			if not displayMenu then
				displayStartLine = displayStartLine + eventData[2]
				printDisplay()
			end
		elseif eventData[1] == "mouse_click" then
			--x:3 y:4
			if displayMenu then
				if eventData[4] == 10 then
					local xPos = eventData[3]
					
					if xPos >= 10 and xPos <= 17 then
						executeMenuRequest()
					elseif xPos >= 21 and xPos <= 28 then
						displayMenu = nil
						printDisplay()
					end
				end
			else
				local itemIndex = (displayStartLine * 2) + (eventData[4]) * 2 + math.floor(eventData[3] / 20) - 1
				if items[itemIndex] then
					displayMenu = {name=items[itemIndex].alias, count="", stock=getItemStock(items[itemIndex])}
					printRequestMenu()
				end
			end
		elseif eventData[1] == "key" and displayMenu then
			local scancode = eventData[2]
			
			if scancode == keys.backspace then
				if displayMenu.count:len() > 0 then
					displayMenu.count = displayMenu.count:sub(1, displayMenu.count:len() - 1)
					updateRequestMenu()
				else
					displayMenu = nil
					printDisplay()
				end
			elseif scancode == keys.enter then
				executeMenuRequest()				
			end
		elseif eventData[1] == "char" and displayMenu then
			local character = eventData[2]
			
			if displayMenu.count:len() < 11 then
				if requestCountValidCharsNum[character] then
					displayMenu.count = displayMenu.count .. character
					updateRequestMenu()
				elseif requestCountValidCharsOperator[character] then
					local countLength = displayMenu.count:len()
					if countLength > 0 and not requestCountValidCharsOperator[displayMenu.count:sub(countLength, countLength)] then
						displayMenu.count = displayMenu.count .. character
						updateRequestMenu()
					else
						updateRequestMenu("consecutive operator")
					end
				end
			end
		elseif eventData[1] == "modem_message" then

		end
	end
end

function mainLoop()
	while true do
		if #fetchQueue > 0 then
			--fetch items
		end



		coroutine.yield()
	end
end

printDisplay()
parallel.waitForAny(eventListen, mainLoop)

error("Either main loop or wireless listen yielded fatal error")