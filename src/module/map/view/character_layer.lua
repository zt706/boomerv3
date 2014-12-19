--[[
	层-角色、敌人和炸弹特效
--]]

local CharacterLayer = class("CharacterLayer", function()
	return display.newLayer()
end)

CharacterLayer.ctor = function(self)
	local defaultPos = Map.getPosByRowAndCol(5, 8)

	self.player = Player.new("guanyu")
	self.player:pos(defaultPos.x, defaultPos.y)
	self.player:move("left")
	self:addChild(self.player)

	self:addEnemy()

	-- 注册炸弹事件，这里先全清一边ADD_MINE事件
	EventMgr.registerEvent(EventConst.ADD_MINE, handler(self, self.addMine))
	EventMgr.registerEvent(EventConst.MINE_BOOM, handler(self, self.mineBoom))
end

CharacterLayer.addEnemy = function(self, row, col)
	row = row or 8
	col = col or 2

	local pos = Map.getPosByRowAndCol(row, col)
	local enemy = BasicEnemy.new("enemy1")
	enemy:pos(pos.x, pos.y)
	enemy:stand()
	self:addChild(enemy)
end

CharacterLayer.addMine = function(self)
	local row, col = Map.getRowAndColByPos(self.player:getPosition())
	local pos = Map.getPosByRowAndCol(row, col)
	
	local mine = BasicMine.new("mine")
	mine:pos(pos.x, pos.y)
	mine:boom() -- 这里炸弹会根据自己的情况进行爆炸等操作
	self:addChild(mine)
end

CharacterLayer.mineBoom = function(self, blocks)
	-- 获取所有的角色，敌人和主角
	--!! 目前只有主角就简单处理主角
	local row, col = Map.getRowAndColByPos(self.player:getPosition())
	for _, v in pairs(blocks) do
		if v.row == row and v.col == col then
			self.player:die()
			Logger.info("你挂了啊～～～～～～～～～")
			break
		end
	end
end

CharacterLayer.getPlayer = function(self)
	return self.player
end

return CharacterLayer