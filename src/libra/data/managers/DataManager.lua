--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-01 11:28:01
--

local DataManager = class("DataManager")

function DataManager:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self._dataList = { }
end

function DataManager:getData(id)
	for i, v in ipairs(self._dataList) do
		if v:id() == id then
			return v
		end
	end
end

function DataManager:getDataListByType(type)
	local list, index = { }, 1
	for i, v in ipairs(self._dataList) do
		if v:type() == type then
			list[index] = v
			index = index + 1
		end
	end
	return list
end

function DataManager:addData(type, id)
	local data = self:getData(id)
	if not data then
		data = self:getDataType().new()
		data:type(type)
		data:id(id)
		self._dataList[#self._dataList + 1] = data
	end
	return data
end

function DataManager:updateData(id, otherProperty)
	local data = self:getData(id)
	if data then
		for k, v in pairs(checktable(otherProperty)) do
			if type(data[k]) == "function" then
				data[k](data, v)
			else
				logger:warn(string.format("%s has no property:%s", data.__cname, k))
			end
		end
	end
	return data
end

function DataManager:removeData(id)
	for i, v in ipairs(self._dataList) do
		if v:id() == id then
			table.remove(self._dataList, i)
			return v
		end
	end
end

function DataManager:clear()
	for i, v in ipairs(self._dataList) do
		v:dispose()
	end
	self._dataList = { }
end

function DataManager:getDataType()
	return require("libra.data.Object")
end

return DataManager