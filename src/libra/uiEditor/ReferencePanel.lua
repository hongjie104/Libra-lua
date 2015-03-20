--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-20 16:43:10
--

local Button = require('libra.ui.components.JButton')
local Label = require('libra.ui.components.JLabel')
local TextFieldWithTip = require('libra.ui.components.JTextFieldWithTip')

local ReferencePanel = class("ReferencePanel", require("libra.uiEditor.Panel"))

function ReferencePanel:ctor()
	ReferencePanel.super.ctor(self, 400, 400)

	require "lfs"
	local resList = getpathes(lfs.currentdir() .. "/res")
	for i, v in ipairs(resList) do
		resList[i] = string.gsub(v, ".*res/", "")
	end
	TextFieldWithTip.new({tipDataList = resList, 
		x = display.cx, 
		y = display.cy, 
		width = 210, 
		height = 58, 
		maxLength = 18,
		textFieldbg = "uiEditor/hint.png",
		listViewBg = "uiEditor/s9List.png"}):addToContainer(self)
end

return ReferencePanel