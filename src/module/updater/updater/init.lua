--[[
	更新器初始化
--]]

package.loaded["updater.config"] = nil
require("updater.config")
require("lfs")

-- 回调方法
handler = function(obj, method)
	return function(...)
		return method(obj, ...)
	end
end

-- 类定义
class = function(classname, super)
	local superType = type(super)
	local cls

	if superType ~= "function" and superType ~= "table" then
		superType = nil
		super = nil
	end

	if superType == "function" or (super and super.__ctype == 1) then
		-- inherited from native C++ Object
		cls = {}

		if superType == "table" then
			-- copy fields from super
			for k,v in pairs(super) do cls[k] = v end
			cls.__create = super.__create
			cls.super    = super
		else
			cls.__create = super
			cls.ctor = function() end
		end

		cls.__cname = classname
		cls.__ctype = 1

		function cls.new(...)
			local instance = cls.__create(...)
			-- copy fields from class to native object
			for k,v in pairs(cls) do instance[k] = v end
			instance.class = cls
			instance:ctor(...)
			return instance
		end

	else
		-- inherited from Lua Object
		if super then
			cls = {}
			setmetatable(cls, {__index = super})
			cls.super = super
		else
			cls = {ctor = function() end}
		end

		cls.__cname = classname
		cls.__ctype = 2 -- lua
		cls.__index = cls

		function cls.new(...)
			local instance = setmetatable({}, cls)
			instance.class = cls
			instance:ctor(...)
			return instance
		end
	end

	return cls
end

local fileUtils = cc.FileUtils:getInstance()
local application = cc.Application:getInstance()
local target = application:getTargetPlatform()
local director = cc.Director:getInstance()
local winSize = director:getWinSize()

-- 检查是否初始化平台
local checkPlatformInitialized = function()
	local initialized = true

	if Launcher.platform == "android" then
		local javaMethodName = "checkPlatformInitialized"
		local javaParams = {}
		local javaMethodSig = "()Z"
		local ok, ret = Launcher.luaj.callStaticMethod(Launcher.javaClassName, javaMethodName, javaParams, javaMethodSig)
		if ok then initialized = ret end
	elseif Launcher.platform == "ios" then
		local ok, ret = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "checkPlatformInitialized")
		if ok then initialized = ret end
	end

	return initialized
end

-- 启动器
Launcher = {}

-- 服务器地址
Launcher.server = "http://127.0.0.1/testupdate/"

-- CDN地址
Launcher.cdn = "http://127.0.0.1/testupdate/"

-- 文件列表文件名
Launcher.flistFileName = "flist"

-- 更新器脚本打包文件名
Launcher.updaterPackage = "updater.zip"

-- 更新文件后缀
Launcher.updateFileSuffix = ".upd"

-- 操作系统
Launcher.platform = nil

-- 模式
Launcher.model = nil

PLATFORM_OS_WINDOWS = 0
PLATFORM_OS_MAC     = 2
PLATFORM_OS_ANDROID = 3
PLATFORM_OS_IPHONE  = 4
PLATFORM_OS_IPAD    = 5
PLATFORM_OS_WINRT   = 10
PLATFORM_OS_WP8     = 11

-- 记录平台和型号
if target == PLATFORM_OS_WINDOWS then
    Launcher.platform = "windows"
elseif target == PLATFORM_OS_MAC then
    Launcher.platform = "mac"
elseif target == PLATFORM_OS_ANDROID then
    Launcher.platform = "android"
elseif target == PLATFORM_OS_IPHONE or target == PLATFORM_OS_IPAD then
    Launcher.platform = "ios"
    if target == PLATFORM_OS_IPHONE then
        Launcher.model = "iphone"
    else
        Launcher.model = "ipad"
    end
elseif target == PLATFORM_OS_WINRT then
    Launcher.platform = "winrt"
elseif target == PLATFORM_OS_WP8 then
    Launcher.platform = "wp8"
end

Launcher.width = winSize.width
Launcher.height = winSize.height
Launcher.cx = Launcher.width / 2
Launcher.cy = Launcher.height / 2

if Launcher.platform ~= "windows" then
	Launcher.writablePath = fileUtils:getWritablePath()
else
	Launcher.writablePath = ""
end

if Launcher.platform == "android" then
	-- Android方法调用
	Launcher.javaClassName = "com/gfan/games/labs/luajavabridge/Luajavabridge"
	Launcher.luaj = {}

	Launcher.luaj.callStaticMethod = function(className, methodName, args, sig)
		return CCLuaJavaBridge.callStaticMethod(className, methodName, args, sig)
	end
elseif Launcher.platform == "ios" then
	-- iOS方法调用
	Launcher.ocClassName = "LuaObjcFun"
	Launcher.luaoc = {}

	Launcher.luaoc.callStaticMethod = function(className, methodName, args)
		local ok, ret = CCLuaObjcBridge.callStaticMethod(className, methodName, args)

		if not ok then
			local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
				className, methodName, tostring(args), tostring(ret))

			if ret == -1 then
				print(msg .. "INVALID PARAMETERS")
			elseif ret == -2 then
				print(msg .. "CLASS NOT FOUND")
			elseif ret == -3 then
				print(msg .. "METHOD NOT FOUND")
			elseif ret == -4 then
				print(msg .. "EXCEPTION OCCURRED")
			elseif ret == -5 then
				print(msg .. "INVALID METHOD SIGNATURE")
			else
				print(msg .. "UNKNOWN")
			end
		end
	end

	return ok, ret
