--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 14:34:04
--

local Button = require("libra.ui.components.JButton")

local Toolbar = class("Toolbar", require("libra.ui.components.JContainer"))

function Toolbar:ctor(param)
	Toolbar.super.ctor(self)
	self:setSize(display.width, 66)

	-- UI列表
	Button.new({normal = "uiEditor/btn_normal.png", down = "uiEditor/btn_down.png", 
		label = {text = "UI列表"}}, function ()
			-- onShowCreateUIPanel()
			param.showUIList()
		end):addToContainer(self)

	-- 新建按钮
	Button.new({normal = "uiEditor/btn_normal.png", down = "uiEditor/btn_down.png", 
		label = {text = "新建"}}, function ()
			-- onShowCreateUIPanel()
		end):addToContainer(self)

	-- 载入示意图按钮
	Button.new({normal = "uiEditor/btn_normal.png", down = "uiEditor/btn_down.png", 
		label = {text = "载入图"}}, function ()
			-- onShowCreateUIPanel()
			-- onShowReferencePanel()
		end):addToContainer(self)

	self:setLayout(require("libra.ui.layout.BoxLayout").new(self._componentList))
	self:updateLayout()
end

return Toolbar
