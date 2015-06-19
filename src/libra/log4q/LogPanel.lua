--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-15 17:31:56
--

local Label = require("libra.ui.components.JLabel")
local ListView = require("libra.ui.components.JListView")

local LogPanel = class("LogPanel", require("libra.uiController.Panel"))

local PANEL_WIDTH, PANEL_HEIGHT = display.width - 100, display.height - 100

function LogPanel:ctor()
	LogPanel.super.ctor(self, cc.size(PANEL_WIDTH, PANEL_HEIGHT))

	-- for i = 1, 4 do
	-- 	logger:debug("上的佛法马克思的福建省的对方的", i, "ddsfdsfdsfdsfd12321321fdfffffffffffffd")
	-- end
	self._logList = logger:getLogList()

	self._listView = ListView.new({
			viewRect = cc.rect(0, 0, PANEL_WIDTH - 100, PANEL_HEIGHT - 100),
		})
		-- :onTouchListener(handler(self, self.onLogItemTouched))
		:addToContainer(self):pos(50, 50)
	self._listView:setDelegate(handler(self, self.listViewSourceDelegate))
	self._listView:reload()
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

return LogPanel