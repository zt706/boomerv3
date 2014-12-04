local MainScene = class("MainScene", function()
	return display.newScene("MainScene")
end)

function MainScene:ctor()
	DebugDrawer.initDefaultMap()
	
	-- local testChar = Character.new("guanyu")
	-- local point1_1 = Map.getPosByRowAndCol(2, 2)
	-- testChar:setPosition(point1_1.x, point1_1.y)
	-- self:addChild(testChar, 100)

	local startPoint = {row = 2, col = 2}
	DebugDrawer.startPoint = startPoint
	DebugDrawer.drawMap({callback = function(row, col, callback)
		-- testChar:move(startPoint, {row = row, col = col}, {onComplete = callback})

		-- if DebugDrawer.findPath then
		-- 	startPoint = {row = row, col = col}
		-- 	DebugDrawer.startPoint = startPoint
		-- end
	end}):addTo(self)

	local player = Player.new("guanyu")
	local point5_7 = Map.getPosByRowAndCol(4, 7)
	player:setPosition(point5_7.x, point5_7.y)
	player:move("left")
	self:addChild(player)

	local joyStick = JoyStickButton:new()
	joyStick:setPosition(JoyStickButtonConst.WIDTH / 2, JoyStickButtonConst.HEIGHT / 2)
	joyStick:setControlNode(player)
	-- joyStick:swallowEnabled(false) -- 测试，允许地图层直接响应
	self:addChild(joyStick)

	local skillButton = SkillButton.new("mine", function()
		-- self:testEffect()
	end)
	skillButton:setPosition(display.right - 100, display.bottom + 100)
	self:addChild(skillButton)
end

function MainScene:testEffect()
	local enterEffect = DividedEffect.new()
	self:addChild(enterEffect)

	enterEffect:alginToDivided()
	enterEffect:gotoConverged({onComplete = function()
		enterEffect:gotoDivided()
	end})
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
