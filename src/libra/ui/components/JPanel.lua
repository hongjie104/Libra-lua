--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:44:18
--

local JPanel = class("JPanel", require("libra.ui.components.JContainer"))

function JPanel:ctor()
	JPanel.super.ctor(self)
	display.newSprite("imgIcoBg30.png"):addTo(self)
end

function JPanel:show()
	self:addToContainer()
end

function JPanel:close()
	self:removeSelf()
end

return JPanel