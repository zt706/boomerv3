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

local BACK_COLORS = {}
local FRONT_COLORS = {}

if device.platform == "windows" then
	BACK_COLORS = {
		BLACK = 8,
		BLUE = 16,
		GREEN = 32,
		RED = 64,
		WHITE = 112,
	}

	FRONT_COLORS = {
		BLACK = 0,
		BLUE = 1,
		GREEN = 2,
		CYAN = 3,
		RED = 4,
		YELLOW = 6,
		WHITE = 7,
	}
end

local colorLogLevel = {
	[Logger.DEBUG]	= {front = FRONT_COLORS.BLUE, back = BACK_COLORS.BLACK}, -- 黑底蓝字
	[Logger.INFO]	= {front = FRONT_COLORS.CYAN, back = BACK_COLORS.BLACK}, -- 黑底青字
	[Logger.WARN]	= {front = FRONT_COLORS.YELLOW, back = BACK_COLORS.BLACK}, -- 黑底黄字
	[Logger.ERROR]	= {front = FRONT_COLORS.GREEN, back = BACK_COLORS.BLACK}, -- 黑底绿字
	[Logger.FATAL]	= {front = FRONT_COLORS.RED, back = BACK_COLORS.BLACK}, -- 黑底红字
}

local echoWithColorBegin = function(logLevel)
	if not LOG_COLOR_ON then
		return
	end

	if device.platform == "mac" then
		-- mac 目前无法控制控制台颜色显示
	elseif device.platform == "windows" then
		-- 指定传入字体颜色为front，背景色为back
		zw.ZWUtils:setConsoleColor(colorLogLevel[logLevel].front, colorLogLevel[logLevel].back)
	end
end

local echoWithColorEnd = function(logLevel)
	if not LOG_COLOR_ON then
		return
	end

	if device.platform == "mac" then
		-- mac 目前无法控制控制台颜色显示
	elseif device.platform == "windows" then
		-- 还原控制台输出为黑底白字
		zw.ZWUtils:setConsoleColor(FRONT_COLORS.WHITE, BACK_COLORS.BLACK)
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