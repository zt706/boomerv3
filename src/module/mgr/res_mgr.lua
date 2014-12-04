--[[
	资源管理器
		通过引用计数来对资源实现管理
--]]

local ResMgr = class("ResMgr")

TEXTURE_FORMAT = {}
TEXTURE_FORMAT.default = 0x8 --!! cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444

ResMgr.ctor = function(self)
	self:init()
end

ResMgr.init = function(self)
	self.const = {
		CHAR_RES_PATH = "char/",
		EFFECT_RES_PATH = "effects/",
	}

	self.resCount = {
		plist = {},
		png = {},
		armature = {},
	}

	self.cache = {
		particleDict = {},
		charActionData = {},
	}

	--!! self.armatureDataManager = cc.ArmatureDataManager:sharedArmatureDataManager()
	self.spriteFrameCache = cc.SpriteFrameCache:getInstance()
	self.resourceMgr = nil --QResourceManager:sharedResourceManager()
	--!! self.textureCache = cc.TextureCache:getInstance()
end

-- 成对使用，保存当前的AlphaPixelFormat
ResMgr.saveAlphaPixelFormat = function(self)
	self.currentFormat = cc.Texture2D:getDefaultAlphaPixelFormat()
	return self.currentFormat
end

ResMgr.restoreAlphaPixelFormat = function(self)
	cc.Texture2D:setDefaultAlphaPixelFormat(self.currentFormat)
end

ResMgr.replaceAlphaPixelFormat = function(self, textureFormat)
	cc.Texture2D:setDefaultAlphaPixelFormat(textureFormat)
end

ResMgr.saveAndReplaceAlphaPixelFormat = function(self, textureFormat)
	self:saveAlphaPixelFormat()
	self:replaceAlphaPixelFormat(textureFormat)
end

-- 成对使用，当加载完成时，调用stopAsync
ResMgr.startAsync = function(self)
	self.resourceMgr:start()
end

ResMgr.stopAsync = function(self)
	self.resourceMgr:stop()
end

-- 加载ExportJson类型资源
ResMgr.loadArmature = function(self, res, textureFormat)
	if self.resCount.armature[res] then
		self.resCount.armature[res] = self.resCount.armature[res] + 1
		return
	end

	self.resCount.armature[res] = 1
	textureFormat = textureFormat or TEXTURE_FORMAT.default

	self:saveAndReplaceAlphaPixelFormat(textureFormat)
	self.armatureDataManager:addArmatureFileInfo(res)
	self:restoreAlphaPixelFormat()
end

ResMgr.loadArmatureAsync = function(self, res, textureFormat, callback)
	if self.resCount.armature[res] then
		self.resCount.armature[res] = self.resCount.armature[res] + 1
		callback()
		return
	end

	self.resCount.armature[res] = 1
	textureFormat = textureFormat or TEXTURE_FORMAT.default

	local currentFormat = self.saveAlphaPixelFormat()
	self.resourceMgr:loadArmatureFileAsync(res, textureFormat, currentFormat, callback)
end

ResMgr.removeArmature = function(self, res, isCleanup)
	if not self.resCount.armature[res] or self.resCount.armature[res] == 0 then
		Logger.error(res, " :并未加载，你无法移除它！")
		return
	end

	self.resCount.armature[res] = self.resCount.armature[res] - 1
	if self.resCount.armature[res] == 0 and isCleanup then
		self.armatureDataManager:removeArmatureFileInfo(res)
		self.resCount.armature[res] = nil
	end
end

-- 加载plist资源类型
ResMgr.loadPlist = function(self, res, textureFormat)
	if self.resCount.plist[res] then
		self.resCount.plist[res] = self.resCount.plist[res] + 1
		return
	end

	self.resCount.plist[res] = 1
	textureFormat = textureFormat or TEXTURE_FORMAT.default

	self:saveAndReplaceAlphaPixelFormat(textureFormat)
	self.spriteFrameCache:addSpriteFrames(res)
	self:restoreAlphaPixelFormat()
end

ResMgr.loadPlistAsync = function(self, res, textureFormat, callback)
	if self.resCount.plist[res] then
		self.resCount.plist[res] = self.resCount.plist[res] + 1
		callback()
		return
	end

	self.resCount.plist[res] = 1
	textureFormat = textureFormat or TEXTURE_FORMAT.default

	local currentFormat = self:saveAlphaPixelFormat()
	self.resourceMgr:loadPlistFileAsync(res, textureFormat, currentFormat, callback)
end

ResMgr.removePlist = function(self, res, isCleanup)
	if not self.resCount.plist[res] or self.resCount.plist[res] == 0 then
		Logger.error(res, " :并未加载，你无法移除它！")
		return
	end

	self.resCount.plist[res] = self.resCount.plist[res] - 1
	if self.resCount.plist[res] == 0 and isCleanup then
		self.spriteFrameCache:removeSpriteFramesFromFile(res)
		self.resCount.plist[res] = nil
	end
end

-- 加载普通纹理图片，png或jpg类型的格式
-- loadTexture私有方法，外界不应该调用
local loadTexture = function(res, textureFormat)
	textureFormat = textureFormat or TEXTURE_FORMAT.default

	self:saveAndReplaceAlphaPixelFormat(textureFormat)

	local texture = self.textureCache:addImage(res)
	if not texture then
		Logger.error("加载纹理图片: ", res, " 失败！")
	end

	self:restoreAlphaPixelFormat()

	return texture
end

-- 加载纹理使用这个方法，这里进行引用计数
ResMgr.retainTexture = function(self, res, textureFormat)
	local key = CCFileUtils:sharedFileUtils():fullPathForFilename(res)
	if self.resCount.png[key] then
		self.resCount.png[key] = self.resCount.png[key] + 1
		return
	end

	local texture = self.textureCache:textureForKey(key)
	if not texture then
		texture = loadTexture(res, textureFormat)
		if not texture then
			return
		end
	end

	texture:retain()

	self.resCount.png[key] = 1
