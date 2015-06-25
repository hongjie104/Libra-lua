--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:00:17
--

local UIManager = class("UIManager")

function UIManager:ctor()
	self._uiContainer = require("libra.ui.components.JContainer").new()
	self._uiContainer:setSize(display.width, display.height)
	self._uiContainer:retain()

	self._uiContainer:setKeypadEnabled(true)
	self._uiContainer:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
		logger:info("event.code = ", event.code, "event.key = ", event.key)
		if event.code == cc.KeyCode.KEY_DOWN_ARROW then
			-- Direction.TOP_TO_BOTTOM
		elseif event.code == cc.KeyCode.KEY_UP_ARROW then
			-- Direction.BOTTOM_TO_TOP
		elseif event.code == cc.KeyCode.KEY_LEFT_ARROW then
			-- Direction.RIGHT_TO_LEFT
		elseif event.code == cc.KeyCode.KEY_RIGHT_ARROW then
			-- Direction.LEFT_TO_RIGHT
		end
	end)
end

function UIManager:getUIContainer()
	return self._uiContainer
end

return UIManager