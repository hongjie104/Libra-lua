--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-19 20:36:38
--

local JPageViewItem = import(".JPageViewItem")

local JPageView = class("JPageView", function ()
	return display.newClippingRegionNode()
end)

function JPageView:ctor()
	makeUIComponent(self)
	self._itemList = {}
	self._viewRect = param.viewRect or cc.rect(0, 0, display.width, display.height)
	self._col = param.col or 1
	self._row = param.row or 1
	self._colGap = param.colGap or 0
	self._rowGap = param.rowGap or 0
	self._padding = param.padding or {left = 0, right = 0, top = 0, bottom = 0}
	self._isCirc = param.isCirc or false

	self:setClippingRegion(self._viewRect)
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		return self:onTouch(event)
	end)
end

--- 创建一个新的页面控件项
-- @return JPageViewItem#JPageViewItem 
function JPageView:newItem()
	local item = JPageViewItem.new()
	local itemW = (self._viewRect.width - self._padding.left - self._padding.right - self._colGap * (self._col - 1)) / self._col
	local itemH = (self._viewRect.height - self._padding.top - self._padding.bottom - self._rowGap * (self._row - 1)) / self._row
	item:actualWidth(itemW):actualHeight(itemH)
	return item
end

--- 添加一项到页面控件中
-- @param node item 页面控件项
-- @return JPageView#JPageView 
function JPageView:addItem(item)
	table.insert(self._itemList, item)
	return self
end

--- 移除一项
-- @param number idx 要移除项的序号
-- @return JPageView#JPageView 
function JPageView:removeItem(item)
	local itemIdx = 0
	for i, v in ipairs(self._itemList) do
		if v == item then
			itemIdx = i
		end
	end
	if 0 == itemIdx then
		logger:error("item isn't exist")
		return self
	end
	table.remove(self._itemList, itemIdx)
	self:reload(self._curPageIdx)
	return self
end

--- 移除所有页面
-- @return JPageView#JPageView 
function JPageView:removeAllItems()
	self._itemList = { }
	self:reload(self._curPageIdx)
	return self
end

--- 注册一个监听函数
-- @param function listener 监听函数
-- @return JPageView#JPageView 
function JPageView:onTouch(listener)
	self._touchListener = listener
	return self
end

--- 加载数据，各种参数
-- @param number page index加载完成后,首先要显示的页面序号,为空从第一页开始显示
-- @return JPageView#JPageView 
function JPageView:reload(idx)
	local page, pageCount = nil, 0
	self._pageList = { }

	self:removeAllChildren()

	pageCount = self:getPageCount()
	if pageCount < 1 then
		return self
	end

	-- retain all items
	for i, v in ipairs(self._itemList) do
		v:retain()
	end

	for i = 1, pageCount do
		page = self:createPage(i)
		page:setVisible(false)
		table.insert(self._pageList, page)
		self:addChild(page)
	end

	if not idx or idx < 1 then
		idx = 1
	elseif idx > pageCount then
		idx = pageCount
	end
	self._curPageIdx = idx
	self._pageList[idx]:setVisible(true)
	self._pageList[idx]:setPosition(self._viewRect.x, self._viewRect.y)

	-- release all items
	for i, v in ipairs(self._itemList) do
		v:release()
	end

	return self
end

--- 跳转到特定的页面
-- @param integer pageIdx 要跳转的页面的位置
-- @param boolean isSmooth 是否需要跳转动画
-- @param isLeftToRight 移动的方向,在可循环下有效, nil:自动调整方向,false:从右向左,true:从左向右
-- @return JPageView#JPageView 
function JPageView:gotoPage(pageIdx, isSmooth, isLeftToRight)
	if pageIdx < 1 then pageIdx = 1 end
	local pageCount = self:getPageCount()
	if pageIdx > pageCount then pageIdx = pageCount end

	if isSmooth then
		if pageIdx ~= self._curPageIdx then
			self:resetPagePos(pageIdx, isLeftToRight)
			self:scrollPagePos(pageIdx, isLeftToRight)
		end
	else
		self._pageList[self._curPageIdx]:setVisible(false)
		self._pageList[pageIdx]:setVisible(true)
		self._pageList[pageIdx]:setPosition(self._viewRect.x, self._viewRect.y)
		self._curPageIdx = pageIdx
		self:notifyListener{name = "pageChange"}
	end

	return self
