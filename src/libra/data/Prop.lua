--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-16 20:45:24
--

local Prop = class("Prop")

function Prop:ctor()
	self._id, self._type, self._name, self._dis = 0, 0, '', ''
end

function Prop:id(int)
	if int then
		self._id = int
		return self
	end
	return self._id
end

function Prop:type(int)
	if int then
		self._type = int
		return self
	end
	return self._type
end

function Prop:name(str)
	if str then
		self._name = str
		return self
	end
	return self._name
end

function Prop:id(str)
	if str then
		self._des = str
		return self
	end
	return self._des
end

return Prop