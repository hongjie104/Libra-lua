--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-17 20:58:50
--

local icon = require("libra.ui.components.JButton").new({normal = "res/ico.jpg"}, nil, {onTouchEnded = function (self, evt)
	if not self:isTouchMoved() then
		print("aaa")
	end
end}):addToContainer(nil, 99999)

local function onDragHandler(evt)
	if evt.name == "began" then
		return true
	elseif evt.name == "moved" then
		icon:addXY(evt.x - evt.prevX, evt.y - evt.prevY)
	end
end

icon:addNodeEventListener(cc.NODE_TOUCH_EVENT, onDragHandler)