end

--- 得到页面的总数
-- @return number#number 
function JPageView:getPageCount()
	return math.ceil(table.nums(self._itemList) / (self._col * self._row))
end

--- 得到当前页面的位置
-- @return number#number 
function JPageView:getCurPageIndex()
	return self._curPageIdx
end

--- 设置页面控件是否为循环
-- @param boolean bCirc 是否循环
-- @return JPageView#JPageView 
function JPageView:setCirculatory(isCirc)
	self._isCirc = isCir
	return self
end

-- @private
function JPageView:createPage(pageNo)
	local page = display.newNode()
	local item, itemW, itemH
	local beginIdx = self._row * self._col * (pageNo - 1) + 1

	itemW = (self._viewRect.width - self._padding.left - self._padding.right
				- self._colGap * (self._col - 1)) / self._col
	itemH = (self._viewRect.height - self._padding.top - self._padding.bottom
				- self._rowGap * (self._row - 1)) / self._row
	local isBreak = false
	for row = 1, self._row do
		for col = 1, self._col do
			item = self._itemList[beginIdx]
			beginIdx = beginIdx + 1
			if not item then
				isBreak = true
				break
			end
			page:addChild(item)

			item:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
			item:setPosition(self._padding.left + (col - 1) * self._colGap + col * itemW - itemW / 2,
				self._viewRect.height - self._padding.top - (row - 1) * self._rowGap - row * itemH + itemH / 2)
		end
		if isBreak then
			break
		end
	end
	return page
end

-- @private
function JPageView:isTouchInViewRect(event, rect)
	rect = rect or self._viewRect
	local viewRect = self:convertToWorldSpace(cc.p(rect.x, rect.y))
	viewRect.width = rect.width
	viewRect.height = rect.height
	return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end

-- @private
function JPageView:onTouch(event)
	if "began" == event.name then
		if self:isTouchInViewRect(event) then
			self:stopAllTransition()
			self._isTouchMoved = false
			self._prevX, self._prevY = event.x, event.y
			return true
		end
	elseif "moved" == event.name then
		if math.abs(event.x - self._prevX) > 6 or math.abs(event.y - self._prevY) > 6 then
			self._isTouchMoved = true
			self._moveSpeed = event.x - event.prevX
			self:scroll(self._moveSpeed)
		end
	elseif "ended" == event.name then
		if self._isTouchMoved then
			self:scrollAuto()
		else
			self:resetPageList()
			self:onClicked(event)
		end
	end
end

--- 重置页面,检查当前页面在不在初始位置,用于在动画被stopAllTransition的情况
-- @private
function JPageView:resetPageList()
	local x, y = self._pageList[self._curPageIdx]:getPosition()

	if x ~= self._viewRect.x then
		self:disablePage()
		self:gotoPage(self._curPageIdx)
	end
end

--- 重置相关页面的位置
-- @param integer pos 要移动到的位置
-- @param isLeftToRight 移动的方向,在可循环下有效, nil:自动调整方向,false:从右向左,true:从左向右
function JPageView:resetPagePos(pos, isLeftToRight)
	local pageIdx = self._curPageIdx
	local page
	local pageWidth = self._viewRect.width
	local dis
	local count = #self._pageList

	dis = pos - pageIdx
	if self._isCirc then
		local disL,disR
		if dis > 0 then
			disR = dis
			disL = disR - count
		else
			disL = dis
			disR = disL + count
		end

		if nil == isLeftToRight then
			dis = ((math.abs(disL) > math.abs(disR)) and disR) or disL
		elseif isLeftToRight then
			dis = disR
		else
			dis = disL
		end
	end

	local disABS = math.abs(dis)
	local x = self._pageList[pageIdx]:getPosition()

	for i = 1, disABS do
		if dis > 0 then
			pageIdx = pageIdx + 1
			x = x + pageWidth
		else
			pageIdx = pageIdx + count
			pageIdx = pageIdx - 1
			x = x - pageWidth
		end
		pageIdx = pageIdx % count
		if 0 == pageIdx then
			pageIdx = count
		end
		page = self._pageList[pageIdx]
		if page then
			page:setVisible(true)
			page:setPosition(x, self._viewRect.y)
		end
	end
