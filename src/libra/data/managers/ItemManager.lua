--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-01 13:44:39
--

local ItemManager = class("ItemManager", require('libra.data.managers.DataManager'))

function ItemManager:ctor()
	ItemManager.super.ctor(self)
end

function ItemManager:getItemCount(id)
	local item = self:getData(id)
	if item then
		return item:count()
	else
		return 0
	end
end

function ItemManager:getItemCountByType(type)
	local count = 0
	for i, v in ipairs(self._dataList) do
		if v:type() == type then
			count = count + v:count()
		end
	end
	return count
end

function ItemManager:getDataType()
	return require("libra.data.Item")
end

return ItemManager