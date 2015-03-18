--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 14:54:51
--

local UIEditorContainer = class("UIEditorContainer", require("libra.ui.components.JContainer"))

function UIEditorContainer:ctor()
	UIEditorContainer.super.ctor(self)

	require("libra.uiEditor.IconBtn").new({normal = "uiEditor/uiEditorIco.jpg"}, function (self)
		if not self:isTouchMoved() then
			logger:info('icon被点击了!')
		end
	end):addToContainer(self, 1000)

	require("libra.uiEditor.Toolbar").new(
		handler(self, self.showCreateUIPanel)
		):addToContainer(self):align(display.CENTER, display.cx, display.top - 36)
end

function UIEditorContainer:showCreateUIPanel()
	require("libra.uiEditor.CreateUIPanel").new():pos(display.cx, display.cy):show(self)
end

return UIEditorContainer
