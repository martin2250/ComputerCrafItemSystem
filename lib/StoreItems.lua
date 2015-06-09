function storeItems()
	if redstone.getInput("front") then
		return
	end
	
	emptyInventory()
	
	turnTo(idleDirection)
	turtle.select(1)

	local turtleSlot = 0
	local storeList = {}

	while turtle.suck() do
		turtleSlot = turtleSlot + 1
		local data = turtle.getItemDetail(turtleSlot)

		if not getItem(getIdFromData(data))  then
			turnTo(idleDirection + 2)
			turtle.select(turtleSlot)
			turtle.drop()
			turtle.select(1)
			turnTo(idleDirection)
			turtleSlot = turtleSlot - 1
		else
			table.insert(storeList, {name=getIdFromData(data), turtleSlot=turtleSlot, count = data.count})
		end
	end
	
	if #storeList == 0 then
		return
	end
	
	table.sort(storeList, function(a, b) return a.name > b.name end)
	
	replaceDisplay("Storing Items")
	
	while #storeList > 0 do
		local item = getItem(storeList[1].name)
		
		table.sort(item.slots)
		
		local slotNum = nil
		
		for i=1, #item.slots do
			if getRemainingCapacity(item.slots[i], item.stackSize) > 0 then
				slotNum = item.slots[i]
				break
			end
		end
		
		if not slotNum then
			slotNum = getFirstFreeSlot()
			if slotNum then
				table.insert(item.slots, slotNum)
				slots[slotNum] = 0
			end
		end
		
		if slotNum then
			local pos = getSlotPos(slotNum)
			
			moveTo(pos.aisle, pos.depth, pos.height, pos.side)
			
			local storeAmount = math.min(turtle.getItemCount(storeList[1].turtleSlot), getRemainingCapacity(slotNum, item.stackSize))
			
			turtle.select(storeList[1].turtleSlot)
			
			turtle.drop(storeAmount)				
			
			slots[slotNum] = slots[slotNum] + storeAmount
			
			saveItems()
			
			storeList[1].count = storeList[1].count - storeAmount
			
			if storeList[1].count == 0 then
				table.remove(storeList, 1)
			end
			
		else
			table.remove(storeList, 1)
		end
	end
	
	moveTo(idleDirection, 0, idleHeight, 0)
	
	resumeDisplay()
end