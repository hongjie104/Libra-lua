--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-24 21:51:31
--

local Button = require('libra.ui.components.JButton')
local Label = require('libra.ui.components.JLabel')
local ListView = require('libra.ui.components.JListView')
local MsgPanel = require('libra.ui.components.JMsgPanel')

local UIListPanel = class("UIListPanel", require("libra.uiEditor.Panel"))

function UIListPanel:ctor(showUIPreviewPanel)
	UIListPanel.super.ctor(self, 600, 400)

	local listViewRect = cc.rect((display.width - self._actualWidth) / 2 + 10, (display.height - self._actualHeight) / 2 + 10, 160, self._actualHeight - 50)
	Label.new({text = "UI列表"}):align(display.CENTER_BOTTOM, listViewRect.x + listViewRect.width / 2, listViewRect.y + listViewRect.height):addToContainer(self)
	local listView = ListView.new({
		viewRect = listViewRect,
		bg = "uiEditor/s9List.png",
		isScale9 = true
		}):addToContainer(self)
		:onTouchListener(handler(self, self.onUIListViewTouch))
	listView:setDelegate(handler(self, self.uiListViewDelegate))
	listView:reload()

	self._selectedUI = Label.new({text = ""}):align(display.TOP_CENTER, display.cx, listViewRect.height + (display.height - self._actualHeight) / 2):addToContainer(self)
	Button.new({normal = "btnRed2_normal.png", down = "btnRed2_down.png", label = {text = "预览"}}, function ()
		if self._uiIndex > 0 then
			showUIPreviewPanel(UI_CONFIG[self._uiIndex].uiConfig)
			self:close()
		else
			MsgPanel.new({isScale9 = true, img = "uiEditor/scale9_darkBrown.png", imgSize = cc.size(200, 100), text = "请选择一个UI先"}):show(self)
		end
	end):align(display.TOP_CENTER, display.cx, self._selectedUI:y() - 30):addToContainer(self)

	self._uiIndex = 0
end

function UIListPanel:onUIListViewTouch(event)
	if "clicked" == event.name then
		self._uiIndex = event.itemPos
		self._selectedUI:setString(UI_CONFIG[self._uiIndex].name)
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