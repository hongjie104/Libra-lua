--
-- 本地存储
-- Author: zhouhongjie@apowo.com
-- Date: 2014-07-10 09:40:25
--

--- 创建并进入本地存储数据的目录
-- @param path 本地存储数据的目录
local function checkDirOK(path)
	require "lfs"
	local oldpath = lfs.currentdir()
	if lfs.chdir(path) then
		lfs.chdir(oldpath)
		return true
	end

	if lfs.mkdir(path) then
		return true
	end
end

local LocalDump = class('LocalDump')

function LocalDump:ctor()
	self._path = cc.FileUtils:getInstance():getWritablePath() .. 'localData/'
	if checkDirOK(self._path) then
		local file = self._path .. 'localData'
		if io.exists(file) then
			self._data = dofile(file)
		else
			self._data = { }
		end
	else
		self._data = { }
	end
	self._needSave = true
end

function LocalDump:save(key, val)
	if val then
		if self._data[key] ~= val then
			self._data[key] = val
			self._needSave = true
		end
	end
end

function LocalDump:get(key)
	if self._data then
		return self._data[key]
	end
end

function LocalDump:saveToLocal()
	if self._needSave then
		self._needSave = false
		if self._data then
			local str = "return {"
			for k, v in pairs(self._data) do
				if type(v) == "number" then
					str = string.format("%s%s=%s%s", str, k, tostring(v), ",")
				else
					str = string.format("%s%s=\'%s\',", str, k, string.gsub(v, '\\', '\\\\'), '\',')
				end
			end
			str = str .. '}'
			io.writefile(self._path .. 'localData', str)
		end
	end
end

return LocalDump