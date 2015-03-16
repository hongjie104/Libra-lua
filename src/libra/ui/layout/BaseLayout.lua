--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 13:38:54
--

local BaseLayout = class("BaseLayout")

function BaseLayout:ctor(componentList)
	self._componentList = componentList
end

function BaseLayout:updateLayout()
	-- do nothing
end

return BaseLayout