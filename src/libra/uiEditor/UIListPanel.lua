--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-24 21:51:31
--

local Button    = require('libra.ui.components.JButton')
local Label     = require('libra.ui.components.JLabel')
local TextField = require('libra.ui.components.JTextField')
local ListView  = require('libra.ui.components.JListView')
local MsgPanel  = require('libra.ui.components.JMsgPanel')

local UIListPanel = class("UIListPanel", require("libra.uiEditor.Panel"))

function UIListPanel:ctor(showUIPreviewPanel)
	UIListPanel.super.ctor(self, 600, 400)

	local listViewRect = cc.rect(10, 10, 160, self._actualHeight - 50)
	Label.new({text = "UI列表"}):align(display.CENTER_BOTTOM, listViewRect.x + listViewRect.width / 2, listViewRect.y + listViewRect.height):addToContainer(self)
	local listView = ListView.new({
		viewRect = listViewRect,
		bg = "uiEditor/s9List.png",
		isScale9 = true
		}):addToContainer(self)
		:onTouchListener(handler(self, self.onUIListViewTouch))
	listView:setDelegate(handler(self, self.uiListViewDelegate))
	listView:reload()

	Label.new({text = 'UI名称:'}):align(display.LEFT_TOP, listViewRect.x + listViewRect.width + 10, listViewRect.y + listViewRect.height):addToContainer(self)
	local textFieldBG = require("libra.ui.components.JImage").new("uiEditor/hint.png"):addToContainer(self):align(display.LEFT_CENTER, listViewRect.x + listViewRect.width + 100, listViewRect.y + listViewRect.height - 10)
	self._uiName = TextField.new({placeHolder = "UI名称", size = cc.size(120, 30), fontSize = 24}):align(display.LEFT_CENTER, textFieldBG:x() + 10, textFieldBG:y()):addToContainer(self)

	Label.new({text = 'UI ID:'}):align(display.LEFT_TOP, listViewRect.x + listViewRect.width + 10, listViewRect.y + listViewRect.height - 70):addToContainer(self)
	textFieldBG = require("libra.ui.components.JImage").new("uiEditor/hint.png"):addToContainer(self):align(display.LEFT_CENTER, listViewRect.x + listViewRect.width + 100, listViewRect.y + listViewRect.height - 80)
	self._uiID = TextField.new({placeHolder = "UI ID", size = cc.size(120, 30), fontSize = 24}):align(display.LEFT_CENTER, textFieldBG:x() + 10, textFieldBG:y()):addToContainer(self)

	Button.new({normal = "btnRed2_normal.png", down = "btnRed2_down.png", label = {text = "预览"}}, function ()
		if self._uiIndex > 0 then
			showUIPreviewPanel(UI_CONFIG[self._uiIndex])
			self:close()
		else
			MsgPanel.new({isScale9 = true, img = "uiEditor/scale9_darkBrown.png", imgSize = cc.size(200, 100), text = "请选择一个UI先"}):show()
		end
	end):align(display.TOP_CENTER, 300, self._uiName:y() - 100):addToContainer(self)

	Button.new({normal = "btnRed2_normal.png", down = "btnRed2_down.png", label = {text = "新建"}}, function ()
		local uiName = self._uiName:getString()
		if uiName == '' then
			MsgPanel.new({isScale9 = true, img = "uiEditor/scale9_darkBrown.png", imgSize = cc.size(200, 100), text = '输入UI名字先'}):show()
		else
			for _, v in ipairs(UI_CONFIG) do
				if v.name == uiName then
					MsgPanel.new({isScale9 = true, img = "uiEditor/scale9_darkBrown.png", imgSize = cc.size(400, 100), text = string.format('已存在名字为%s的UI了', uiName)}):show()
					return
				end
			end
			local uiID = self._uiID:getString()
			if uiID == '' then
				MsgPanel.new({isScale9 = true, img = "uiEditor/scale9_darkBrown.png", imgSize = cc.size(200, 100), text = '输入UI ID先'}):show()
			else
				for _, v in ipairs(UI_CONFIG) do
					if v.id == uiID then
						MsgPanel.new({isScale9 = true, img = "uiEditor/scale9_darkBrown.png", imgSize = cc.size(400, 100), text = string.format('已存在ID为%s的UI了', uiID)}):show()
						return
					end
				end
			end
			UI_CONFIG[#UI_CONFIG + 1] = {id = uiID, name = uiName, uiConfig = { }}
			listView:reload()
			MsgPanel.new({isScale9 = true, img = "uiEditor/scale9_darkBrown.png", imgSize = cc.size(300, 100), text = string.format('添加%s成功', uiName)}):show()
		end
	end):align(display.TOP_CENTER, 430, self._uiName:y() - 100):addToContainer(self)

	self._uiIndex = 0
end

function UIListPanel:onUIListViewTouch(event)
	if "clicked" == event.name then
		self._uiIndex = event.itemPos
		self._uiName:setString(UI_CONFIG[self._uiIndex].name)
		self._uiID:setString(UI_CONFIG[self._uiIndex].id)
	end
end

function UIListPanel:uiListViewDelegate(listView, tag, idx)
	if TAG.COUNT_TAG == tag then
		return #UI_CONFIG
	elseif TAG.CELL_TAG == tag then
		local content = nil
		local item = listView:dequeueItem()
		if item then
			content = item:getContent()
		else
			content = Label.new({text = "", size = 20, align = cc.ui.TEXT_ALIGN_CENTER, color = display.COLOR_WHITE})
			item = listView:newItem(content)
		end
		content:setString(UI_CONFIG[idx].name)
		item:actualWidth(160):actualHeight(30)
		return item
	end
end

return UIListPanel