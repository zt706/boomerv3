--[[
	事件管理器
	
eg：
	updateHp = function(param1, param2)
		print("update hp", param1, param2)
	end

	updateMp = function(param1, param2)
		print("update mp", param1, param2)
	end

	EventMgr.registerEvent("update", updateHp, eventConst.PRIO_MIDDLE, 1, 100)
	EventMgr.registerEvent("update", updateMp, eventConst.PRIO_MIDDLE)

	EventMgr.triggerEvent("update")
	EventMgr.triggerEvent("update", 20)
--]]

local EventMgr = {}

EventMgr.registerEvent = function(eventType, callback, priority, ...)
	if not eventType then
		Logger.error("事件类型为空！！！")
	end

	if type(callback) ~= "function" then
		Logger.error("没有对应的事件触发回调处理！！！")
		return
	end

	local eventCallback = {
		callback = callback,
		priority = priority or EventConst.PRIO_MIDDLE,
		params = {...},
	}

	EventMgr.events = EventMgr.events or {}
	EventMgr.events[eventType] = EventMgr.events[eventType] or {}
	
	EventMgr.events[eventType][#EventMgr.events[eventType] + 1] = eventCallback
	table.sort(EventMgr.events[eventType], function(left, right)
		return left.priority > right.priority
	end)
end

EventMgr.unRegisterEvent = function(eventType, callback)
	EventMgr.events = EventMgr.events or {}
	local eventCallbacks = EventMgr.events[eventType]
	if not eventCallbacks or #eventCallbacks == 0 then
		Logger.warn(string.format("事件：没有对应的回调函数", eventType))
		return
	end

	for k, v in pairs(eventCallbacks) do
		if v.callback == callback then
			table.remove(eventCallbacks, k)
			return
		end
	end
end

EventMgr.triggerEvent = function(eventType, ...)
	-- clone，防止回调函数时，调用unRegisterEvent，把数据清空了
	EventMgr.events = EventMgr.events or {}
	local eventCallbacks = clone(EventMgr.events[eventType])
	if not eventCallbacks or #eventCallbacks == 0 then
		Logger.warn(string.format("事件：没有对应的回调函数", eventType))
		return
	end

	for k, v in pairs(eventCallbacks) do
		if EventMgr.hasRegisterEvent(eventType, v.callback) then
			if #{...} == 0 then
				v.callback(unpack(v.params))
			else
				for _, param in ipairs({...}) do
					table.insert(v.params, param)
				end

				v.callback(unpack(v.params))
			end
		end
	end
end

EventMgr.hasRegisterEvent = function(eventType, callback)
	EventMgr.events = EventMgr.events or {}
	local eventCallbacks = EventMgr.events[eventType]
	if not eventCallbacks or #eventCallbacks == 0 then
		return false
	end

	for k, v in pairs(eventCallbacks) do
		if v.callback == callback then
			return true
		end
	end

	return false
end

EventMgr.clearEvent = function(eventType)
	Logger.debug("\n\n\n clearEvent:", eventType)

	EventMgr.events = EventMgr.events or {}
	local eventCallbacks = EventMgr.events[eventType]
	if eventCallbacks then
		EventMgr.events[eventType] = {}
	end
end

EventMgr.clearEvents = function()
	EventMgr.events = {}
end

return EventMgr