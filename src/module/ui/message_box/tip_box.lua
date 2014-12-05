--[[
	提示框
--]]

local schedule = require("framework.scheduler")

local labelList = {}
local container = nil

local release = function(scene)
	labelList = {}

	if container then
		container:stopAllActions()
		container:removeFromParent()
		container = nil
	end
end

EventMgr.registerEvent(EventConst.SCENE_EXIT, release, EventConst.PRIO_LOW)

local remove = function()
	if #labelList == 0 then
		return
	end

	local label = table.remove(labelList, 1)
	label:removeFromParent()

	if #labelList == 0 then
		container:removeFromParent()
		container = nil
		return 
	end

	-- 还剩下一个label，延迟0.5秒再清楚
	local actions = transition.sequence({
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			table.remove(labelList, 1)

			container:removeFromParent()
			container = nil
		end)
	})

	container:runAction(actions)
end

local checkCount = function()
	if #labelList < 2 then
		return
	end

	local label = table.remove(labelList, 1)
	label:removeFromParent()
end

local deal = function()
	if table.nums(labelList) == 0 then
		return
	end

	transition.fadeOut(labelList[1], {time = 1, onComplete = remove})
end

local repos = function()
	if #labelList == 1 then
		labelList[1]:setPosition(0, 15)
		labelList[1]:runAction(cc.MoveBy:create(1, cc.p(0, 0)))
		return
	end

	-- 一次最多就处理2个label
	labelList[1]:runAction(cc.MoveBy:create(0.3, cc.p(0, 25)))
	labelList[2]:runAction(cc.MoveBy:create(0.2, cc.p(0, 15)))
end

showTip = function(text, color)
	if string.len(text) > 100 then
		Logger.warn("TipBox: 提示文字太多！！！")
		return
	end

	Logger.info("showTip: " .. text)

	if not container then
		local res = "module/ui/message_box/tip_box.png"
		local bgLeft = display.newSprite(res)
		local bgRight = display.newSprite(res)
		bgRight:setScaleX(-1)

		display.align(bgLeft, display.LEFT_BOTTOM)
		display.align(bgRight, display.LEFT_BOTTOM)

		local bgSize = bgLeft:getContentSize()
		bgLeft:setPosition(-bgSize.width, 0)
		bgRight:setPosition(bgSize.width, 0)

		container = display.newNode()
		container:addChild(bgLeft)
		container:addChild(bgRight)
		container:setPosition(display.cx, display.height - 100)

		local scene = display.getRunningScene()
		scene:addChild(container)
	end
	container:stopAllActions()

	-- 保证最多只有2个label显示
	checkCount()

	local label = display.newTTFLabel({
		text = text,
		color = color or cc.c3b(246, 246, 246),
		size = 20,
		align = cc.TEXT_ALIGN_CENTER,
	})
	
	table.insert(labelList, label)
	label:performWithDelay(deal, 1)

	container:addChild(label)

	-- 重定向label的位置
	repos()
end

return {showTip = showTip}