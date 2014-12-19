--[[
	敌人类
--]]

local BasicEnemy = class("BasicEnemy", Player)

BasicEnemy.ctor = function(self, charId)
	BasicEnemy.super.ctor(self, charId)
end
BasicEnemy.move = function(self, dir)
end

BasicEnemy.attack = function(self, params)
end

return BasicEnemy