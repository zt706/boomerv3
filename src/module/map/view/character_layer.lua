--[[
	层-角色、敌人和炸弹特效
--]]

local scheduler = require("framework.scheduler")

local CharacterLayer = class("CharacterLayer", function()
	return display.newLayer()
end)

CharacterLayer.ctor = function(self)
	self:addPlayer(8, 7)
	self:addEnemy(4, 11)
	self:addEnemy(2, 6)
	self:addEnemy(3, 5)

	-- 注册添加炸弹和炸弹爆炸事件
	EventMgr.registerEvent(EventConst.ADD_MINE, handler(self, self.addMine))
	EventMgr.registerEvent(EventConst.MINE_BOOM, handler(self, self.mineBoom))
	EventMgr.registerEvent(EventConst.PLAYER_DIE, handler(self, self.playerDie))

	-- 添加一个每帧计时器，用来记录场景上角色，敌人和炸弹之间的碰撞关系
	self.timeHandler = scheduler.scheduleUpdateGlobal(handler(self, self.handleLogic))
end

-- 处理战斗逻辑，每帧循环处理
CharacterLayer.handleLogic = function(self)
	-- 1、敌人与player是否碰撞
	if self.player:isAlive() then
		for _, enemy in pairs(self.enemys) do
			local enemyBox = enemy:getBoundingBox()
			local playerBox = self.player:getBoundingBox()
			if enemy:isAlive() and cc.rectIntersectsRect(enemyBox, playerBox) then
				EventMgr.triggerEvent(EventConst.PLAYER_DIE)
			end
		end
	end

	-- 2、敌人是否碰到炸弹，碰到炸弹，需要掉头
	if self.mine then
		for _, enemy in pairs(self.enemys) do
			if enemy:isAlive() then
				local enemyBox = enemy:getBoundingBox()
				local mineBox = self.mine:getBoundingBox()
				if enemy:getMovingOpposite() and not cc.rectIntersectsRect(enemyBox, mineBox) then
					enemy:resetMovingOpposite()
				elseif enemy:shouldBeOpposite(self.mine) and cc.rectIntersectsRect(enemyBox, mineBox) then
					-- shouldBeOpposite判断炸弹是在前进的前面还是后面，在前面就掉头，后面则不掉头
					enemy:moveOpposite()
					Logger.info("敌人掉头～～～～～～～～～")
				end
			end
		end
	end

	-- 3、剩余敌人如果状态是站立，则寻找重新可走的地方
	for _, enemy in pairs(self.enemys) do
		if enemy:isAlive() then
			if enemy:isStand() and not enemy:hasMineAround(self.mine) then
				enemy:start()
			end
		end
	end
end

CharacterLayer.addPlayer = function(self, row, col)
	row = row or 8
	col = col or 2

	local defaultPos = Map.getPosByRowAndCol(row, col)
	self.player = Player.new("guanyu")
	self.player:pos(defaultPos.x, defaultPos.y)
	self.player:move("left")
	self:addChild(self.player)
end

CharacterLayer.addEnemy = function(self, row, col)
	row = row or 8
	col = col or 5

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
	-- 处理player与炸弹爆炸碰撞关系
	local playerRow, playerCol = Map.getRowAndColByPos(self.player:getPosition())
	if self.player:isAlive() then
		for _, v in pairs(blocks) do
			for _, block in pairs(v) do
				if block.row == playerRow and block.col == playerCol then
					EventMgr.triggerEvent(EventConst.PLAYER_DIE)
					break
				end
			end
		end
	end

	-- 处理敌人与炸弹爆炸碰撞关系
	for k, enemy in pairs(self.enemys) do
		if enemy:isAlive() then
			local enemyX, enemyY = enemy:getPosition()
			local enemyRow, enemyCol = Map.getRowAndColByPos(enemyX, enemyY)

			for _, v in pairs(blocks) do
				for _, block in pairs(v) do
					if block.row == enemyRow and block.col == enemyCol then
						enemy:die({onComplete = function()
							self:removeChild(enemy)
							self.enemys[k] = nil
						end})

						Logger.info("敌人挂了啊~~~~~~~~~~~~~~~~")
						break
					end
				end
			end
		end
	end

	self.mine = nil
end

CharacterLayer.playerDie = function(self)
	self.player:die()
	Logger.info("你挂了啊～～～～～～～～～")
end

CharacterLayer.getPlayer = function(self)
	return self.player
end

return CharacterLayer