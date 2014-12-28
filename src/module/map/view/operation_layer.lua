--[[
	层-操纵杆和技能
--]]

local OperationLayer = class("OperationLayer", function()
	return display.newLayer()
end)

OperationLayer.ctor = function(self)
	-- 添加操纵杆
	self.joyStick = JoyStickButton:new()
	self.joyStick:pos(JoyStickButtonConst.WIDTH / 2, JoyStickButtonConst.HEIGHT / 2)
	self:addChild(self.joyStick)

	-- 添加技能栏
	local skillButton = SkillButton.new("mine", function()
		EventMgr.triggerEvent(EventConst.ADD_MINE)
	end)
	skillButton:setPosition(display.right - 100, display.bottom + 100)
	self:addChild(skillButton)
	self.skillButton = skillButton

	EventMgr.registerEvent(EventConst.PLAYER_DIE, handler(self, self.skillDisabled))
end

OperationLayer.setControlNode = function(self, controlNode)
	self.joyStick:setControlNode(controlNode)
end

OperationLayer.skillDisabled = function(self)
	self.skillButton:setDisabled(true)
end

return OperationLayer