--[[
	提示框
--]]

local schedule = require("framework.scheduler")

local TipBox = {}

TipBox.init = function()
	TipBox.list = {}
	TipBox.removeList = {}
	TipBox.handleList = {}
	TipBox.container = nil
	TipBox.containerWidth = 0
	TipBox.containerHeight = 0
end
TipBox.init()

TipBox.remove = function()
	if table.nums(removeList) then
		return
	end

	table.remove(TipBox.list, 1)

	for i, v in ipairs(TipBox.handleList) do
		if i == #TipBox.handleList and #TipBox.handleList ~= 1 then
			return
		end

		local handle = table.remove(TipBox.handleList, 1)
		schedule.unscheduleGlobal(handle)
	end

	for i, v in ipairs(TipBox.removeList) do
		if i == #TipBox.removeList and #TipBox.removeList ~= 1 then
			return
		end

		local item = table.remove(TipBox.removeList, 1)
		item:removeFromParentAndCleanup(true)
	end

	if #TipBox.removeList == 0 then
		table.remove(TipBox.handleList, 1)
		table.remove(TipBox.list, 1)

		TipBox.container:setVisible(false)
		TipBox.container:removeFromParentAndCleanup(true)
		TipBox.container = nil

		return
	end

	local actions = transition.sequence({
		CCDelayTime:create(0.5),
		CCCallFuncN:create(function()
			table.remove(TipBox.handleList, 1)
			table.remove(TipBox.list, 1)
			table.remove(TipBox.removeList, 1)

			TipBox.container:removeFromParentAndCleanup(true)
			TipBox.container = nil
		end)
	})

	TipBox.container:runAction(actions)
end

TipBox.checkCount = function()
	if table.nums(TipBox.list) < 2 then
		return
	end

	local handle = table.remove(TipBox.handleList, 1)
	schedule.unscheduleGlobal(handle)

	local item = table.remove(TipBox.list, 1)
	item:removeFromParentAndCleanup(true)
end

TipBox.deal = function()
	if table.nums(TipBox.list) == 0 then
		return
	end

	table.insert(TipBox.removeList, TipBox.list[1])

	local label = list[1]
	if not label.actFadeout then
		transition.fadeOut(label, {time = 1, onComplete = TipBox.remove})
		TipBox.actFadeout = true
	end
end

TipBox.repos = function()
	if #TipBox.list == 1 then
		TipBox.list[1]:setPosition(0, 15)
		TipBox.list[1]:runAction(CCMoveBy:create(1, cc.p(0, 0)))
	end

	for k, v in pairs(TipBox.list) do
		if k == 1 then
			v:runAction(CCMoveBy:create(0.3, cc.p(0, (#TipBox.list - k) * 15 + 10)))
		elseif k == 2 then
			v:runAction(CCMoveBy:create(0.2, cc.p(0, (#TipBox.list - k) * 15 + 15)))
		end
	end
end

TipBox.show = function(text, color)
	if string.len(text) > 100 then
		Logger.warn("TipBox: 提示文字太多！！！")
		return
	end

	Logger.info("TipBox: " .. text)

	TipBox.checkCount()

	if not color or #color ~= 3 then
		color = {246, 246, 246}
	end

	local label = ui.newTTFLabel({
		text = text,
		color = cc.c3(color[1], color[2], color[3]),
		size = 20,
		align = ui.TEXT_ALIGN_CENTER
	})

	if not TipBox.container then
		local res = "module/ui/message_box/tip_box.png"
		local bgLeft = display.newSprite(res)
		local bgRight = display.newSprite(res)
		bgRight:setScaleX(-1)

		display.align(bgLeft, display.LEFT_BOTTOM)
		display.align(bgRight, display.LEFT_BOTTOM)

		local bgSize = bgLeft:getContentSize()
		bgLeft:setPosition(-bgSize.width, 0)
		bgRight:setPosition(bgSize.width, 0)

		TipBox.container = display.newNode()
		TipBox.container:addChild(bgLeft)
		TipBox.container:addChild(bgRight)
		TipBox.container:setPosition(display.cx, display.height - 100)

		local scene = display.getRunningScene()
		scene:addChild(TipBox.container)
	end

	TipBox.container:stopAllActions()
	TipBox.container.label = label
	if label then
		table.insert(TipBox.list, TipBox.container.label)
		table.insert(TipBox.handleList, schedule.performWithDelayGlobal(deal, 1))
	end

	TipBox.container:addChild(label)

	TipBox.repos()
end

TipBox.release = function(scene)
	TipBox.list = {}
	TipBox.removeList = {}
	TipBox.handleList = {}

	if TipBox.container then
		TipBox.container:stopAllActions()
		TipBox.container = nil
	end
end

EventMgr.registerEvent(EventConst.SCENE_EXIT, TipBox.release, EventConst.PRIO_LOW)

return TipBox