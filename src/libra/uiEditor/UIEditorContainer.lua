--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 14:54:51
--

local Container = require("libra.ui.components.JContainer")

local UIEditorContainer = class("UIEditorContainer", Container)

function UIEditorContainer:ctor()
	UIEditorContainer.super.ctor(self)

	self._layer = Container.new():addToContainer(self)
	self._layer:setVisible(false)

	require("libra.uiEditor.IconBtn").new({normal = "uiEditor/uiEditorIco.jpg"}, function (icon)
		if not icon:isTouchMoved() then
			self._layer:setVisible(not self._layer:isVisible())
		end
	end):addToContainer(self)

	require("libra.uiEditor.Toolbar").new(
		handler(self, self.showCreateUIPanel),
		handler(self, self.ShowReferencePanel)
		):addToContainer(self._layer):align(display.CENTER, display.cx, display.top - 36)
end

function UIEditorContainer:showCreateUIPanel()
	require("libra.uiEditor.CreateUIPanel").new():show(self._layer)
end

--- 打开选取参考图的面板
function UIEditorContainer:ShowReferencePanel()
	require("libra.uiEditor.ReferencePanel").new():show(self._layer)
end

return UIEditorContainer
