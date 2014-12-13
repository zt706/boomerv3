--[[
	层-障碍物（可以被炸毁）
--]]

local ObstacleLayer = class("ObstacleLayer", function()
	return display.newLayer()
end)

ObstacleLayer.ctor = function()
	
end

return ObstacleLayer