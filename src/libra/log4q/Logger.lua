--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 10:11:02
--

local Logger = class("Logger")

function Logger:debug(...)
	if LOG_LEVEL.DEBUG then
		local info = "[DEBUG]:"
		for k, v in pairs({...}) do
			info = info .. tostring(v) .. ' '
		end
		print(info)
	end
end

function Logger:info(...)
	if LOG_LEVEL.INFO then
		local info = "[INFO]:"
		for k, v in pairs({...}) do
			info = info .. tostring(v) .. ' '
		end
		print(info)
	end
end

function Logger:warn(...)
	if LOG_LEVEL.WARN then
		local info = "[WARN]:"
		for k, v in pairs({...}) do
			info = info .. tostring(v) .. ' '
		end
		print(info)
	end
end

function Logger:error(...)
	if LOG_LEVEL.ERROR then
		local info = "[ERROR]:"
		for k, v in pairs({...}) do
			info = info .. tostring(v) .. ' '
		end
		print(info)
	end
end

function Logger:fatal(...)
	if LOG_LEVEL.FATAL then
		local info = "[FATAL]:"
		for k, v in pairs({...}) do
			info = info .. tostring(v) .. ' '
		end
		print(info)
	end
end

return Logger