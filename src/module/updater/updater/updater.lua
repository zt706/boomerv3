--[[
	更新器
--]]

package.loaded["updater.init"] = nil
require("updater.init")

-- 单例对象
local fileUtils = cc.FileUtils:getInstance()

-- 更新器对象
local Updater = class("Updater")

-- 初始化
Updater.ctor = function(self)
	self.scene = nil
	self._path = Launcher.writablePath .. "updates/"

	-- 间隔时间执行
	Launcher.invoke(function()
		self:_onPlatformInitialized("successed")
		
		--!! 目前没有移动平台sdk初始化的需求
		-- Launcher.initializePlatform(handler(self, self._onPlatformInitialized))
	end, 0.1)
end

-- 平台初始化完成
Updater._onPlatformInitialized = function(self, msg)
	if msg == "successed" then
		Launcher.invoke(function()
			self:_checkUpdate()
		end, 0.1)
	else
		--!! 平台初始化失败处理
	end
end

-- 检测更新
Updater._checkUpdate = function(self)
	Launcher.mkDir(self._path)

	-- 检测文件列表文件是否存在（先检测更新目录，没有再检测apk）
	self._flistFile = self._path .. Launcher.flistFileName
	if Launcher.fileExists(self._flistFile) then
		self._fileList = Launcher.doFile(self._flistFile)
	else
		self._flistFile = "res/" .. Launcher.flistFileName
		self._fileList = Launcher.doFile(self._flistFile)
	end

	if self._fileList ~= nil then
		local appVersion = Launcher.getAppVersion()

		if appVersion ~= self._fileList.appVersion then
			-- TODO: APK下载更新
			-- 删除更新器目录下的所有文件
			Launcher.removePath(self._path)
			require("main")
			return
		end
	else
		-- 没找到文件列表，直接进入游戏
		self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
		self:_completeUpdate()
	end

	-- 请求最新版本的更新器脚本
	print("--------------- start download updater.zip ---------------")
	local url = Launcher.cdn .. Launcher.updaterPackage
	self:_downloadFile(url, Launcher.RequestType.LAUNCHER, 30)
end

-- 下载文件
Updater._downloadFile = function(self, url, requestType, waitTime)
	if Launcher.update then
		local request = cc.HTTPRequest:createWithUrl(function(event)
			self:_onResponse(event, requestType)
		end, url, cc.kCCHTTPRequestMethodGET)

		if request then
			request:setTimeout(waitTime or 60)
			request:start()
		else
			-- 初始化网络失败
			self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR

			--!! 弹窗提示用户检查网络
			self:_completeUpdate()
		end
	else
		-- 无需更新，直接开始游戏
		local runApp = function()
			require("app.MyApp").new():run()
		end

		runApp()
	end
end

-- 请求数据响应方法
Updater._onResponse = function(self, event, requestType)
	local request = event.request
	if event.name == "completed" then
		if request:getResponseStatusCode() ~= 200 then
			self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
			self:_completeUpdate()
		else
			local dataRecv = request:getResponseData()

			if requestType == Launcher.RequestType.LAUNCHER then
				self:_onUpdaterPackageCompleted(dataRecv)
			elseif requestType == Launcher.RequestType.FLIST then
				self:_onFileListDownloaded(dataRecv)
			elseif requestType == Launcher.RequestType.RES then
				self:_onResFileDownloaded(dataRecv)
			end
		end
	elseif event.name == "progress" then
		if requestType == Launcher.RequestType.RES then
			self:_onResourceProgress(event.dltotal)
		end
	else
		self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
		self:_completeUpdate()
	end
end

-- 资源更新进度
Updater._onResourceProgress = function(self, dltotal)
	self._currentFileDownloadedSize = dltotal
	self:_calculateUpdateProgress()
end

-- 更新器脚本包下载完成
Updater._onUpdaterPackageCompleted = function(self, dataRecv)
	local localMD5 = nil
	local localPath = self._path .. Launcher.updaterPackage

	if not Launcher.fileExists(localPath) then
		localPath = "res/" .. Launcher.updaterPackage
	end

	local localMD5 = Launcher.fileMD5(localPath)
	local downloadMD5 = Launcher.fileDataMD5(dataRecv)
	if localMD5 ~= downloadMD5 then
		-- 更新更新器脚本打包
		local path = self._path  .. Launcher.updaterPackage
		Launcher.writeFile(path, dataRecv)
		require("main")
	else
		-- 加载flist文件
		print("--------------- start download flist ---------------")
		local url = Launcher.server .. Launcher.flistFileName
		self:_downloadFile(url, Launcher.RequestType.FLIST)
	end
end

