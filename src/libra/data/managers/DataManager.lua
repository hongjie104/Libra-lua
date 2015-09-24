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

--指定位置插入数据
function DataManager:insertData(type, id, pos)
	local data = self:getData(id)
	if not data then
		data = self:getDataType().new()
		data:type(type)
		data:id(id)
		table.insert(self._dataList, pos, data)
	end
	return data
end

function DataManager:updateData(id, otherProperty, data)
	local data = data or self:getData(id)
	if data then
		local hasWarn = false
		for k, v in pairs(checktable(otherProperty)) do
			if type(data[k]) == "function" then
				data[k](data, v)
			else
				logger:warn(string.format("%s has no property:%s, value:%s", data.__cname, k, tostring(v)))
				hasWarn = true
			end
		end
		if hasWarn then
			logger:info("=====================================================================")
		end
		if data.count and type(data.count) == "function" then
			if data:count() < 1 then
				self:removeData(data:id())
				logger:info(data:id(), data:name(), "被删除")
			end
		end
	else
		-- 如果没有data，说明是新加的data，那就先添加，然后再update
		self:updateData(id, otherProperty, self:addData(otherProperty.typeId, id))
	end
	return data
end

function DataManager:removeData(id)
	for i, v in ipairs(self._dataList) do
		if v:id() == id then
			table.remove(self._dataList, i)
			return v, i
		end
	end
end

function DataManager:clear()
	for i, v in ipairs(self._dataList) do
		if v.dispose and type(v.dispose) == "function" then
			v:dispose()
		end
	end
	self._dataList = { }
end

function DataManager:getDataList()
	return self._dataList
end

--- 获取数据类
-- 需要被子类重写，不同的管理类需要的数据类不同
function DataManager:getDataType()
	return require("libra.data.Object")
end

return DataManager