--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-09-15 20:04:30
--

require "lfs"

local function dirExist(path)
	local oldpath = lfs.currentdir()
	if lfs.chdir(path) then
		lfs.chdir(oldpath)
		return true
	else
		return false
	end
end

--- 清空文件夹下所有文件
-- @param path 文件夹路径
local function cleanDir(path)
	if dirExist(path) then
		for file in lfs.dir(path) do
			if file ~= "." and file ~= ".." then
				local fullpath = path .. file
				local attr = lfs.attributes(fullpath)
				if attr.mode == "directory" then
					fullpath = fullpath.."/"
					cleanDir(fullpath)
					lfs.rmdir(fullpath)
				else
					os.remove(fullpath)
				end
			end
		end
	end
end

local function createDir(path)
	if not dirExist(path) then
		if lfs.mkdir(path) then
			print("创建目录:" .. path)
			return true
		end
	else
		return true
	end
end


--- 创建并进入热更新下载的目录
-- @param path 热更新目录
local function checkDirOK(path)
	local result = true
	if platform == 'ios' or platform == 'mac' then
		-- 在ios下，gsub得到结果有莫名的问题，不知道为啥，所以就直接用正则表达式来截取string了
		local found = string.find(path, "upd.*")
		if found then
			path = string.sub(path, found)
		else 
			path = ""
		end	
	else
		path = string.gsub(path, cc.FileUtils:getInstance():getWritablePath(), "")
	end
	local pathTable = string.split(path, "/")
	local newPath = nil
	for i, v in ipairs(pathTable) do
		if v ~= "" then
			if newPath then
				newPath = newPath .. v .. '/'
			else
				newPath = cc.FileUtils:getInstance():getWritablePath() .. v .. '/'
			end
			if not createDir(newPath) then
				result = false
				break
			end
		end
	end
	return result
end

local function filterPath(path)
	return string.gsub(path, "res/%d+/", "")
end

local function pathinfo(path)
	local pos = string.len(path)
	local extpos = pos + 1
	while pos > 0 do
		local b = string.byte(path, pos)
		if b == 46 then -- 46 = char "."
			extpos = pos
		elseif b == 47 then -- 47 = char "/"
			break
		elseif b == 92 then -- 92 = char "\"
			break
		end
		pos = pos - 1
	end

	local dirname = string.sub(path, 1, pos)
	local filename = string.sub(path, pos + 1)
	extpos = extpos - pos
	local basename = string.sub(filename, 1, extpos - 1)
	local extname = string.sub(filename, extpos)
	return {
		dirname = dirname,
		filename = filename,
		basename = basename,
		extname = extname
	}
end

local function writefile(path, content, mode)
	path = filterPath(path)
	if checkDirOK(pathinfo(path).dirname) then
		mode = mode or "w+b"
		local file = io.open(path, mode)
		if file then
			if file:write(content) == nil then return false end
			io.close(file)
			print("写入文件成功:", path)
			return true
		else
			print("写入文件失败:", path)
			return false
		end
	end
end

--- 读取文件
-- @param path 文件路径
-- @return 文件内容
local function readFile(path)
	path = filterPath(path)
	local file = io.open(path, "rb")
	if file then
		local content = file:read("*all")
		io.close(file)
		return content
	end
	return nil
end

--- 删除文件
-- @param path 文件路径
local function removeFile(path)
	path = filterPath(path)
	writefile(path, "")
	if device.platform == "windows" then
		-- win下的删除文件代码注释掉，否则会导致输入台中错乱
		-- os.execute("del " .. string.gsub(path, '/', '\\'))
	else
		os.execute("rm " .. path)
	end
end

--- 检查文件
-- 如果待查文件的md5与cryptoCode一致，返回true
-- 否则返回false
-- @param fileName 待查文件，完整的路径
-- @param cryptoCode md5码
local function checkFile(fileName, cryptoCode)
	fileName = filterPath(fileName)
	if not io.exists(fileName) then
		return false
	end

	local data = readFile(fileName)
	if data == nil then
		return false
	end

	if cryptoCode == nil then
		return true
	end

	-- local ms = crypto.md5file(data)
	-- local ms = crypto.md5file(fileName)
	local ms = crypto.md5file(fileName)
	if string.upper(ms) == string.upper(cryptoCode) then
		return true
	end

	return false