end

ResMgr.releaseTexture = function(self, res)
	local key = CCFileUtils:sharedFileUtils():fullPathForFilename(res)
	if not self.resCount.png[key] or self.resCount.png[key] == 0 then
		return
	end

	self.resCount.png[key] = self.resCount.png[key] - 1
	local texture = self.textureCache:textureForKey(key)
	if self.resCount.png[key] == 0 and texture then
		texture:release()
	end
end

-- 调试使用
ResMgr.dumpTexturesInfo = function(self)
	table.print(self.resCount.png)
	table.print(self.resCount.plist)
	table.print(self.resCount.armature)
end

-- 遍历移除那些没有使用的纹理
ResMgr.removeUnusedTextures = function(self)
	-- 移除没有使用的plist资源
	local unusedPlist = {}
	for k, v in pairs(self.resCount.plist) do
		if v == 0 then
			table.insert(unusedPlist, k)
		end
	end

	for k, v in pairs(unusedPlist) do
		self.resCount.plist[v] = nil
		self.spriteFrameCache:removeSpriteFramesFromFile(v)
	end

	-- 移除没有使用的ExportJson资源
	local unusedArmature = {}
	for k, v in pairs(self.resCount.armature) do
		if v == 0 then
			table.insert(unusedArmature, k)
		end
	end

	for k, v in pairs(unusedArmature) do
		self.resCount.armature[v] = nil
		self.armatureDataManager:removeArmatureFileInfo(v)
	end

	-- 移除没有使用的普通纹理图片
	self.textureCache:removeUnusedTextures()
end

-- 针对角色加载动画资源
ResMgr.getCharRes = function(self, name, resType)
	resType = resType or "png"
	return string.format("%s%s.%s", self.const.CHAR_RES_PATH, name, resType)
end

ResMgr.loadCharRes = function(self, name, resType)
	self:loadPlist(self:getCharRes(name, resType), TEXTURE_FORMAT.char)
end

ResMgr.removeCharRes = function(self, name, resType)
	self:removePlist(self:getCharRes(name, resType))
end

ResMgr.getEffectRes = function(self, name, resType)
	resType = resType or "png"
	return string.format("%s%s.%s", self.const.EFFECT_RES_PATH, name, resType)
end

ResMgr.loadEffectRes = function(self, name, resType)
	local res = self:getEffectRes(name, resType)
	if resType == "ExportJson" then
		self:loadArmature(res)
	elseif resType == "plist" then
		self:loadPlist(res)
	else
		Logger.error("加载特效资源错误：", res)
	end
end

ResMgr.removeEffectRes = function(self, name, resType)
	local res = self:getEffectRes(name, resType)
	if resType == "ExportJson" then
		self:removeArmature(res)
	elseif resType == "plist" then
		self:removePlist(res)
	else
		Logger.error("移除特效资源错误：", res)
	end
end

ResMgr.createParticleWithCacheDict = function(self, plist, nodeEventHandler)
	local dict = self.cache.particleDict[plist]
	if not dict then
		dict = CCDictionary:createWithContentsOfFileThreadSafe(plist)
		dict:retain()
		self.cache.particleDict[plist] = dict
	end

	local particle = nil
	local infoPackTex = require("data.info_particle_packtexture")
	local pathinfo = io.pathinfo(plist)
	local packTex = infoPackTex[pathinfo.basename] and infoPackTex[pathinfo.basename].res
	
	if not packTex then
		particle = CCParticleSystemQuad:create(dict, pathinfo.dirname)
	else
		-- 预加载纹理
		local textureRes = self:getEffectRes(packTex, "plist")
		self:loadPlist(textureRes, TEXTURE_FORMAT.effect)

		local splitnames = string.split(dict:valueForKey("textureFileName"):getCString(), ".")
		local frameName = self:getEffectRes(splitnames[1], splitnames[2])
		local spriteFrame = display.newSpriteFrame(frameName)
		particle = CCParticleSystemQuad:create(dict, spriteFrame)
		particle:registerScriptHandler(function(event)
			if event == "destroy" then
				self:removePlist(textureRes, true)
			end

			if nodeEventHandler then
				nodeEventHandler(event)
			end
		end)
	end

	return particle
end

ResMgr.clearParticleDictCache = function(self)
	for k, v in pairs(self.cache.particleDict) do
		if not tolua.isnull(v) then
			v:release()
		end

		self.cache.particleDict[k] = nil
	end
end

ResMgr.getCharActionData = function(self, prefix, action)
	local data = self.cache.charActionData[prefix]
	if data and data[action] and not tolua.isnull(data[action]) then
		return data[action]
	end

	return nil
end

ResMgr.saveCharActionData = function(self, prefix, action, actionData)
	self.cache.charActionData[prefix] = self.cache.charActionData[prefix] or {}
	if self.cache.charActionData[prefix][action] and not tolua.isnull(self.cache.charActionData[prefix][action]) then
		return
	end

	actionData:retain()
	self.cache.charActionData[prefix][action] = actionData
end

ResMgr.clearCharActionDataCache = function(self)
	for prefix, actionDatas in pairs(self.cache.charActionData) do
		for action, actionData in pairs(actionDatas) do
			if not tolua.isnull(actionData) then
				actionData:release()
			end
		end

		self.cache.charActionData[prefix] = nil
	end
end

ResMgr.removeResCache = function(self)
	-- 清空粒子缓存
	self:clearParticleDictCache()
	-- 清空角色Action的数据
	self:clearCharActionDataCache()
end

return ResMgr