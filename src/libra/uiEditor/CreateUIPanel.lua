--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 15:39:08
--

local Button = require('libra.ui.components.JButton')

local CreateUIPanel = class("CreateUIPanel", require("libra.ui.components.JPanel"))

function CreateUIPanel:ctor()
	CreateUIPanel.super.ctor(self, {bg = "uiEditor/panel_bg.png", isScale9 = true})
	self:setSize(400, 400)

	Button.new({normal = "uiEditor/closeBtn_normal.png", down = 'uiEditor/closeBtn_down.png'}, function ()
		self:close()
	end):pos(self._actualWidth / 2, self._actualHeight / 2):addToContainer(self)
end

return CreateUIPanel