--[[
	层-操纵杆和技能
--]]

local OperationLayer = class("OperationLayer", function()
	return display.newLayer()
end)

OperationLayer.ctor = function(self)
	self.joyStick = JoyStickButton:new()
	self.joyStick:pos(JoyStickButtonConst.WIDTH / 2, JoyStickButtonConst.HEIGHT / 2)
	self:addChild(self.joyStick)
end

OperationLayer.setControlNode = function(self, controlNode)
	self.joyStick:setControlNode(controlNode)
end

return OperationLayer