end

-- 是否需要更新标志
Launcher.update = true

-- 请求类型
Launcher.RequestType = {
	LAUNCHER = 0,
	FLIST = 1,
	RES = 2
}

-- 更新结果
Launcher.UpdateRetType = {
	SUCCESSED = 0,
	NETWORK_ERROR = 1,
	MD5_ERROR = 2,
	OTHER_ERROR = 3
}

-- 输出16进制
Launcher.hex = function(input)
	return string.gsub(input, "(.)", function (x) return string.format("%02X", string.byte(x)) end)
end

-- 检查指定的文件或目录是否存在，如果存在返回 true，否则返回 false
Launcher.fileExists = function(path)
	local file = io.open(path, "r")

	if file then
		io.close(file)
		return true
	end

	return false
end

-- 读取文件内容，返回包含文件内容的字符串，如果失败返回 nil
Launcher.readFile = function(path)
	local file = io.open(path, "rb")

	if file then
		local content = file:read("*all")
		io.close(file)
		return content
	end

	return nil
end

-- 以字符串内容写入文件，成功返回 true，失败返回 false
Launcher.writeFile = function(path, content, mode)
	mode = mode or "w+b"
	local file = io.open(path, mode)

	if file then
		if file:write(content) == nil then return false end
		io.close(file)
		return true
	end

	return false
end

-- 递归删除指定路径下的所有文件和该文件夹
Launcher.removePath = function(path)
	local mode = lfs.attributes(path, "mode")
	if mode == "directory" then
		local dirPath = path .. "/"

		for file in lfs.dir(dirPath) do
			if file ~= "." and file ~= ".." then
				local f = dirPath .. file
				Launcher.removePath(f)
			end
		end

		os.remove(path)
	else
		os.remove(path)
	end
end

-- 建立目录
Launcher.mkDir = function(path)
	if not Launcher.fileExists(path) then
		return lfs.mkdir(path)
	end

	return true
end

-- 执行字符串的脚本
Launcher.doFile = function(path)
	local fileData = cc.HelperFunc:getFileData(path)
	local func = loadstring(fileData)
	local ret, flist = pcall(func)
	if ret then return flist end
	return flist
end

-- 生成文件数据的MD5值
Launcher.fileDataMD5 = function(fileData)
	if fileData ~= nil then
		return cc.Crypto:MD5(Launcher.hex(fileData), false)
	end

	return nil
end

-- 生成文件的MD5值
Launcher.fileMD5 = function(filePath)
	local data = Launcher.readFile(filePath)
	return Launcher.fileDataMD5(data)
end

-- 检查文件数据的MD5值
Launcher.checkFileDataWithMD5 = function(data, md5)
	if md5 == nil then return true end

	local fileMD5 = cc.Crypto:MD5(Launcher.hex(data), false)

	if fileMD5 == md5 then
		return true
	end

	return false
end

-- 检查文件的MD5值
Launcher.checkFileWithMD5 = function(filePath, md5)
	if not Launcher.fileExists(filePath) then
		return false
	end

	local data = Launcher.readFile(filePath)
	if data == nil then return false end

	return Launcher.checkFileDataWithMD5(data, md5)
end

-- 初始化平台
Launcher.initializePlatform = function(callback)
	if not checkPlatformInitialized() then
		if Launcher.platform == "android" then
			local javaMethodName = "initializePlatform"
			local javaParams = { callback }
			local javaMethodSig = "(I)V"
			Launcher.luaj.callStaticMethod(Launcher.javaClassName, javaMethodName, javaParams. javaMethodSig)
		elseif Launcher.platform == "ios" then
			local args = { callback }
			Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "initializePlatform", args)
		else
			callback("successed")
		end
	else
		callback("successed")
	end
end

-- 获取应用版本号
Launcher.getAppVersion = function()
	local appVersion = 1

	if Launcher.platform == "android" then
		local javaMethodName = "getAppVersion"
		local javaParams = {}
		local javaMethodSid = "()l"
		local ok, ret = Launcher.luaj.callStaticMethod(Launcher.javaClassName, javaMethodName, javaParams, javaMethodSig)
		if ok then
			appVersion = ret
		end
	elseif Launcher.platform == "ios" then
		local ok, ret = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "getAppVersion")
		if ok then
			appVersion = ret
		end
	end

	return appVersion
end

-- 指定时间后执行方法
Launcher.invoke = function(method, time)
	local scheduler = director:getScheduler()
	local handle = nil
	handle = scheduler:scheduleScriptFunc(function ()
		scheduler:unscheduleScriptEntry(handle)
		method()
	end, time, false)
end

-- 替换场景
Launcher.runWithScene = function(scene)
	local runningScene = director:getRunningScene()

	if runningScene then
		director:replaceScene(scene)
	else
		director:runWithScene(scene)
	end
end