--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-01 13:08:06
--

local Item = class("Item", require("libra.data.Object"))

function Item:ctor()
	Item.super.ctor(self)
	self._count = 1
end

function Item:count(val)
	if val then
		self._count = val
		return self
	end
	return self._count
end

--- 读写Type,在写Type值进行配置数据的初始化
-- @override
function Item:type(int)
	if type(int) == "number" then
		self._type = int
		self._cfg = getConfig(self._type, "ItemConfig")
		assert(self._cfg, string.format("%s找不到Type为%d的配置", self.__cname, self._type))
		return self
	end
	return self._type
end

return Item