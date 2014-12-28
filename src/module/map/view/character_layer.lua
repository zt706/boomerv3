--[[
	层-角色、敌人和炸弹特效
--]]

local scheduler = require("framework.scheduler")

local CharacterLayer = class("CharacterLayer", function()
	return display.newLayer()
end)

CharacterLayer.ctor = function(self)
	self:addPlayer()
	self:addEnemy()

	-- 注册添加炸弹和炸弹爆炸事件
	EventMgr.registerEvent(EventConst.ADD_MINE, handler(self, self.addMine))
	EventMgr.registerEvent(EventConst.MINE_BOOM, handler(self, self.mineBoom))

	-- 添加一个每帧计时器，用来记录场景上角色，敌人和炸弹之间的碰撞关系
	self.timeHandler = scheduler.scheduleUpdateGlobal(function()
		-- 1、敌人与player是否碰撞
		for _, enemy in pairs(self.enemys) do
			local enemyBox = enemy:getBoundingBox()
			local playerBox = self.player:getBoundingBox()
			if cc.rectIntersectsRect(enemyBox, playerBox) then
				self.player:die()
				Logger.info("你挂了啊，被敌人碾压而亡～～～～～～～～～")
			end
		end

		-- 2、敌人是否碰到炸弹，碰到炸弹，需要掉头
		if self.mine then
			for _, enemy in pairs(self.enemys) do
				local enemyBox = enemy:getBoundingBox()
				local mineBox = self.mine:getBoundingBox()
				if enemy:getMovingOpposite() and not cc.rectIntersectsRect(enemyBox, mineBox) then
					enemy:resetMovingOpposite()
				elseif enemy:shouldBeOpposite(self.mine) and cc.rectIntersectsRect(enemyBox, mineBox) then
					--!! 并不完整，应该是看方向的，如果是在敌人后面放的雷，那么就不应该掉头
					--!! 还需要判断雷的块是在炸弹前面还是后面
					enemy:moveOpposite()
					Logger.info("敌人掉头～～～～～～～～～")
				end
			end
		end
	end)
end

CharacterLayer.addPlayer = function(self, row, col)
	row = row or 8
	col = col or 3

	local defaultPos = Map.getPosByRowAndCol(row, col)
	self.player = Player.new("guanyu")
	self.player:pos(defaultPos.x, defaultPos.y)
	self.player:move("left")
	self:addChild(self.player)
end

CharacterLayer.addEnemy = function(self, row, col)
	row = row or 8
	col = col or 2

	local pos = Map.getPosByRowAndCol(row, col)
	local enemy = BasicEnemy.new("enemy1")
	enemy:pos(pos.x, pos.y)
	enemy:start()
	self:addChild(enemy)

	-- 添加入敌人表
	self.enemys = self.enemys or {}
	self.enemys[#self.enemys + 1] = enemy
end

CharacterLayer.addMine = function(self)
	local row, col = Map.getRowAndColByPos(self.player:getPosition())
	local pos = Map.getPosByRowAndCol(row, col)
	
	local mine = BasicMine.new("mine")
	mine:pos(pos.x, pos.y)
	mine:boom() -- 这里炸弹会根据自己的情况进行爆炸等操作
	self:addChild(mine)

	self.mine = mine
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

	self.mine = nil
end

CharacterLayer.getPlayer = function(self)
	return self.player
end

return CharacterLayer