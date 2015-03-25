--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 15:39:08
--

local Button = require('libra.ui.components.JButton')
local Label = require('libra.ui.components.JLabel')
local ListView = require('libra.ui.components.JListView')

local CreateUIPanel = class("CreateUIPanel", require("libra.uiEditor.Panel"))

function CreateUIPanel:ctor()
	CreateUIPanel.super.ctor(self, 600, 400)

	-- local listViewRect = cc.rect((display.width - self._actualWidth) / 2 + 10, (display.height - self._actualHeight) / 2 + 10, 160, 350)
	-- Label.new({text = "组件"}):align(display.CENTER_BOTTOM, listViewRect.x + listViewRect.width / 2, listViewRect.y + listViewRect.height):addToContainer(self)
	-- local listView = ListView.new({
	-- 	viewRect = listViewRect,
	-- 	bg = "uiEditor/s9List.png",
	-- 	isScale9 = true
	-- 	}):addToContainer(self)
	-- 	:onTouchListener(handler(self, self.onComponentsListViewTouch))
	-- listView:setDelegate(handler(self, self.componentsListViewDelegate))
	-- listView:reload()

	
end



-- function CreateUIPanel:onComponentsListViewTouch(event)
-- 	if "clicked" == event.name then
-- 		print("async list view clicked idx:" .. event.itemPos)
-- 	end
-- end

-- function CreateUIPanel:componentsListViewDelegate(listView, tag, idx)
-- 	if TAG.COUNT_TAG == tag then
-- 		return #COMPONENT_LIST
-- 	elseif TAG.CELL_TAG == tag then
-- 		local content = nil
-- 		local item = listView:dequeueItem()
-- 		if item then
-- 			content = item:getContent()
-- 		else
-- 			content = Label.new({text = "", size = 20, align = cc.ui.TEXT_ALIGN_CENTER, color = display.COLOR_WHITE})
-- 			item = listView:newItem(content)
-- 		end
-- 		content:setString(COMPONENT_LIST[idx].name)
-- 		item:actualWidth(160):actualHeight(30)
-- 		return item
-- 	end
-- end

return CreateUIPanel