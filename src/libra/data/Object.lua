--
-- 所有对象的父类，只有一些最基本的字段和方法
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-16 20:45:24
--

local Object = class("Object")

function Object:ctor()
	-- id, type, 名字, 描述
	self._id, self._type, self._name, self._des = 0, 0, '', ''
end

function Object:id(int)
	if int then
		self._id = int
		return self
	end
	return self._id
end

function Object:type(int)
	if int then
		self._type = int
		self._cfg = { }
		return self
	end
	return self._type
end

--- 获取配置文件
function Object:cfg(...)
	assert(not ..., string.format("%s的cfg方法不可有参数", self.__cname))
	return self._cfg
end

function Object:name(str)
	if str then
		self._name = str
		return self
	end
	return self._name
end

function Object:des(str)
	if str then
		self._des = str
		return self
	end
	return self._des
end

function Object:dispose()
	
end

return Object