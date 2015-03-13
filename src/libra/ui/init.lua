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

function makeUIComponent(component)
    component:setCascadeOpacityEnabled(true)
    component:setCascadeColorEnabled(true)
    component:addNodeEventListener(cc.NODE_EVENT, function(event)
        if event.name == "cleanup" then
            component:removeAllEventListeners()
        end
    end)

    component._actualWidth, component._actualHeight = 0, 0
    component.actualWidth = actualWidth
    component.actualHeight = actualHeight

    local size = component:getContentSize()
	component:actualWidth(size.width)
	component:actualHeight(size.height)
end