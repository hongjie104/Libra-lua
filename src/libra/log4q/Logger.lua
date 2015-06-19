--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 10:11:02
--

local MAX_COUNT = 50

local Logger = class("Logger")

function Logger:ctor()
	self._logList = { }
	self._count = 0
end

function Logger:getLogList()
	return self._logList
end

function Logger:printLog(tag, ...)
	local log = tag
	for k, v in pairs({...}) do
		log = string.format("%s%s ", log, tostring(v))
	end
	if self._count == MAX_COUNT then
		table.remove(self._logList, 1)
		self._count = MAX_COUNT - 1
	end
	self._count = self._count + 1
	self._logList[self._count] = log
	print(log)
end

function Logger:debug(...)
	if LOG_LEVEL.DEBUG then
		self:printLog("[DEBUG]:", ...)
	end
end

function Logger:info(...)
	if LOG_LEVEL.INFO then
		self:printLog("[INFO]:", ...)
	end
end

function Logger:warn(...)
	if LOG_LEVEL.WARN then
		self:printLog("[WARN]:", ...)
	end
end

function Logger:error(...)
	if LOG_LEVEL.ERROR then
		self:printLog("[ERROR]:", ...)
	end
end

function Logger:fatal(...)
	if LOG_LEVEL.FATAL then
		self:printLog("[FATAL]:", ...)
	end
end

return Logger