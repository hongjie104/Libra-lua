--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-20 17:03:06
--

local TextField = import('.JTextField')
local ListView = import('.JListView')
local Image = import('.JImage')
local Label = import('.JLabel')

local JTextFieldWithTip = class("JTextFieldWithTip", require("libra.ui.components.JContainer"))

-- function JTextFieldWithTip:ctor(tipDataList, x, y, width, height, textFieldbg)
function JTextFieldWithTip:ctor(param)
	assert(param, "JTextFieldWithTip:class() - invalid param:param is nil")
	assert(param.width, "JTextFieldWithTip:class() - invalid param:param.width is nil")
	assert(param.height, "JTextFieldWithTip:class() - invalid param:param.height is nil")
	param.x = param.x or display.cx
	param.y = param.y or display.cy

	JTextFieldWithTip.super.ctor(self)

	self._tipDataList = param.tipDataList
	self._width = param.width
	self._filterTipDataList = { }

	if param.textFieldbg then
		Image.new(param.textFieldbg, {scale9 = param.isTextFieldbgScale9, size = cc.size(param.width, param.height)}):addToContainer(self):pos(param.x, param.y)
	end
	self._textField = TextField.new({placeHolder = "input here!", size = cc.size(param.width, param.height), x = param.x, y = param.y, maxLength = param.maxLength, listener = function (textfield, eventType)
		if eventType == 0 then
			-- ATTACH_WITH_IME
			self:showTip()
		elseif eventType == 1 then
			-- DETACH_WITH_IME
			self:closeTip()
		elseif eventType == 2 then
			-- INSERT_TEXT
			self:filterTip(textfield:getString())
		elseif eventType == 3 then
			-- DELETE_BACKWARD
			self:filterTip(textfield:getString())
		end
	end}):addToContainer(self)

	local listViewHeight, maxListViewHeight = 360, param.y - param.height / 2
	if listViewHeight > maxListViewHeight then
		listViewHeight = maxListViewHeight
	end
	self._tipListView = ListView.new({
		viewRect = cc.rect(param.x - param.width / 2, param.y - param.height / 2 - listViewHeight, param.width, listViewHeight),
		bg = param.listViewBg,
		isScale9 = true
		}):addToContainer(self)
		:onTouchListener(handler(self, self.onTipListViewTouch))
	self._tipListView:setDelegate(handler(self, self.tipListViewDelegate))
	self._tipListView:setVisible(false)
end

function JTextFieldWithTip:onTipListViewTouch(event)
	if "clicked" == event.name then
		self._textField:setString(self._filterTipDataList[event.itemPos])
	end
end

function JTextFieldWithTip:tipListViewDelegate(listView, tag, idx)
	if TAG.COUNT_TAG == tag then
		return #self._filterTipDataList
	elseif TAG.CELL_TAG == tag then
		local content = nil
		local item = listView:dequeueItem()
		if item then
			content = item:getContent()
		else
			content = Label.new({text = "", size = 20, align = cc.ui.TEXT_ALIGN_CENTER, color = display.COLOR_WHITE})
			item = listView:newItem(content)
		end
		content:setString(self._filterTipDataList[idx])
		item:actualWidth(self._width):actualHeight(30)
		return item
	end
end

function JTextFieldWithTip:showTip()
	self._tipListView:setVisible(true)
end

function JTextFieldWithTip:closeTip()
	self._tipListView:setVisible(false)
end

function JTextFieldWithTip:filterTip(key)
	if self._tipListView:isVisible() then
		self._filterTipDataList = { }
		for _, v in ipairs(self._tipDataList) do
			if string.find(v, key) then
				self._filterTipDataList[#self._filterTipDataList + 1] = v
			end
		end
		self._tipListView:reload()
	end
end

function JTextFieldWithTip:getString()
	return self._textField:getString()
end

return JTextFieldWithTip