end

local list_filename = "fileList"
local resUrl = "127.0.0.1/"
local param = "?dev=" .. device.platform
local downList = {}

local UpdateScene = class("UpdateScene", function()
	return display.newScene("UpdateScene")
end)

function UpdateScene:ctor()
	self._path = cc.FileUtils:getInstance():getWritablePath() .. "upd/"

	-- 读取本地存储的上一次安装包的VERSION，和appConfig中的VERSION对比一下
	-- 如果一致，说明不是新的安装包，否则就把upd目录给删掉
	local lastVersionLua = cc.FileUtils:getInstance():getWritablePath() .. "version"
	local lastVersion = nil
	if io.exists(lastVersionLua) then
		lastVersion = dofile(lastVersionLua)
	end
	if lastVersion ~= VERSION then
		print("安装了新的安装包,将upd目录删除")
		cleanDir(self._path)
		self._version = VERSION
		writefile(lastVersionLua, "return '" .. VERSION .. "'")
	end

	if checkDirOK(self._path) then
		self:startToUpdate()
	else
		require("app.MyApp").new():run()
	end
end

function UpdateScene:startToUpdate()
	-- 当前的更新列表
	self._curListFile = self._path .. list_filename
	self._fileList = nil
	if io.exists(self._curListFile) then
		self._fileList = dofile(self._curListFile)
	end
	if self._fileList == nil then
		self._fileList = {
			ver = VERSION,
			core = 0,
			updateList = {}
		}
	end
	-- 核心版本号
	self._coreOld = self._fileList.core
	self._curVer = checkint(string.split(self._fileList.ver, '.')[4])
	
	-- 开始动态更新
	self._requestCount = 0
	self._requesting = list_filename
	self._newListFile = self._curListFile .. ".upd"
	self._dataRecv = nil
	self:requestFromServer(self._requesting)
end

--- 向服务器发送下载请求
function UpdateScene:requestFromServer(filename, waittime)
	self._requesting = filename
	local url = resUrl .. filename .. param
	print('开始下载' .. url)
	self._requestCount = self._requestCount + 1
	local request = network.createHTTPRequest(function(event)
		self:onResponse(event, index)
	end, url, "GET")
	if request then
		request:setTimeout(waittime or 30)
		request:start()
	else
		print('更新失败: 连不上资源服务器')
		self:endProcess()
	end
end

function UpdateScene:onResponse(event)
	local request = event.request
	if event.name == "completed" then
		if request:getResponseStatusCode() ~= 200 then
			print('更新失败: request:getResponseStatusCode()为' .. request:getResponseStatusCode())
			self:endProcess()
		else
			self._dataRecv = request:getResponseData()
			self:onFileDownLoaded()
		end
	elseif event.name == 'inprogress' or event.name == 'progress' then
		if self._requesting ~= 'fileList' then
			local cur, total = 0, 0
			-- android的CCHTTPRequest中的键值居然不一样，太坑爹了
			if event.dlnow then
				cur, total = event.dlnow, event.dltotal
			elseif event.total then
				cur, total = event.dltotal, event.total
			end
			self._requestTempSize = self._requestSize + cur
			print('下载中=>' .. cur .. '/'.. total)
			-- self._progressBar:setPercentage(checkint(self._requestTempSize / self._requestTotalSize * 100))
			-- self._infoLabel:setString(string.format("游戏更新中，请耐心等待...(%sM/%sM)", string.format("%.2f", self._requestTempSize / 1048576), self._totalM))
		end
	else
		print('更新失败: 请检查网络，event.name = ' .. event.name)
		self:endProcess()
	end
end

