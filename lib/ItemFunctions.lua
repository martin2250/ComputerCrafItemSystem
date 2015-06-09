--Item functions

function getItemStock(item)
	if not item then return end

	local stock = 0

	for i, slot in pairs(item.slots) do
		stock = stock + slots[slot]
	end
	return stock
end

function getFirstFreeSlot()
	for i=0, maxSlot do
		if not slots[i] then
			return i
		end
	end
end

function getItem(name)
	for i=1, #items do
		if items[i].name == name or items[i].alias:lower() == name:lower() then
			return items[i], i
		end
	end
end

function addToFetchQueue(name, count)
	for i=1, #fetchQueue do
		if fetchQueue[i].name == name then
			fetchQueue[i].count = fetchQueue[i].count + count
			return
		end
	end
	table.insert(fetchQueue, {name = name, count = count})
end

function getSlotPos(slot)
	local pos = {}
	
	pos.side = (slot % 2) * 2 - 1
	slot = math.floor(slot / 2)
	
	pos.height = slot % chestHeight
	slot = math.floor(slot / chestHeight)
	
	pos.aisle = slot % 4
	
	pos.depth = math.floor(slot / 4) + 3
	
	return pos
end

function getRemainingCapacity(slot, stackSize)
	return chestSize * stackSize - slots[slot]
end

function emptyInventory()
	for i=1, 16 do
		if turtle.getItemCount(i) > 0 then
			turnTo(idleDirection + 2)
			turtle.select(i)
			turtle.drop()
		end
	end
	turtle.select(1)
	turnTo(idleDirection)
end