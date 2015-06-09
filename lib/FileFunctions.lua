local itemsFilePath = "items.ll"

function loadItems()
	local file = fs.open(itemsFilePath, "r")
	local content = file.readAll()
	file.close()
	data = textutils.unserialize(content)
	items = data.items
	slots = data.slots
end

function saveItems()
	local file = fs.open(itemsFilePath, "w")
	file.write(textutils.serialize({items = items, slots = slots}))
	file.close()
end