function UpdateScene:onFileDownLoaded()
	if self._dataRecv then
		if self._requesting == list_filename then
			-- 更新列表加载完成
			if writefile(self._newListFile, self._dataRecv) then
				self._dataRecv = nil

				self._fileListNew = dofile(self._newListFile)
				-- self._requestCountTotal = 0
				if self._fileListNew == nil then
					self._curVer = 0
					print("更新失败: self._fileListNew 为nil")
					self:endProcess()
				else
					-- 总共需要下载的大小,默认不是0是为了避免0成为除数
					self._requestTotalSize = 1
					-- 已经下载的大小
					self._requestSize = 0
					self._requestTempSize = 0
					if self._fileListNew.ver == self._fileList.ver then
						print("与线上版本号一致，不需要更新")
						self:endProcess()
					else
						self._versionNew = self._fileListNew.ver
						self._coreNew = self._fileListNew.core or 0
						if self._coreOld < self._coreNew then
							-- 核心版本号小于最新版，说明得下载最新的安装包了
							-- local alert = self:showAlert("得去下载最新的安装包，进行完整的安装才能进入游戏")
							-- self:addChild(alert)
							print("请下载最新的安装包")
						else
							print("获取更新列表成功")
							local localV = checkint(string.split(self._fileList.ver, ".")[4])
							local serverV = checkint(string.split(self._fileListNew.ver, ".")[4])
							print("checking version: %s: %s", localV, serverV)
							if localV < serverV then
								-- 判断网络状态，值有三种：
								-- kCCNetworkStatusNotReachable: 无法访问互联网
								-- kCCNetworkStatusReachableViaWiFi: 通过 WIFI
								-- kCCNetworkStatusReachableViaWWAN: 通过 3G 网络
								if device.platform == "windows" or device.platform == "mac" then
									self:doUpdate()
								else
									if IS_TV then
										-- TV版不用检查网络状态
										self:doUpdate()
									else
										local netStatus = network.getInternetConnectionStatus()
										if netStatus == kCCNetworkStatusNotReachable then
											-- local alert = self:showAlert("网络不可用", function ()
											--	 self:doUpdate()
											-- end, function ()
											--	 self:endProcess()
											-- end)
											-- self:addChild(alert)
											print("网络不可用")
										elseif netStatus == kCCNetworkStatusReachableViaWWAN then
											-- local alert = self:showAlert("3G网络,确定要更新嘛?", function ()
											--	 self:doUpdate()
											-- end)
											-- self:addChild(alert)
											self:doUpdate()
										else
											self:doUpdate()
										end
									end
								end
							else
								print(string.format("本地版本号:%s大于更新列表中版本号:%s,故不更新", localV, serverV))
								self:endProcess()
							end
						end
					end
				end
			else
				self:endProcess()
			end
		else
			local fn = self._path .. self._curUpdateFile.name .. ".upd"
			print(self._curUpdateFile.name .. '下载好了')
			if type(self._curUpdateFile.size) == 'number' then
				self._requestSize = self._requestSize + self._curUpdateFile.size
			end
			self._requestTempSize = self._requestSize
			-- self._progressBar:setPercentage(checkint(self._requestTempSize / self._requestTotalSize * 100))

			if writefile(fn, self._dataRecv) then
				print(self._curUpdateFile.name .. '.upd保存好了')
				self._dataRecv = nil
				if checkFile(fn, self._curUpdateFile.code) then
					table.insert(downList, fn)
					print('开始下载下一个')
					self:reqNextFile()
				else
					print("校验失败：:" .. fn .. '的md5码不等于' .. self._curUpdateFile.code)
					self:endProcess()
				end
			else
				print("保存失败:" .. fn)
				self:endProcess()
			end
		end
	else
		self:endProcess()
	end
end

function UpdateScene:doUpdate()
	self._numFileCheck = 0
	self._requesting = "files"
	self:checkUpdateList()

	-- if self._requestTotalSize>0 then
	-- 	self:showAlert(string.format("大人，有新版本更新，需要下载%.2fM数据。", self._requestTotalSize), 
	-- 		function ()
	-- 			print("我要更新")
	-- 			self:reqNextFile()
	-- 		end,
	-- 		function ()
	-- 			print("取消更新，直接进入游戏")
	-- 			self:skipUpdateAndRunGame()
	-- 		end,
	-- 		"更新",
	-- 		"ty_tankuangdi01.png"
	-- 	)
	-- else
	-- 	self:reqNextFile()
	-- end
	self:reqNextFile()
