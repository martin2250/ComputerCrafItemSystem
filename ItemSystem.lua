--Settings
maxSlot = 191			--zero based -> 31 means 32 doublechests
chestHeight = 8
idleHeight = 9
idleDirection = 1
systemKey = "ItemSystem_001"
requestPort = 65530
broadcastPort = 65535

--static variables
fetchQueue = {}		--{name="minecraft:cobblestone", count=3574}
items = {}			--{name="", alias="", stackSize=0, color=8, slots={24, 26}		#alias < 12
slots = {}			-- [35] = 642

--constants
nameFurnace = "minecraft:furnace"
nameLapis = "minecraft:lapis_block"
chestSize = 6 * 9

shell.run("/lib/Modules.lua")
shell.run("/lib/ItemFunctions.lua")
shell.run("/lib/Display.lua")
shell.run("/lib/ModemMessage.lua")
shell.run("/lib/SortItems.lua")
shell.run("/lib/StoreItems.lua")
shell.run("/lib/Move.lua")
shell.run("/lib/FileFunctions.lua")
shell.run("/lib/FetchItems.lua")

loadItems()

shell.run("/lib/Homing.lua")

--Debug
--for i=1, 153 do table.insert(items, {name = "name" .. i, alias = "TestItem" .. i, stackSize = 64, color = math.pow(2, math.random(1, 15)), slots={[i]=math.random(1, 3600)}}) end

sortItems()

--Receiving events

function eventListen()
	while true do
		local timerId = os.startTimer(0.25)
		
		local eventData = {os.pullEvent()}
		
		if eventData[1] ~= "timer" then
			os.cancelTimer(timerId)
		end
		
		if showMenu and eventData[1] == "mouse_scroll" then
			if not displayMenu then
				displayStartLine = displayStartLine + eventData[2] * 3
				printDisplay()
			end
		elseif showMenu and eventData[1] == "mouse_click" then
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
		elseif eventData[1] == "key" then
			local scancode = eventData[2]
			
			if scancode == keys.backspace and showMenu and displayMenu then
				if displayMenu.count:len() > 0 then
					displayMenu.count = displayMenu.count:sub(1, displayMenu.count:len() - 1)
					updateRequestMenu()
				else
					displayMenu = nil
					printDisplay()
				end
			elseif scancode == keys.enter and showMenu and displayMenu then
				executeMenuRequest()				
			elseif scancode == keys.f4 then
				term.setBackgroundColor(colors.black)
				term.clear()
				error("aborted")
			end
		elseif showMenu and eventData[1] == "char" and displayMenu then
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
		
			local replyChannel, message = eventData[4], eventData[5]
			
			local ok, reply = pcall(processModemMessage, replyChannel, message)
			
			wireless.transmit(replyChannel, requestPort, reply)
			
		end
	end
end

function mainLoop()
	while true do
		fetchItems()
		
		storeItems()

		coroutine.yield()
	end
end

printDisplay()
parallel.waitForAny(eventListen, mainLoop)

error("Either main loop or wireless listen yielded fatal error")