end

--- 移动到相对于当前页的某个位置
-- @param integer pos 要移动到的位置
-- @param isLeftToRight 移动的方向,在可循环下有效, nil:自动调整方向,false:从右向左,true:从左向右
function JPageView:scrollPagePos(pos, isLeftToRight)
	local pageIdx = self._curPageIdx
	local page
	local pageWidth = self._viewRect.width
	local dis
	local count = #self._pageList

	dis = pos - pageIdx
	if self._isCirc then
		local disL,disR
		if dis > 0 then
			disR = dis
			disL = disR - count
		else
			disL = dis
			disR = disL + count
		end

		if nil == isLeftToRight then
			dis = ((math.abs(disL) > math.abs(disR)) and disR) or disL
		elseif isLeftToRight then
			dis = disR
		else
			dis = disL
		end
	end

	local disABS = math.abs(dis)
	local x = self._viewRect.x
	local movedis = dis * pageWidth

	for i=1, disABS do
		if dis > 0 then
			pageIdx = pageIdx + 1
		else
			pageIdx = pageIdx + count
			pageIdx = pageIdx - 1
		end
		pageIdx = pageIdx % count
		if 0 == pageIdx then
			pageIdx = count
		end
		page = self._pageList[pageIdx]
		if page then
			page:setVisible(true)
			transition.moveBy(page, {x = -movedis, y = 0, time = 0.3})
		end
	end
	transition.moveBy(self._pageList[self._curPageIdx],
					{x = -movedis, y = 0, time = 0.3,
					onComplete = function()
						local pageIdx = (self._curPageIdx + dis + count) % count
						if 0 == pageIdx then
							pageIdx = count
						end
						self._curPageIdx = pageIdx
						self:disablePage()
						self:notifyListener{name = "pageChange"}
					end})
end

-- @private
function JPageView:stopAllTransition()
	for i, v in ipairs(self._pageList) do
		transition.stopTarget(v)
	end
end

-- @private
function JPageView:disablePage()
	for i, v in ipairs(self._pageList) do
		if i ~= self._curPageIdx then
			v:setVisible(false)
		end
	end
end

-- @private
function JPageView:scroll(dis)
	local threePages = { }
	local count
	if self._pageList then
		count = #self._pageList
	else
		count = 0
	end

	local page
	if 0 == count then
		return
	elseif 1 == count then
		table.insert(threePages, false)
		table.insert(threePages, self._pageList[self._curPageIdx])
	elseif 2 == count then
		local posX, posY = self._pageList[self._curPageIdx]:getPosition()
		if posX > self._viewRect.x then
			page = self:getNextPage(false)
			if not page then
				page = false
			end
			table.insert(threePages, page)
			table.insert(threePages, self._pageList[self._curPageIdx])
		else
			table.insert(threePages, false)
			table.insert(threePages, self._pageList[self._curPageIdx])
			table.insert(threePages, self:getNextPage(true))
		end
	else
		page = self:getNextPage(false)
		if not page then
			page = false
		end
		table.insert(threePages, page)
		table.insert(threePages, self._pageList[self._curPageIdx])
		table.insert(threePages, self:getNextPage(true))
	end

	self:scrollLCRPages(threePages, dis)
end

-- @private
function JPageView:scrollLCRPages(threePages, dis)
	local posX, posY
	local pageL = threePages[1]
	local page = threePages[2]
	local pageR = threePages[3]

	-- current
	posX, posY = page:getPosition()
	posX = posX + dis
	page:setPosition(posX, posY)

	-- left
	posX = posX - self._viewRect.width
	if pageL and "boolean" ~= type(pageL) then
		pageL:setPosition(posX, posY)
		if not pageL:isVisible() then
			pageL:setVisible(true)
		end
	end

	posX = posX + self._viewRect.width * 2
	if pageR then
		pageR:setPosition(posX, posY)
		if not pageR:isVisible() then
			pageR:setVisible(true)
		end
	end
end

