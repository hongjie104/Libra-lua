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
    component:addNodeEventListener(cc.NODE_EVENT, function(event)
        if event.name == "cleanup" then
            component:removeAllEventListeners()
        end
    end)

    component.addToContainer = addToContainer

    component._actualWidth, component._actualHeight = 0, 0
    component.actualWidth = actualWidth
    component.actualHeight = actualHeight

    local size = component:getContentSize()
	component:actualWidth(size.width)
	component:actualHeight(size.height)

	component._name = ''
    component.name = name
end

-- Direction = {
-- 	HORIZONTAL = 0,
-- 	VERTICAL = 1
-- }

libraUIManager = require("libra.ui.managers.UIManager").new()