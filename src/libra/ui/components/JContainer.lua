--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:01:02
--

local JContainer = class("JContainer", function ()
	return display.newNode()
end)

-- @param param {bg="背景图", isScale9 = true}
function JContainer:ctor(param)
	self._param = param
	makeUIComponent(self)
	self._componentList = {}
end

function JContainer:setSize(width, height)
	self:actualWidth(width):actualHeight(height)
	if self._param.bg then
		if self._bg then
			if self._param.isScale9 then
				self._bg:setContentSize(cc.size(width, height))
			end
		else
			if self._param.isScale9 then
				self._bg = display.newScale9Sprite(self._param.bg, 0, 0, cc.size(width, height)):addTo(self, -1)
			else
				display.newSprite(self._param.bg):addTo(self, -1)
			end
		end
	end
	return self
end

function JContainer:getSize()
	return self._actualWidth, self._actualHeight
end

function JContainer:isContainer()
	return true
end

function JContainer:addComponent(component)
	if not table.indexof(self._componentList, component) then
		self:addChild(component)
		self._componentList[#self._componentList + 1] = component
	end
end

function JContainer:getComponent(name)
	if name and name == '' then
		for _, v in ipairs(self._componentList) do
			if v:name() == name then return v end
		end
	end
end

function JContainer:clearComponents()
	self:removeAllChildren()
	self._componentList = {}
end

function JContainer:updateLayout()
	if self._layout then
		self._layout:updateLayout()
	end
end

function JContainer:setLayout(val)
	self._layout = val
	return self
end

return JContainer