displayStartLine = 0
displayMenu = nil		--{name="", count="", stock=0}
termWidth, termHeight = term.getSize()
showMenu = true

defaultBackgroundColor = colors.black
menuBackgroundColor = colors.gray
requestCountValidCharsNum = {["0"]=true, ["1"]=true, ["2"]=true, ["3"]=true, ["4"]=true, ["5"]=true, ["6"]=true, ["7"]=true, ["8"]=true, ["9"]=true}
requestCountValidCharsOperator = {["*"]=true, ["/"]=true, ["+"]=true, ["-"]=true, ["("]=true, [")"]=true}

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
	if not showMenu then
		return
	end
	
	sortItems()

	local lineCount = math.ceil(#items / 2)
	
	if displayStartLine > (math.ceil(#items / 2) - termHeight) then
		displayStartLine = math.ceil(#items / 2) - termHeight
	end
	
	if displayStartLine < 0 then
		displayStartLine = 0
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
	local func = loadstring("return " .. displayMenu.count)
	local ok, result = pcall(func)
	
	if not ok then
		updateRequestMenu(result)
	else
		result = math.floor(result)
		
		if result > displayMenu.stock then
			updateRequestMenu("Not enough stock")
		elseif result <= 0 then
			updateRequestMenu("Amount < 1")
		else
			addToFetchQueue(displayMenu.name, result)
			displayMenu = nil
			printDisplay()
		end
	end
end

function replaceDisplay(message)
	showMenu = false
	displayMenu = nil
	term.setBackgroundColor(colors.black)
	term.clear()
	
	term.setCursorPos((termWidth / 2)- (message:len() / 2), termHeight / 2)
	term.write(message)	
end

function resumeDisplay()
	showMenu = true
	printDisplay()
end