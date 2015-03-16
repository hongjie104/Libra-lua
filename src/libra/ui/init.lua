--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-12 20:42:49
--

local function actualWidth(self, int)
	if int then
		self._actualWidth = int
		return self
	end
	return self._actualWidth
end

local function actualHeight(self, int)
	if int then
		self._actualHeight = int
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
		self._border = display.newRect(cc.rect(self._actualWidth / -2, self._actualHeight / -2, self._actualWidth, self._actualHeight), 
			{borderColor = cc.c4f(0,1,0,1)}):addTo(self)
	end
	return self
end

local function closeBorder(self)
	if self._border then
		self._border:setVisible(false)
	end
end

local function addToContainer(self, container)
	local container = container or libraUIManager:getUIContainer()
	assert(container.isContainer, "libra.ui.init.addToContainer() - invalid container")
	assert(container:isContainer(), "libra.ui.init.addToContainer() - invalid container")
	if container ~= self then
		self:addTo(container)
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

	component._name = ''
    component.name = name

    component.showBorder = showBorder
    component.closeBorder = closeBorder
    component.addToContainer = addToContainer
end

-- Direction = {
-- 	HORIZONTAL = 0,
-- 	VERTICAL = 1
-- }

libraUIManager = require("libra.ui.managers.UIManager").new()