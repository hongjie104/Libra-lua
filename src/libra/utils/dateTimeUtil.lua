--
-- Author: tanghongyang@apowo.com
-- Date: 2014-07-14 15:01:36
--

-- function formatDateSpanToAgoStr(fromDate, toDate)
-- 	return formatTimeSpanToAgoStr(os.time(fromDate), os.time(toDate))
-- end

-- function formatTimeSpanToAgoStr(fromTime, toTime)
-- 	return getSecondInterval(toTime - fromTime)
-- end

-- --- 将格式化日期字符串 "1970-1-1 0:0:0" 转换为table
-- function strToDateTable(str)
-- 	result = {}
-- 	for s in string.gmatch(str, "%d+") do
-- 		result[#result+1] = s
-- 	end
	
-- 	date = {}
-- 	date.year = tonumber(result[1])
-- 	date.month = tonumber(result[2])
-- 	date.day = tonumber(result[3])
-- 	date.hour = tonumber(result[4])
-- 	date.min = tonumber(result[5])
-- 	date.sec = tonumber(result[6])
-- 	return date
-- end

-- --- 比较两个日期字符串 "1970-1-1 0:0:0" 时间越往后越大，如2014年>2013年
-- -- @return -1 A>B  0 A=B  1 A<B
-- -- @usage print(compareTimeStr("2013-1-1 12:12:12", "2014-1-1 12:12:12"))
-- function compareTimeStr(strA, strB)
-- 	local timeA = os.time(strToDateTable(strA))
-- 	local timeB = os.time(strToDateTable(strB))

-- 	if timeA > timeB then
-- 		return -1
-- 	elseif timeA < timeB then
-- 		return 1
-- 	else
-- 		return 0
-- 	end
-- end

-- function secondToMSStr(sec)
-- 	local min = math.floor(sec / 60)
-- 	local sec = math.floor(sec % 60)
-- 	return min..":"..sec
-- end

--- 专门处理服务器传来的UTC时间，传化成lua的时间table格式
function formatSecondToLuaTable(second)
	return os.date("*t", second)
end

function formatTimeMonthDayHourMin(second)
	return os.date("%m-%d %H:%M", second)
end

function formateSecondToFullDate(second)
	return os.date("%Y-%m-%d %H:%M:%S", second)
end

--- 根据秒数获取一个文字的描述
-- function getSecondInterval(second)
-- 	local day = math.floor(second / 86400)
-- 	local hour = math.floor((second - day * 86400) / 3600)
-- 	local min = math.floor((second - day * 86400 - hour * 3600) / 60)

-- 	local str = ""
-- 	if day ~= 0 then
-- 		if hour > 0 then
-- 			str = _("%d天%d小时前", day, hour)
-- 		-- elseif min > 0 then
-- 		-- 	str = _("%d天%d分前", day, min)
-- 		else
-- 			str = _("%d天前", day)
-- 		end
-- 	else
-- 		if hour > 0 then
-- 			str = _("%d小时%d分前", hour, min)
-- 		elseif min > 0 then
-- 			str = _("%d分钟前", min)
-- 		else
-- 			str = _("%d分钟前", 1)
-- 		end
-- 	end
-- 	return str
-- end

-- --- 获取一个时间间隔
-- function getTimeInterval(oldTime)
-- 	return getSecondInterval(systemTimeSecond - oldTime)
-- end

-- function getFutureTimeStr(second)
-- 	local time = formatSecondToLuaTable(second)
-- 	local day = math.floor((second - systemTimeSecond) / 86400)
-- 	if day == 0 then
-- 		return _("今天%02d:%02d", time.hour, time.min)
-- 	elseif day == 1 then
-- 		return _("明天%02d:%02d", time.hour, time.min)
-- 	elseif day == 2 then
-- 		return _("后天%02d:%02d", time.hour, time.min)
-- 	else
-- 		return _("%d天后%02d:%02d", day, time.hour, time.min)
-- 	end
-- end

-- --- 将分钟数转换为小时、分钟
-- -- @ret 返回两个数:小时、分钟
-- function min2HourMin(min)
-- 	return math.floor(min/60), min%60
-- end