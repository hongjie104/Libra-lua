--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-12 20:42:49
--

local function actualWidth(self, int)
	if int then
		if self._actualWidth ~= int then
			self._actualWidth = int
			self:setContentSize(self._actualWidth, self._actualHeight)
		end
		return self
	end
	return self._actualWidth
end

local function actualHeight(self, int)
	if int then
		if self._actualHeight ~= int then
			self._actualHeight = int
			self:setContentSize(self._actualWidth, self._actualHeight)
		end
		return self
	end
	return self._actualHeight
end

local function name(self, str)
	if str then
		self._name = str
		return self
	end
	return self._name
end

local function showBorder(self)
	if self._border then
		self._border:setVisible(true)
	else
		-- self._border = display.newRect(cc.rect(self._actualWidth / -2, self._actualHeight / -2, self._actualWidth, self._actualHeight), 
		-- 	{borderColor = cc.c4f(0,1,0,1)}):addTo(self)
		self._border = display.newScale9Sprite("uiEditor/border.png", 0, 0, self:getContentSize()):addTo(self)
	end
	return self
end

local function closeBorder(self)
	if self._border then
		self._border:setVisible(false)
	end
end

local function addToContainer(self, container, zOrder)
	local container = container or libraUIManager:getUIContainer()
	assert(type(container.isContainer) == "function" and container:isContainer(), "libra.ui.init.addToContainer() - invalid container")
	if container ~= self then
		container:addComponent(self, zOrder)
	end
	return self
end

function makeUIComponent(component)
    component:setCascadeOpacityEnabled(true)
    component:setCascadeColorEnabled(true)

    component._actualWidth, component._actualHeight = 0, 0
    component.actualWidth = actualWidth
    component.actualHeight = actualHeight

    local size = component:getContentSize()
	component:actualWidth(size.width)
	component:actualHeight(size.height)

	component._name = component.class.__cname
    component.name = name

    component.showBorder = showBorder
    component.closeBorder = closeBorder
    component.addToContainer = addToContainer
end

import(".event")

Direction = {
	BOTH = 0,
	VERTICAL = 1,
	HORIZONTAL = 2,
	LEFT_TO_RIGHT = 3,
	RIGHT_TO_LEFT = 4,
	TOP_TO_BOTTOM = 5,
	BOTTOM_TO_TOP = 6
}

TAG = {
	COUNT_TAG       = "Count",
	CELL_TAG        = "Cell",
	UNLOAD_CELL_TAG = "UnloadCell"
}

UI_CONFIG = UI_CONFIG or { }

libraUIManager = require("libra.ui.managers.UIManager").new()