--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-15 17:30:05
--

local Panel = class("Panel", require("libra.ui.components.JPanel"))

function Panel:ctor(size)
	Panel.super.ctor(self, {bg = "ui/ty_erjikuang.png", size = size or cc.size(600, 400), closeBtnParam = {normal = "ui/ty_guanbi.png"}})
	self._closeBtn:addXY(-14, -14)
end

return Panel