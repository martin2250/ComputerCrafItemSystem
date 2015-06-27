function processModemMessage(replyChannel, message)
	if message.key == systemKey then
		message.command = message.command:lower()
		if message.command == "get" then
			local args = message.args
			local fetchBuffer = {}
			
			while #args > 0 do
				local name = table.remove(args, 1)
				local item = getItem(name)
				
				if not item then
					return "unknown name / alias " .. name
				end
				
				local count = 1
				
				if #args > 0 then
					local isnumber = true
					
					for i=1, #args[1] do
						local character = args[1]:sub(i, i)
						if not (requestCountValidCharsNum[character] or requestCountValidCharsOperator[character]) then
							isnumber = false
							break;
						end
					end
					
					if isnumber then								
						local ok, result = pcall(loadstring("return " .. args[1]))
						
						if ok then
							count = result
							table.remove(args, 1)
						end
					end
				end
				
				count = math.floor(count)
				
				if getItemStock(item) < count then
					return "not enough stock of " .. item.alias
				end
				
				table.insert(fetchBuffer, {name=item.name, count=count})
			end
			
			for i=1, #fetchBuffer do
				addToFetchQueue(fetchBuffer[i].name, fetchBuffer[i].count)
			end
			
			return "OK"
		elseif message.command == "addtype" then
			local name, alias, stackSize, color = unpack(message.args)
			
			stackSize = tonumber(stackSize)
			color = tonumber(color)
			
			if name and alias and stackSize and color then
				if getItem(name) then
					return "Item exists"
				end
				
				if getItem(alias) then
					return "Alias exists"
				end
				
				if alias:len() > 11 then
					return "Alias too long (11 chars max)"
				end
				
				if alias:len() < 3 then
					return "Alias must have 3 characters or more"
				end
				
				if stackSize > 64 or stackSize < 0 or stackSize % 1 ~= 0 then
					return "invalid stackSize"
				end
				
				if color < 0 or color % 1 ~= 0 then
					return "invalid color"
				end
				
				table.insert(items, {name=name, alias=alias, stackSize=stackSize, color=color, slots={}})
				saveItems()
				printDisplay()				
				return "OK"
			else
				return "please supply name, alias stackSize and color"
			end
		elseif message.command == "removetype" then
			local name = message.args[1]
			if not name then
				return "please supply name"
			end
			
			local item, itemIndex = getItem(name)
			
			if not item then
				return "Item does not exist"
			end
			
			if getItemStock(item) > 0 then
				return "Item still in stock"
			end
			
			table.remove(items, itemIndex)
			saveItems()
			printDisplay()
			return "OK"
		elseif message.command == "list" then
			return {items=items, slots=slots}
		end
	end
end