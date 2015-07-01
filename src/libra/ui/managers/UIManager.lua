--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:00:17
--

local UIManager = class("UIManager")

function UIManager:ctor()
	-- ui容器，所有的ui组件都应该放在这里容器之中
	self._uiContainer = require("libra.ui.components.JContainer").new()
	self._uiContainer:setSize(display.width, display.height)
	self._uiContainer:retain()

	-- 注册按键事件
	self._uiContainer:setKeypadEnabled(true)
	self._uiContainer:addNodeEventListener(cc.KEYPAD_EVENT, handler(self, self.onKeyPadEvent))

	-- 当前激活的面板容器
	self._activeContainer = self._uiContainer
end

function UIManager:activeContainer(val)
	if val then
		self._activeContainer = val
		return self
	end
	return self._activeContainer
end

-- @private
function UIManager:onKeyPadEvent(event)
	if self._activeContainer then
		if event.name == "Pressed" then
			self._activeContainer:onKeyPressed(event.code)
		elseif event.name == "Released" then
			self._activeContainer:onKeyReleased(event.code)
		end
	end
end

function UIManager:getUIContainer()
	return self._uiContainer
end

return UIManager