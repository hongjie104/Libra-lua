--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 13:38:54
--

local BaseLayout = class("BaseLayout")

function BaseLayout:ctor(componentList)
	-- self._componentList = {}
	self._componentList = componentList
end

-- function BaseLayout:addComponent(...)
-- 	for _, v in pairs({...}) do
-- 		if not talbe.indexof(self._componentList, v) then
-- 			self._componentList[#self._componentList + 1] = v
-- 		end
-- 	end
-- end

-- function BaseLayout:removeComponent(component)
-- 	table.removebyvalue(self._componentList, component)
-- end

function BaseLayout:updateLayout()
	-- do nothing
end

return BaseLayout