function JPageView:scrollAuto()
	local page = self._pageList[self._curPageIdx]
	local pageL = self:getNextPage(false)
	local pageR = self:getNextPage(true)
	local bChange = false
	local posX, posY = page:getPosition()
	local dis = posX - self._viewRect.x

	local pageRX = self._viewRect.x + self._viewRect.width
	local pageLX = self._viewRect.x - self._viewRect.width

	local count = #self._pageList
	if 0 == count then
		return
	elseif 1 == count then
		pageL = nil
		pageR = nil
	end
	if (dis > self._viewRect.width/2 or self._moveSpeed > 10)
		and (self._curPageIdx > 1 or self._isCirc)
		and count > 1 then
		bChange = true
	elseif (-dis > self._viewRect.width/2 or -self._moveSpeed > 10)
		and (self._curPageIdx < self:getPageCount() or self._isCirc)
		and count > 1 then
		bChange = true
	end

	if dis > 0 then
		if bChange then
			transition.moveTo(page,
				{x = pageRX, y = posY, time = 0.3,
				onComplete = function()
					self._curPageIdx = self:getNextPageIndex(false)
					self:disablePage()
					self:notifyListener{name = "pageChange"}
				end})
			transition.moveTo(pageL,
				{x = self._viewRect.x, y = posY, time = 0.3})
		else
			transition.moveTo(page,
				{x = self._viewRect.x, y = posY, time = 0.3,
				onComplete = function()
					self:disablePage()
					self:notifyListener{name = "pageChange"}
				end})
			if pageL then
				transition.moveTo(pageL,
					{x = pageLX, y = posY, time = 0.3})
			end
		end
	else
		if bChange then
			transition.moveTo(page,
				{x = pageLX, y = posY, time = 0.3,
				onComplete = function()
					self._curPageIdx = self:getNextPageIndex(true)
					self:disablePage()
					self:notifyListener{name = "pageChange"}
				end})
			transition.moveTo(pageR,
				{x = self._viewRect.x, y = posY, time = 0.3})
		else
			transition.moveTo(page,
				{x = self._viewRect.x, y = posY, time = 0.3,
				onComplete = function()
					self:disablePage()
					self:notifyListener{name = "pageChange"}
				end})
			if pageR then
				transition.moveTo(pageR,
					{x = pageRX, y = posY, time = 0.3})
			end
		end
	end
end

-- @private
function JPageView:onClicked(event)
	local itemW = (self._viewRect.width - self._padding.left - self._padding.right
				- self._colGap*(self._col - 1)) / self._col
	local itemH = (self._viewRect.height - self._padding.top - self._padding.bottom
				- self._rowGap*(self._row - 1)) / self._row

	local itemRect = {width = itemW, height = itemH}

	local clickIdx
	for row = 1, self._row do
		itemRect.y = self._viewRect.y + self._viewRect.height - self._padding.top - row*itemH - (row - 1)*self._rowGap
		for col = 1, self._col do
			itemRect.x = self._viewRect.x + self._padding.left + (col - 1)*(itemW + self._colGap)

			if self:isTouchInViewRect(event, itemRect) then
				clickIdx = (row - 1)*self._col + col
				break
			end
		end
		if clickIdx then
			break
		end
	end

	if not clickIdx then
		-- not found, maybe touch in space
		return
	end

	clickIdx = clickIdx + (self._col * self._row) * (self._curPageIdx - 1)

	self:notifyListener{name = "clicked", item = self._itemList[clickIdx], itemIdx = clickIdx}
end

function JPageView:notifyListener(event)
	if type(self._touchListener) == "function" then
		event.pageView = self
		event.pageIdx = self._curPageIdx
		self._touchListener(event)
	end
end

function JPageView:getNextPage(bRight)
	if self._pageList and #self._pageList < 2 then
		return
	end
	local pos = self:getNextPageIndex(bRight)
	return self._pageList[pos]
end

function JPageView:getNextPageIndex(bRight)
	local count = #self._pageList
	local pos
	if bRight then
		pos = self._curPageIdx + 1
	else
		pos = self._curPageIdx - 1
	end

	if self._isCirc then
		pos = pos + count
		pos = pos % count
		if 0 == pos then
			pos = count
		end
	end

	return pos
end

return JPageView