end

function UpdateScene:checkUpdateList()
	-- 等一会要加载并更新的文件
	self._toUpdateList = { }
	for k, v in pairs(self._fileListNew.updateList) do
		if self._curVer < checkint(k) then
			table.insertto(self._toUpdateList, v)
			for _, vv in ipairs(v) do
				-- self._requestCountTotal = self._requestCountTotal + 1 
				if type(vv.size) == "number" then
					self._requestTotalSize = self._requestTotalSize + vv.size
				end
			end
		end
	end

	self._totalM = string.format("%.2f", self._requestTotalSize / 1048576)
end

function UpdateScene:reqNextFile()
	self._numFileCheck = self._numFileCheck + 1
	-- 取出当前正在更新的文件信息
	self._curUpdateFile = self._toUpdateList[self._numFileCheck]
	if self._curUpdateFile and self._curUpdateFile.name then
		local fn = self._path .. self._curUpdateFile.name
		if checkFile(fn, self._curUpdateFile.code) then
			self:reqNextFile()
		else
			fn = fn .. ".upd"
			if checkFile(fn, self._curUpdateFile.code) then
				table.insert(downList, fn)
				self:reqNextFile()
			else
				local timeout = 0
				if self._curUpdateFile.size > 3000000 then timeout = checkint(self._curUpdateFile.size / 100000) end
				self:requestFromServer(self._curUpdateFile.name, timeout)
			end
		end
	else
		-- 没有要读取的文件时，将已经下载好的文件进行整理
		local data = readFile(self._newListFile)
		if writefile(self._curListFile, data) then
			self._fileList = dofile(self._curListFile)
			if self._fileList == nil then
				print('更新失败：self._fileList 为nil')
				self:endProcess()
			else
				removeFile(self._newListFile)
				for i, v in ipairs(downList) do
					local data = readFile(v)
					local fn = string.sub(v, 1, -5)
					writefile(fn, data)
					print('保存文件：' .. fn)
					removeFile(v)
				end
				self:endProcess(true)
			end
		else
			self:endProcess()
		end
	end
end

--- 最后的收尾工作，不管更新是否成功了
function UpdateScene:endProcess(success)
	if success then
		self._version = self._versionNew
		print("更新完成，初始化游戏中")
	else
		print("更新失败，请退出游戏重新尝试")
	end

	-- if self._progressBar then
	-- 	self._progressBar:setPercentage(100)
	-- end

	if self._fileList and self._fileList.updateList then
		local checkOK = true
		for k, v in pairs(self._fileList.updateList) do
			if self._curVer < checkint(k) then
				for _, vv in ipairs(v) do
					if not checkFile(self._path .. vv.name, vv.code) then
						-- Check Files Error
						checkOK = false
						break
					end
				end
				if checkOK == false then
					break
				end
			end
		end

		if checkOK then
			local keyList = { }
			for i in pairs(self._fileList.updateList) do
				table.insert(keyList, i)
			end
			table.sort(keyList, function(v1, v2) return checkint(v1) < checkint(v2) end)

			for i, ver in ipairs(keyList) do
				for _, vv in ipairs(self._fileList.updateList[ver]) do
					if vv.act == "load" then
						loadChunksFromZIP(self._path .. vv.name)
						print('加载zip = ' .. self._path .. vv.name)
					end
				end
			end
		else
			removeFile(self._curListFile)
		end
	end

	-- 清除数据
	-- CCArmatureDataManager:purge()
	-- SceneReader:sharedSceneReader():purge()
	-- ActionManager:purge()
	-- GUIReader:purge()

	require("app.MyApp").new():run()
end

display.replaceScene(UpdateScene.new())
