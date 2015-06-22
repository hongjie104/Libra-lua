--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 14:34:04
--

local Button   = require("libra.ui.components.JButton")
local MsgPanel = require('libra.ui.components.JMsgPanel')

local Toolbar = class("Toolbar", require("libra.ui.components.JContainer"))

function Toolbar:ctor(param)
	param.width, param.height = display.width, 66
	Toolbar.super.ctor(self, param)

	-- UI列表
	Button.new({normal = "uiEditor/btn_normal.png", down = "uiEditor/btn_down.png", 
		label = {text = "UI列表"}}, function ()
			-- onShowCreateUIPanel()
			param.showUIList()
		end):addToContainer(self)

	-- UI列表
	Button.new({normal = "uiEditor/btn_normal.png", down = "uiEditor/btn_down.png", 
		label = {text = "保存"}}, function ()
			-- 保存UI_CONFIG
			require "lfs"
			local path = lfs.currentdir() .. "/src/app/uiConfig.lua"
			local content = string.format("return %s", serialize(UI_CONFIG))
			content = string.gsub(content, "},{", "},\n{")
			local msg = io.writefile(path, content) and '保存UI_CONGIG成功' or '保存UI_CONFIG失败'
			MsgPanel.new({isScale9 = true, img = "uiEditor/scale9_darkBrown.png", imgSize = cc.size(300, 100), text = msg}):show()
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

	self:setLayout(require("libra.ui.layout.BoxLayout").new(self._componentList, true))
	self:updateLayout()
end

return Toolbar