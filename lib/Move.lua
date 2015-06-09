x, y, aisle = 0, 0, 0

function gotoY(dY)
	local moveFunc = turtle.up
	local increment = 1

	if y > dY then
		moveFunc = turtle.down
		increment = -1
	end

	while y ~= dY do
		if moveFunc() then
			y = y + increment
		else
			sleep(0.1)
		end
	end
end

function gotoX(dX)
	if x == dX then
		return
	end
	
	turnTo(aisle)
	
	local moveFunc = turtle.forward
	local increment = 1

	if x > dX then
		moveFunc = turtle.back
		increment = -1
	end

	while x ~= dX do
		if moveFunc() then
			x = x + increment
		else
			sleep(0.1)
		end
	end
end

function moveTo(dAisle, dX, dY, dSide)
	if dX ~= 0 and dY > (chestHeight - 1) then
		error("Y is too high, result in crash")
	end
	
	if dY < chestHeight then
		gotoY(dY)
	end
	
	while dAisle < 0 do
		dAisle = dAisle + 4
	end
	
	dAisle = dAisle % 4
	
	if aisle ~= dAisle then
		gotoX(0)
		turnTo(dAisle)
		aisle = dAisle	
	end
	
	gotoX(dX)
	gotoY(dY)
	
	turnTo(aisle + dSide)
end