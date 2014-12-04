--[[
	日志输出控制
--]]

-- 这里用语取代默认的print打印
-- 一律使用以下打印方式，方便输出辨认
local Logger = {}
Logger.DEBUG	= 1
Logger.INFO		= 2
Logger.WARN		= 3
Logger.ERROR	= 4
Logger.FATAL	= 5

Logger.PrefixInfo = {
	"[LOGGER_DEBUG]:",
	"[LOGGER_INFO]:",
	"[LOGGER_WARN]:",
	"[LOGGER_ERROR]:",
	"[LOGGER_FATAL]:"
}

Logger.old_print = print
--!! 这里由于我为了方便，引入了cocos2dx的代码，导致了这里直接引用到了那里去了，只要将那个移除，print在这里是不会影响到LUA ERROR的
-- print = function() end

-- 默认打印日志级别为debug，即所有信息输出
if not LOG_LEVEL then
	LOG_LEVEL = Logger.DEBUG
end

-- 默认打印日志颜色开启
if not LOG_COLOR_ON then
	LOG_COLOR_ON = 1
end

local echo = function(logLevel, ...)
	if logLevel < LOG_LEVEL then
		return
	end

	Logger.old_print(Logger.PrefixInfo[logLevel], ...)
end

--[[
	COLOR 命令是设置默认控制台前景和背景颜色，后面跟的是颜色属性。
	其中：	0 = 黑色			8 = 灰色
			1 = 蓝色			9 = 淡蓝色
			2 = 绿色			A = 淡绿色
			3 = 湖蓝色		B = 淡浅绿色
			4 = 红色			C = 淡红色
			5 = 紫色			D = 淡紫色
			6 = 黄色			E = 淡黄色
			7 = 白色			F = 亮白色
	所以color f1的意思就是将默认控制台前景色设置为亮白色，背景色设置为蓝色。
--]]
local colorLogLevel = {
	[Logger.DEBUG]	= {mac = 0, windows = "71"}, -- 白底蓝字
	[Logger.INFO]	= {mac = 0, windows = "70"}, -- 白底黑字
	[Logger.WARN]	= {mac = 0, windows = "76"}, -- 白底黄字
	[Logger.ERROR]	= {mac = 0, windows = "7A"}, -- 白底绿字
	[Logger.FATAL]	= {mac = 0, windows = "74"}, -- 白底红字
}
local echoWithColorBegin = function(logLevel)
	if not LOG_COLOR_ON then
		return
	end

	if device.platform == "mac" then
		-- mac 目前无法控制控制台颜色显示
		-- echo -e "\033[36m 天蓝字 \033[0m"
	elseif device.platform == "windows" then
		-- 验证不行
		-- os.execute("color " .. colorLogLevel[logLevel].windows)
	end
end

local echoWithColorEnd = function(logLevel)
	if not LOG_COLOR_ON then
		return
	end

	if device.platform == "mac" then
		-- mac 目前无法控制控制台颜色显示
	elseif device.platform == "windows" then
		-- 验证不行
		-- 还原控制台输出为白底黑字
		-- os.execute("color 70")
	end
end

Logger.fatal = function(...)
	echoWithColorBegin(Logger.FATAL)
	echo(Logger.FATAL, ...)
	echoWithColorEnd(Logger.FATAL)
end

Logger.error = function(...)
	echoWithColorBegin(Logger.ERROR)
	echo(Logger.ERROR, ...)
	echoWithColorEnd(Logger.ERROR)
end

Logger.warn = function(...)
	echoWithColorBegin(Logger.WARN)
	echo(Logger.WARN, ...)
	echoWithColorEnd(Logger.WARN)
end

Logger.info = function(...)
	echoWithColorBegin(Logger.INFO)
	echo(Logger.INFO, ...)
	echoWithColorEnd(Logger.INFO)
end

Logger.debug = function(...)
	echoWithColorBegin(Logger.DEBUG)
	echo(Logger.DEBUG, ...)
	echoWithColorEnd(Logger.DEBUG)
end

cclog = Logger.info

return Logger