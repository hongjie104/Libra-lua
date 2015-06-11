--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-12 20:45:32
--

import(".ui.init")
-- import(".data.init")
import(".utils.init")
import(".log4q.init")

if LUA_UPDATE then 
	-- 在win平台,才开启代码热更新机制
	if device.platform == "windows" then
		import(".luaUpdate.init")
	end
end

if LUA_UI_EDITOR then
	import(".uiEditor.init")
end

-- 扩展一下Node
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

function Node:addXY(x, y)
	local oldX, oldY = self:getPosition()
	self:setPosition(oldX + x, oldY + y)
	return self
end

function Node:isPointIn(x, y)
	return self:getCascadeBoundingBox():containsPoint(cc.p(x, y))
end

--- 本地热更新启用时
-- 每次require都必然多出一个类表,它是一个新实例被成员函数当做upvalue引用(所有super调用)
-- 如果添加了一个函数到类里面，之前创建的旧实例会自动获得到这个函数
-- 不支持任何成员函数对upvalue的数值操作 比如: "MyClass._varName" 这种
if device.platform == "windows" then
	local orgRequire = require
	local function isCLib(path)
		return path == "bit"
			or path == "string"
			or path == "math"
			or path == "protobuf.c"
	end

	function require(path)
		if not isCLib(path) then
			local oldVal = package.loaded[path]
			package.loaded[path] = nil

			local newVal = orgRequire(path)
			if type(oldVal)=="table" and type(newVal)=="table" then
				for k, v in pairs(newVal) do
					oldVal[k] = v
				end
				package.loaded[path] = oldVal
			else
				package.loaded[path] = newVal
			end
			return package.loaded[path]
		else
			return orgRequire(path)
		end
	end
end