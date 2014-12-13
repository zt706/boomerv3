--[[
	层-底图背景
	层-阻挡和行走方块（炸弹特效不可以穿越）
	层-障碍物（可以被炸毁）
	层-角色、敌人和炸弹特效
	层-操纵杆和技能
--]]

local MapLayer = class("MapLayer", function()
	return display.newLayer()
end)

MapLayer.ctor = function(self, id)
	self.mapId = id or "1"
	
	-- 初始化地图Model
	Map.init(self.mapId)

	-- 背景层
	local backgroundLayer = BackgroundLayer.new(self.mapId)
	self:addChild(backgroundLayer)

	-- 阻挡层
	local blockLayer = BlockLayer.new(self.mapId)
	self:addChild(blockLayer)

	-- 障碍物层
	local obstacleLayer = ObstacleLayer.new(self.mapId)
	self:addChild(obstacleLayer)

	-- 角色层
	local characterLayer = CharacterLayer.new(self.mapId)
	self:addChild(characterLayer)

	-- 操纵控制层
	local operationLayer = OperationLayer.new(self.mapId)
	self:addChild(operationLayer)

	operationLayer:setControlNode(characterLayer:getPlayer())
end

return MapLayer