-- 文件列表下载完成
Updater._onFileListDownloaded = function(self, dataRecv)
	self._newFlistFile = self._path .. Launcher.flistFileName .. Launcher.updateFileSuffix
	Launcher.writeFile(self._newFlistFile, dataRecv)

	self._newFileList = Launcher.doFile(self._newFlistFile)

	if self._newFileList == nil then
		self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
		self:_completeUpdate()
		return
	end

	-- 版本相同时则删除更新的文件列表
	if self._newFileList.version == self._fileList.version then
		Launcher.removePath(self._newFlistFile)
		self._updateRetType = Launcher.UpdateRetType.SUCCESSED
		self:_completeUpdate()
		return
	end

	print("--------------- start download resource files ---------------")

	if self.scene ~= nil and type(self.scene.onUpdateOpen) == "function" then
		self.scene:onUpdateOpen()
	end

	-- 创建资源目录
	local dirPaths = self._newFileList.dirPaths
	for i, v in ipairs(dirPaths) do
		local dirName = v.name
		Launcher.mkDir(self._path .. dirName)
	end

	self:_genUpdateFileList()
	self._fileUpdatedIndex = 0
	self:_updateNextResourceFile()
end

-- 生成下载文件列表
Updater._genUpdateFileList = function(self)
	self._updateFileList = {}
	self._removeFileList = {}
	self._downloadedFileList = {}
	self._totalDownloadSize = 0
	self._downloadedSize = 0
	self._currentFileDownloadedSize = 0

	local newFileList = self._newFileList.fileInfoList
	local oldFileList = self._fileList.fileInfoList

	local changed = false

	for i, newFile in ipairs(newFileList) do
		changed = false

		for j, oldFile in ipairs(oldFileList) do
			if newFile.name == oldFile.name then

				changed = true

				if newFile.code ~= oldFile.code then
					local fn = newFile.name .. Launcher.updateFileSuffix

					if Launcher.checkFileWithMD5(self._path .. fn, newFile.code) then
						table.insert(self._downloadedFileList, fn)
					else
						self._totalDownloadSize = self._totalDownloadSize + newFile.size
						table.insert(self._updateFileList, newFile)
					end
				end

				table.remove(oldFileList, j)
				break
			end
		end

		if changed == false then
			self._totalDownloadSize = self._totalDownloadSize + newFile.size
			table.insert(self._updateFileList, newFile)
		end
	end

	self._removeFileList = oldFileList
end

-- 资源文件下载完成
Updater._onResFileDownloaded = function(self, dataRecv)
	local fn = self._currentFileInfo.name .. Launcher.updateFileSuffix
	Launcher.writeFile(self._path .. fn, dataRecv)

	if Launcher.checkFileWithMD5(self._path .. fn, self._currentFileInfo.code) then
		table.insert(self._downloadedFileList, fn)
		self._downloadedSize = self._downloadedSize + self._currentFileInfo.size
		self._currentFileDownloadedSize = 0
		self:_updateNextResourceFile()
	else
		-- 文件验证失败
		self._updateRetType = Launcher.UpdateRetType.MD5_ERROR
		self:_completeUpdate()
	end
end

-- 更新下一个资源文件
Updater._updateNextResourceFile = function(self)
	self:_calculateUpdateProgress()
	self._fileUpdatedIndex = self._fileUpdatedIndex + 1
	self._currentFileInfo = self._updateFileList[self._fileUpdatedIndex]

	if self._currentFileInfo and self._currentFileInfo.name then
		local url = Launcher.cdn .. self._currentFileInfo.name
		self:_downloadFile(url, Launcher.RequestType.RES)
	else
		self:_completeResourceFilesDownload()
	end
end

-- 计算更新进度
Updater._calculateUpdateProgress = function(self)
	local downloadProgress = (self._downloadedSize + self._currentFileDownloadedSize) * 100 / self._totalDownloadSize
	if self.scene ~= nil and type(self.scene.onUpdateProgress) == "function" then
		self.scene:onUpdateProgress(downloadProgress)
	end
end

-- 完成资源文件下载
Updater._completeResourceFilesDownload = function(self)
	-- 用新的文件列表替换旧的文件列表
	local data = Launcher.readFile(self._newFlistFile)
	local path = self._path .. Launcher.flistFileName

	Launcher.writeFile(path, data)
	self._fileList = Launcher.doFile(self._flistFile)

	if self._flistFile == nil then
		-- 报错
		self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
		self:_completeUpdate()
	end

	Launcher.removePath(self._newFlistFile)

	local offset = -1 - string.len(Launcher.updateFileSuffix)

	for i, v in ipairs(self._downloadedFileList) do
		v = self._path .. v
		local data = Launcher.readFile(v)
		local fn = string.sub(v, 1, offset)
		Launcher.writeFile(fn, data)
		Launcher.removePath(v)
	end

	for i, v in ipairs(self._removeFileList) do
		local fn = v.name
		Launcher.removePath(self._path .. fn)
	end

	self._updateRetType = Launcher.UpdateRetType.SUCCESSED
	self:_completeUpdate()
end

-- 完成更新
Updater._completeUpdate = function(self)
	if self._updateRetType ~= Launcher.UpdateRetType.SUCCESSED then
		print(string.format("--------------- Update ErrorCode = %d ---------------", self._updateRetType))
		if self._flistFile ~= nil then
			--!! 暂时屏蔽掉
			-- Launcher.removePath(self._flistFile)
		end
	end

	if self.scene ~= nil and type(self.scene.onUpdateComplete) == "function" then
		self.scene:onUpdateComplete()
	end
end

return Updater