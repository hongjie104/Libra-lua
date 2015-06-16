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

	-- require("libra.uiEditor.IconBtn").new({normal = "uiEditor/uiEditorIco.jpg"}, function (icon)
	-- 	if not icon:isTouchMoved() then
	-- 		self._layer:setVisible(not self._layer:isVisible())
	-- 	end
	-- end):addToContainer(self)

	require("libra.uiEditor.Toolbar").new({
		showUIList = function ()
			require("libra.uiEditor.UIListPanel").new(function (uiConfig)
				require("libra.uiEditor.preview.UIPreviewPanel").new(uiConfig):pos(display.cx, display.cy):show(self._layer)
			end):show(self._layer)
		end,
		showCreateUIPanel = function ()
			require("libra.uiEditor.CreateUIPanel").new():show(self._layer)
		end,
		showReferencePanel = function ()
			require("libra.uiEditor.ReferencePanel").new():show(self._layer)
		end
		}):addToContainer(self._layer):align(display.TOP_LEFT, display.left, display.top)
end

return UIEditorContainer