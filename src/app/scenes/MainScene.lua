local MainScene = class("MainScene", function()
	return display.newScene("MainScene")
end)

function MainScene:ctor()
	-- self:testDebugMap()
	self:testSkill()
	-- self:initMapLayer()
end

function MainScene:initMapLayer()
	local mapLayer = MapLayer.new("2")
	self:addChild(mapLayer)
end

function MainScene:testDebugMap()
	DebugDrawer.initDefaultMap()
	
	local testChar = Character.new("guanyu")
	local point1_1 = Map.getPosByRowAndCol(2, 2)
	testChar:setPosition(point1_1.x, point1_1.y)
	self:addChild(testChar, 100)

	local startPoint = {row = 2, col = 2}
	DebugDrawer.startPoint = startPoint
	DebugDrawer.drawMap({callback = function(row, col, callback)
		testChar:move(startPoint, {row = row, col = col}, {onComplete = callback})

		if DebugDrawer.findPath then
			startPoint = {row = row, col = col}
			DebugDrawer.startPoint = startPoint
		end
	end}):addTo(self)
end

function MainScene:testSkill()
	display.newColorLayer(cc.c4b(156, 255, 0, 127)):addTo(self)

	local skillButton = SkillButton.new("mine", function()
		TipBox.showTip("哈哈哈哈哈")
		
		local enterEffect = DividedEffect.new()
		self:addChild(enterEffect)

		enterEffect:alginToDivided()
		enterEffect:gotoConverged({onComplete = function()
			enterEffect:gotoDivided()
		end})
	end)
	skillButton:setPosition(display.right - 100, display.bottom + 100)
	self:addChild(skillButton)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
