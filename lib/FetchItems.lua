function getTurtleFreeSlots()
	local count = 0
	for i=1, 16 do
		if turtle.getItemCount(i) == 0 then
			count = count + 1
		end
	end
	return count
end


function fetchItems()
	if #fetchQueue == 0 then
		return
	end
	
	replaceDisplay("Fetching Items")
	turtle.select(1)
	while #fetchQueue > 0 and getTurtleFreeSlots() > 0 do
		local name = fetchQueue[1].name
		local item = getItem(name)
		
		if item then
			table.sort(item.slots)
			local slotNum = item.slots[#item.slots]
			local amount = math.min(fetchQueue[1].count, item.stackSize, slots[slotNum])
			
			if amount > 0 then
				local pos = getSlotPos(slotNum)
			
				moveTo(pos.aisle, pos.depth, pos.height, pos.side)
				
				turtle.suck(amount)
				slots[slotNum] = slots[slotNum] - amount
				
				if slots[slotNum] == 0 then
					slots[slotNum] = nil
					table.remove(item.slots, #item.slots)
				end
				
				saveItems()	

				fetchQueue[1].count = fetchQueue[1].count - amount
				
				if fetchQueue[1].count == 0 then
					table.remove(fetchQueue, 1)
				end				
			else
				table.remove(fetchQueue, 1)
			end
		else
			table.remove(fetchQueue, 1)
		end
	end
	
	
	moveTo(idleDirection, 0, idleHeight, 0)
	emptyInventory()
	resumeDisplay()
end