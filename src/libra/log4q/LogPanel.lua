--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-15 17:31:56
--

local Label = require("libra.ui.components.JLabel")
local ListView = require("libra.ui.components.JListView")

local LogPanel = class("LogPanel", require("libra.uiController.Panel"))

function LogPanel:ctor()
	LogPanel.super.ctor(self)

	for i = 1, 100 do
		logger:debug("上的佛法马克思的福建省的对方的", i)
	end
	self._logList = logger:getLogList()

	self._listView = ListView.new({
		viewRect = cc.rect(0, 0, 600, 360),
		}):onTouchListener(handler(self, self.touchListener8))
		:addToContainer(self):pos(0, 20)
	self._listView:setDelegate(handler(self, self.sourceDelegate))
	self._listView:reload()
end

function LogPanel:sourceDelegate(listView, tag, idx)
	if TAG.COUNT_TAG == tag then
		return #self._logList
	elseif TAG.CELL_TAG == tag then
		local item = listView:dequeueItem()
		local content
		if not item then
			content = Label.new(
					{
						size = 20,
						align = cc.ui.TEXT_ALIGN_CENTER,
						color = cc.c3b(98, 29, 7)
					})
			item = listView:newItem(content)
		else
			content = item:getContent()
		end
		content:setString(self._logList[idx + 1])
		item:actualWidth(600):actualHeight(30)
		return item
	end
end

function LogPanel:touchListener8(event)
	local listView = event.listView
	if "clicked" == event.name then
		print("async list view clicked idx:" .. event.itemPos)
	end
end

return LogPanel