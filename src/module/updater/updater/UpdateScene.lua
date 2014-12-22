--[[
	更新场景
--]]

package.loaded["updater.updater"] = nil
local Updater = require("updater.updater")

-- 运行程序
local runApp = function()
	require("app.MyApp").new():run()
end

-- 更新场景
local UpdateScene = class("UpdateScene", function()
	local scene = cc.Scene:create()
	scene.name = "UpdateScene"
	return scene
end)

-- 构造函数
UpdateScene.ctor = function(self)
	-- 显示文本
	self._textLabel = cc.LabelTTF:create("正在检测更新，请耐心等待...", "Arial", 20)
	self._textLabel:setColor({r = 255, g = 255, b = 255})
	self._textLabel:setPosition(Launcher.cx, Launcher.cy)
	self:addChild(self._textLabel)

	-- 更新器初始化
	self._updater = Updater.new()
	self._updater.scene = self
end

-- 更新开始
UpdateScene.onUpdateOpen = function(self)
	self._textLabel:setString("正在更新数据资源，请耐心等待...")

	self._progressLabel = cc.LabelTTF:create("0%", "", 20)
	self._progressLabel:setColor({r = 255, g = 255, b = 255})
	self._progressLabel:setPosition(Launcher.cx, Launcher.cy - 20)
	self:addChild(self._progressLabel)
end

-- 更新进度显示
UpdateScene.onUpdateProgress = function(self, downloadProgress)
	self._progressLabel:setString(string.format("%d%%", downloadProgress))
end

-- 更新完毕
UpdateScene.onUpdateComplete = function(self)
	runApp()
end

local scene = UpdateScene.new()
Launcher.runWithScene(scene)