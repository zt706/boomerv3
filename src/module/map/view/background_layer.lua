--[[
	层-底图背景
--]]

local BackgroundLayer = class("BackgroundLayer", function()
	return display.newLayer()
end)

BackgroundLayer.ctor = function(self)
	local background = display.newSprite(Map.getBackgroundRes())
	background:pos(display.cx, display.cy)

	local size = background:getContentSize()
	local xScale = display.width / size.width
	local yScale = display.height / size.height
	background:setScale(xScale, yScale)

	self:addChild(background)
end

return BackgroundLayer