--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-19 14:07:01
--

local ListViewItem = import(".JListViewItem")

local JListView = class("JListView", require("libra.ui.components.JScrollView"))

function JListView:ctor(param)
	JListView.super.ctor(self, param)

	self._direction = param.direction or Direction.VERTICAL
	self._itemList = { }

	self._freeItemList = { }
	self._redundancyViewVal = 0 --异步的视图两个方向上的冗余大小,横向代表宽,竖向代表高

	self._container = display.newNode()
	self:addScrollNode(self._container)
	self:onScrollListener(handler(self, self.onScrollHandler))
end

--- 设置显示区域
-- @function [parent=#JListView] setViewRect
-- @return JListView#JListView  self
function JListView:viewRect(viewRect)
	if viewRect then
		if Direction.VERTICAL == self._direction then
			self._redundancyViewVal = viewRect.height
		else
			self._redundancyViewVal = viewRect.width
		end
	end
	return JListView.super.viewRect(self, viewRect)
end

-- 创建一个新的listViewItem项
-- @param node item 要放到listViewItem中的内容content
-- @return UIListViewItem#UIListViewItem 
function JListView:newItem(item)
	return ListViewItem.new(item)
end

--- 取某项在列表控件中的位置
-- @param node listItem 列表项
-- @return integer#integer 
function JListView:getItemPos(listItem)
	for i,v in ipairs(self._itemList) do
		if v == listItem then
			return i
		end
	end
end

function JListView:isItemInViewRect(pos)
	local item
	if "number" == type(pos) then
		item = self.items_[pos]
	elseif "userdata" == type(pos) then
		item = pos
	end

	if not item then return end
	
	local bound = item:getBoundingBox()
	local nodePoint = self.container:convertToWorldSpace(cc.p(bound.x, bound.y))
	bound.x = nodePoint.x
	bound.y = nodePoint.y

	return cc.rectIntersectsRect(self:getViewRectInWorldSpace(), bound)
end

--- 加载列表
-- @function [parent=#JListView] reload
-- @return JListView#JListView
function JListView:reload(resetPosition)
	if resetPosition == nil then
		resetPosition = true
	end
	self:asyncLoad(resetPosition)
	return self
end

--- 取一个空闲项出来,如果没有返回空
-- @function [parent=#JListView] dequeueItem
-- @return JListViewItem#JListViewItem  item
function JListView:dequeueItem()
	if #self._freeItemList > 0 then
		local item = table.remove(self._freeItemList, 1)
		--标识从free中取出,在loadOneItem中调用release
		--这里直接调用release,item会被释放掉
		item._bFromFreeQueue = true
		return item
	end
end

-- function JListView:moveItems(beginIdx, endIdx, x, y, bAni)
-- 	local posX, posY = 0, 0
-- 	local moveByParams = {x = x, y = y, time = 0.2}
-- 	for i = beginIdx, endIdx do
-- 		if bAni then
-- 			if i == beginIdx then
-- 				moveByParams.onComplete = function()
-- 					self:elasticScroll()
-- 				end
-- 			else
-- 				moveByParams.onComplete = nil
-- 			end
-- 			transition.moveBy(self._itemList[i], moveByParams)
-- 		else
-- 			posX, posY = self._itemList[i]:getPosition()
-- 			self._itemList[i]:setPosition(posX + x, posY + y)
-- 			if i == beginIdx then
-- 				self:elasticScroll()
-- 			end
-- 		end
-- 	end
-- end

function JListView:notifyListener(event)
	if self._touchListener and type(self._touchListener) == "function" then
		self._touchListener(event)
	end
end

local function rectIntersectsRect(rectParent, rect)
	-- 0:no intersects,1:have intersects,2,have intersects and include totally
	local nIntersects 
	local bIn = rectParent.x <= rect.x and
			rectParent.x + rectParent.width >= rect.x + rect.width and
			rectParent.y <= rect.y and
			rectParent.y + rectParent.height >= rect.y + rect.height
	if bIn then
		nIntersects = 2
	else
		local bNotIn = rectParent.x > rect.x + rect.width or rectParent.x + rectParent.width < rect.x or 
			rectParent.y > rect.y + rect.height or rectParent.y + rectParent.height < rect.y
		nIntersects = bNotIn and 0 or 1
	end
	return nIntersects
end

function JListView:checkItemsInStatus()
	if not self._itemInStatus then self._itemInStatus = { } end
	local newStatus, bound, nodePoint = { }, nil, nil
	for i, v in ipairs(self._itemList) do
		bound = v:getBoundingBox()
		nodePoint = self._container:convertToWorldSpace(cc.p(bound.x, bound.y))
		bound.x = nodePoint.x
		bound.y = nodePoint.y
		newStatus[i] = rectIntersectsRect(self._viewRect, bound)
	end

	for i, v in ipairs(newStatus) do
		if self._itemInStatus[i] and self._itemInStatus[i] ~= v then
			local params = {listView = self,
							itemPos = i,
							item = self._itemList[i]}
			if 0 == v then
				params.name = "itemDisappear"
			elseif 1 == v then
				params.name = "itemAppearChange"
			elseif 2 == v then
				params.name = "itemAppear"
			end
			self:notifyListener(params)
		end
	end
	self._itemInStatus = newStatus
end

function JListView:getContainerCascadeBoundingBox()
	local boundingBox
	for i, item in ipairs(self._itemList) do
		local w, h = item:actualWidth(), item:actualHeight()
		local x, y = item:getPosition()
		local anchor = item:getAnchorPoint()
		x = x - anchor.x * w
		y = y - anchor.y * h
		boundingBox = boundingBox and cc.rectUnion(boundingBox, cc.rect(x, y, w, h)) or cc.rect(x, y, w, h)
	end

	local point = self._container:convertToWorldSpace(cc.p(boundingBox.x, boundingBox.y))
	boundingBox.x = point.x
	boundingBox.y = point.y

	return boundingBox
end

--- 动态调整item,是否需要加载新item,移除旧item
-- @private
function JListView:increaseOrReduceItem()
	if 0 == #self._itemList then return end

	-- 作为是否还需要再增加或减少item的标志,2表示上下两个方向或左右都需要调整
	local nNeedAdjust = 2 
	local cascadeBound = self:getContainerCascadeBoundingBox()
	local item, itemW, itemH
	local viewRect = self:getViewRectInWorldSpace()
	if Direction.VERTICAL == self._direction then
		-- ahead part of view
		item = self._itemList[1]
		if not item then return end
		local disH = cascadeBound.y + cascadeBound.height - viewRect.y - viewRect.height
		local tempIdx = item:index()
		if disH > self._redundancyViewVal then
			itemW, itemH = item:actualWidth(), item:actualHeight()
			if cascadeBound.height - itemH > self._viewRect.height
				and disH - itemH > self._redundancyViewVal then
				self:unloadOneItem(tempIdx)
			else
				nNeedAdjust = nNeedAdjust - 1
			end
		else
			item = nil
			tempIdx = tempIdx - 1
			if tempIdx > 0 then
				local localPoint = self._container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y + cascadeBound.height))
				item = self:loadOneItem(localPoint, tempIdx, true)
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1
			end
		end

		-- part after view
		disH = viewRect.y - cascadeBound.y
		item = self._itemList[#self._itemList]
		if not item then return end

		tempIdx = item:index()
		if disH > self._redundancyViewVal then
			itemW, itemH = item:actualWidth(), item:actualHeight()
			if cascadeBound.height - itemH > viewRect.height
				and disH - itemH > self._redundancyViewVal then
				self:unloadOneItem(tempIdx)
			else
				nNeedAdjust = nNeedAdjust - 1
			end
		else
			item = nil
			tempIdx = tempIdx + 1
			if tempIdx <= self._delegateFunc(self, TAG.COUNT_TAG) then
				local localPoint = self._container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))
				item = self:loadOneItem(localPoint, tempIdx)
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1
			end
		end
	else
		-- left part of view
		local disW = viewRect.x - cascadeBound.x
		item = self._itemList[1]
		local tempIdx = item:index()
		if disW > self._redundancyViewVal then
			itemW, itemH = item:actualWidth(), item:actualHeight()
			if cascadeBound.width - itemW > viewRect.width
				and disW - itemW > self._redundancyViewVal then
				self:unloadOneItem(tempIdx)
			else
				nNeedAdjust = nNeedAdjust - 1
			end
		else
			item = nil
			tempIdx = tempIdx - 1
			if tempIdx > 0 then
				local localPoint = self._container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))
				item = self:loadOneItem(localPoint, tempIdx, true)
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1
			end
		end

		-- right part of view
		disW = cascadeBound.x + cascadeBound.width - viewRect.x - viewRect.width
		item = self._itemList[#self._itemList]
		tempIdx = item:index()
		if disW > self._redundancyViewVal then
			itemW, itemH = item:actualWidth(), item:actualHeight()
			if cascadeBound.width - itemW > viewRect.width
				and disW - itemW > self._redundancyViewVal then
				self:unloadOneItem(tempIdx)
			else
				nNeedAdjust = nNeedAdjust - 1
			end
		else
			item = nil
			tempIdx = tempIdx + 1
			if tempIdx <= self._delegateFunc(self, TAG.COUNT_TAG) then
				local localPoint = self._container:convertToNodeSpace(cc.p(cascadeBound.x + cascadeBound.width, cascadeBound.y))
				item = self:loadOneItem(localPoint, tempIdx)
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1
			end
		end
	end

	if nNeedAdjust > 0 then
		return self:increaseOrReduceItem()
	end
end

--- 移除所有的项
-- @return integer#integer 
function JListView:removeAllItems()
    self._container:removeAllChildren()
    self._itemList = { }
    return self
end

--- 异步加载列表数据
function JListView:asyncLoad(resetPosition)
	self:removeAllItems()
	local oldPositionX, oldPositionY = self._container:getPosition()
	self._container:setPosition(0, 0)
	self._container:setContentSize(cc.size(0, 0))

	local count = self._delegateFunc(self, TAG.COUNT_TAG)
	local item, itemW, itemH = nil, 0, 0
	local containerW, containerH, posX, posY = 0, 0, 0, 0
	for i = 1, count do
		item, itemW, itemH = self:loadOneItem(cc.p(posX, posY), i)
		if Direction.VERTICAL == self._direction then
			posY = posY - itemH
			containerH = containerH + itemH
		else
			posX = posX + itemW
			containerW = containerW + itemW
		end
		-- 初始布局,最多保证可隐藏的区域大于显示区域就可以了
		if containerW > self._viewRect.width + self._redundancyViewVal
			or containerH > self._viewRect.height + self._redundancyViewVal then
			break
		end
	end

	-- self._container:setPosition(self._viewRect.x, self._viewRect.y)
	if resetPosition then
		if Direction.VERTICAL == self._direction then
			self._container:setPosition(self._viewRect.x,
				self._viewRect.y + self._viewRect.height)
		else
			self._container:setPosition(self._viewRect.x, self._viewRect.y)
		end
	else
		self._container:setPosition(oldPositionX, oldPositionY)
	end
	return self
end

--- 设置delegate函数
-- @return JListView#JListView 
function JListView:setDelegate(delegate)
	self._delegateFunc = delegate
end

--- 加载一个数据项
-- @private
-- @param table originPoint 数据项要加载的起始位置
-- @param number idx 要加载数据的序号
-- @param boolean bBefore 是否加在已有项的前面
-- @return JListViewItem item
function JListView:loadOneItem(originPoint, idx, bBefore)
	local item, itemW, itemH, containerW, containerH = nil, 0, 0, 0, 0
	local posX, posY = originPoint.x, originPoint.y
	item = self._delegateFunc(self, TAG.CELL_TAG, idx)
	if nil == item then
		logger:error("ERROR! JListView load nil item")
		return
	end
	item:index(idx)
	itemW, itemH = item:actualWidth(), item:actualHeight()
	itemW = itemW or 0
	itemH = itemH or 0
	if Direction.VERTICAL == self._direction then
		posY = bBefore and posY or posY - itemH
		item:setPosition(0, posY)
		-- transition.moveTo(item, {time = .05 * idx, x = 0, y = posY})
		containerH = containerH + itemH
	else
		if bBefore then
			posX = posX - itemW
		end
		item:setPosition(posX, 0)
		containerW = containerW + itemW
	end
	local content = item:getContent()
	content:setAnchorPoint(0.5, 0.5)
	content:setPosition(itemW / 2, itemH / 2)

	if bBefore then
		table.insert(self._itemList, 1, item)
	else
		table.insert(self._itemList, item)
	end

	self._container:addChild(item)
	if item._bFromFreeQueue then
		item._bFromFreeQueue = nil
		item:release()
	end	
	return item, itemW, itemH
end

--- 移除一个数据项
-- @private
function JListView:unloadOneItem(idx)
	local item = self._itemList[1]
	if item and item:index() <= idx then
		local unloadIdx = idx - item:index() + 1
		item = self._itemList[unloadIdx]
		if item then
			table.remove(self._itemList, unloadIdx)
			self:addFreeItem(item)
			self._container:removeChild(item, false)
			self._delegateFunc(self, TAG.UNLOAD_CELL_TAG, idx)
		end
	end
end

--- 加一个空项到空闲列表中
-- @private
function JListView:addFreeItem(item)
	item:retain()
	table.insert(self._freeItemList, item)
end

--- 释放所有的空闲列表项
-- @private
function JListView:releaseFreeItemList()
	for i,v in ipairs(self._freeItemList) do
		v:release()
	end
	self._freeItemList = {}
end

--- 列表控件触摸注册函数
-- @param function listener 触摸临听函数
-- @return JListView#JListView  self 自身
function JListView:onTouchListener(listener)
	self._touchListener = listener
	return self
end

function JListView:onScrollHandler(event)
	if "clicked" == event.name then
		local nodePoint = self._container:convertToNodeSpace(cc.p(event.x, event.y))
		local pos, idx = 0, 0
		local itemRect = nil
		for i, v in ipairs(self._itemList) do
			local posX, posY = v:getPosition()
			local itemW, itemH = v:actualWidth(), v:actualHeight()
			itemRect = cc.rect(posX, posY, itemW, itemH)
			if cc.rectContainsPoint(itemRect, nodePoint) then
				pos, idx = i, v:index()
				break
			end
		end
		self:notifyListener{name = event.name, listView = self, itemPos = idx, item = self._itemList[pos], point = nodePoint}
	else
		event.scrollView = nil
		event.listView = self
		self:notifyListener(event)
	end
end

function JListView:onUpdate(dt)
	JListView.super.onUpdate(self, dt)

	self:checkItemsInStatus()
	self:increaseOrReduceItem()
end

function JListView:onCleanup()
	JListView.super.onCleanup(self)
	self:releaseFreeItemList()
end

return JListView