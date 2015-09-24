--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-07-04 10:39:43
--

local TextField = require("libra.ui.components.JTextField")
local Label     = require("libra.ui.components.JLabel")
local Button    = require("libra.ui.components.JButton")

local PANEL_WIDTH, PANEL_HEIGHT = display.width - 100, display.height - 100

local DebugPanel = class("DebugPanel", require("libra.uiController.Panel"))

function DebugPanel:ctor()
	DebugPanel.super.ctor(self, cc.size(PANEL_WIDTH, PANEL_HEIGHT))

	local inputLabel = Label.new({text = _("指令输入框:"), color = cc.c3b(98, 29, 7)}):addToContainer(self):align(display.CENTER_LEFT, 50, 50)
	self._inputField = TextField.new({isEditBox = true, image = "img_alpha.png", size = cc.size(460, 36)})
		:addToContainer(self):align(display.CENTER_LEFT, 50 + inputLabel:actualWidth(), 50)
	self._inputField:setFontColor(display.COLOR_GREEN)
	self._inputField:setPlaceHolder(_("{opCode [opName param] | command [key value]}"))
	self._inputField:setText("2001 CreateCharacter nickName=abc,gender=1,type=2")

	-- 发送谷歌协议的按钮
	Button.new({normal = "ui/ty_anniu02.png", label = {text = _("Proto")}}):addToContainer(self):pos(PANEL_WIDTH - 180, 50)
		:addEventListener(BUTTON_EVENT.CLICKED, function ()
			local strTable = string.split(self._inputField:getText(), " ")
			if #strTable > 1 or strTable[1] ~= '' then
				local paramTable = { }
				for i = 3, #strTable do
					local ary = string.split(strTable[i], ",")
					for i,v in ipairs(ary) do
						local keyVal = string.split(v, "=")
						local val = checkint(keyVal[2])
						if val == 0 then
							paramTable[keyVal[1]] = keyVal[2]
						else
							paramTable[keyVal[1]] = val
						end
					end
				end

				if strTable[2] == "nil" then
					socketHandler:send(strTable[1], nil, paramTable)
				else
					socketHandler:send(strTable[1], strTable[2], paramTable)
				end
			end
		end)

	Button.new({normal = "ui/ty_anniu02.png", label = {text = _("Json")}}):addToContainer(self):pos(PANEL_WIDTH - 80, 50)
		:addEventListener(BUTTON_EVENT.CLICKED, function ()
			local strTable = string.split(self._inputField:getText(), " ")
			if #strTable > 1 or strTable[1] ~= '' then
				local command = strTable[1]
				table.remove(strTable, 1)
				socketHandler:sendJson(command, strTable)
			end
		end)
end

function DebugPanel:close(animation, direct)
	DebugPanel.super.close(self, animation, direct)
	uiManager:resetActiveContainer()
end

--- 处理返回键的逻辑，如果需要用到返回键，那么该方法的返回值必须得是true
function DebugPanel:doBackHandler()
	self:close()
	return true
end

return DebugPanel