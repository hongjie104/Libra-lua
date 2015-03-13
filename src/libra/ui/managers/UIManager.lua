--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:00:17
--

local UIManager = class("UIManager")

function UIManager:ctor()
	self._uiContainer = require("libra.ui.components.JContainer").new()
	self._uiContainer:retain()
end

function UIManager:getUIContainer()
	return self._uiContainer
end

return UIManager