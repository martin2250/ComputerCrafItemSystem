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
