--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-12 20:45:32
--

import(".ui.init")
import(".log4q.init")
if LUA_UPDATE then 
	-- 在win平台,才开启代码热更新机制
	if device.platform == "windows" then
		import(".luaUpdate.init")
	end
end

logger = import(".log4q.Logger")

local Node = cc.Node

function Node:x(int)
	if int then
		self:setPosition(cc.p(int, self:y()))
		return self
	end
    return self:getPositionX()
end

function Node:y(int)
	if int then
		self:setPosition(cc.p(self:x(), int))
		return self
	end
    return self:getPositionY()
end

function Node:isPointIn(x, y)
	return self:getCascadeBoundingBox():containsPoint(cc.p(x, y))
end