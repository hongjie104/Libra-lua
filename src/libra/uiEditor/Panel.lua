--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-20 16:45:44
--

local Button = require('libra.ui.components.JButton')

local Panel = class("Panel", require("libra.ui.components.JPanel"))

function Panel:ctor(width, height)
	Panel.super.ctor(self, {bg = "uiEditor/panel_bg.png", isScale9 = true, width = width, height = height})

	Button.new({normal = "uiEditor/closeBtn_normal.png", down = 'uiEditor/closeBtn_down.png'}, function ()
		self:close()
	end):align(display.RIGHT_TOP, width, height):addToContainer(self)
end

return Panel