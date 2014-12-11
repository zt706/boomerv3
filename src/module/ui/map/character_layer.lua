--[[
	层-角色、敌人和炸弹特效
--]]

local CharacterLayer = class("CharacterLayer", function()
	return display.newLayer()
end)

CharacterLayer.ctor = function(self)
	local defaultPos = Map.getPosByRowAndCol(2, 2)

	self.player = Player.new("guanyu")
	self.player:pos(defaultPos.x, defaultPos.y)
	self.player:move("left")
	self:addChild(self.player)
end

CharacterLayer.getPlayer = function(self)
	return self.player
end

return CharacterLayer