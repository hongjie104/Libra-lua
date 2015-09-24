--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-15 17:31:56
--

local Label     = require("libra.ui.components.JLabel")
local ListView  = require("libra.ui.components.JListView")
local TextField = require("libra.ui.components.JTextField")
local Button    = require("libra.ui.components.JButton")

local LogPanel = class("LogPanel", require("libra.uiController.Panel"))

local PANEL_WIDTH, PANEL_HEIGHT = display.width - 100, display.height - 100

function LogPanel:ctor()
	LogPanel.super.ctor(self, cc.size(PANEL_WIDTH, PANEL_HEIGHT))

	self._logList = logger:getLogList()
	self._listView = ListView.new({
			viewRect = cc.rect(0, 0, PANEL_WIDTH - 100, PANEL_HEIGHT - 200),
		})
		-- :onTouchListener(handler(self, self.onLogItemTouched))
		:addToContainer(self):pos(50, 150)
	self._listView:setDelegate(handler(self, self.listViewSourceDelegate))
	self._listView:reload()

	-- 发送消息的UI
	local inputLabel = Label.new({text = _("指令输入框:"), color = cc.c3b(98, 29, 7)}):addToContainer(self):align(display.CENTER_LEFT, 50, 90)
	self._inputField = TextField.new({isEditBox = true, image = "img_alpha.png", size = cc.size(460, 36)})
		:addToContainer(self):align(display.CENTER_LEFT, 50 + inputLabel:actualWidth(), 90)
	self._inputField:setFontColor(display.COLOR_GREEN)
	self._inputField:setPlaceHolder(_("{opCode [opName param] | command [key value]}"))
	self._inputField:setText(localDump:get("GMCommond") or "2001 CreateCharacter nickName=abc,gender=1,type=2")

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
						paramTable[keyVal[1]] = unserialize(keyVal[2])
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
			localDump:save("GMCommond", self._inputField:getText())
			local strTable = string.split(self._inputField:getText(), " ")
			if #strTable > 1 or strTable[1] ~= '' then
				local command = strTable[1]
				table.remove(strTable, 1)
				socketHandler:sendJson(command, strTable)
			end
		end)
end

function LogPanel:listViewSourceDelegate(listView, tag, idx)
	if TAG.COUNT_TAG == tag then
		return #self._logList
	elseif TAG.CELL_TAG == tag then
		local item = listView:dequeueItem()
		local content
		if not item then
			content = Label.new(
					{
						size = 20,
						align = cc.ui.TEXT_ALIGN_LEFT,
						color = cc.c3b(98, 29, 7),
						dimensions = cc.size(PANEL_WIDTH - 100, 0)
					})
			item = listView:newItem(content)
		else
			content = item:getContent()
		end
		content:setString(self._logList[idx])
		item:actualWidth(PANEL_WIDTH - 100):actualHeight(content:getContentSize().height)
		return item
	end
end

-- function LogPanel:onLogItemTouched(event)
-- 	local listView = event.listView
-- 	if "clicked" == event.name then
-- 		print("async list view clicked idx:" .. event.itemPos)
-- 	end
-- end

function LogPanel:close(animation, direct)
	LogPanel.super.close(self, animation, direct)
	uiManager:resetActiveContainer()
	localDump:saveToLocal()
end

--- 处理返回键的逻辑，如果需要用到返回键，那么该方法的返回值必须得是true
function LogPanel:doBackHandler()
	self:close()
	return true
end

return LogPanel