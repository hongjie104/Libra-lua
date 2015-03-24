--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-20 16:43:10
--

LAST_REFERENCE_IMG = LAST_REFERENCE_IMG or nil

local Button = require('libra.ui.components.JButton')
local Label = require('libra.ui.components.JLabel')
local TextFieldWithTip = require('libra.ui.components.JTextFieldWithTip')

-- local ReferencePanel = class("ReferencePanel", require("libra.uiEditor.Panel"))
local ReferencePanel = class("ReferencePanel", require("libra.ui.components.JPanel"))

function ReferencePanel:ctor()--[[onShowReferenceImg]]
	ReferencePanel.super.ctor(self)
	self:setSize(display.width, display.height)

	require "lfs"
	local resList = getpathes(lfs.currentdir() .. "/res")
	for i, v in ipairs(resList) do
		resList[i] = string.gsub(v, ".*res/", "")
	end

	Button.new({normal = "uiEditor/btn_normal.png", down = "uiEditor/btn_down.png", label = {text = "关闭"}}, function ()
		self:close()
	end):align(display.LEFT_TOP, 0, display.top):addToContainer(self)

	Button.new({normal = "uiEditor/btn_normal.png", down = "uiEditor/btn_down.png", label = {text = "确定"}}, function ()
		LAST_REFERENCE_IMG = self._textField:getString()
		self:showReferenceImg()
	end):align(display.LEFT_TOP, 500, display.top):addToContainer(self)

	self._textField = TextFieldWithTip.new({tipDataList = resList, 
		x = 300, 
		y = display.top - 58 / 2,
		width = 300, 
		height = 58, 
		-- maxLength = 18,
		textFieldbg = "uiEditor/hint.png",
		isTextFieldbgScale9 = true,
		listViewBg = "uiEditor/s9List.png"}):addToContainer(self)
end

function ReferencePanel:show()
	ReferencePanel.super.show(self)
	self:showReferenceImg()
end

function ReferencePanel:showReferenceImg()
	if LAST_REFERENCE_IMG then
		if self._referenceImg then
			self._referenceImg:setTexture(LAST_REFERENCE_IMG)
		else
			self._referenceImg = require("libra.ui.components.JImage").new(LAST_REFERENCE_IMG):pos(display.cx, display.cy):addToContainer(self)
			self._referenceImg:setOpacity(128)
		end
	end
end

return ReferencePanel