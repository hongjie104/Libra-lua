--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 21:39:06
--

local JScrollView = class("JScrollView", function ()
	return cc.ClippingRegionNode:create()
end)

function JScrollView:ctor(param)
	makeUIComponent(self)
	self:isBounceable(true)

	if param then
		self._direction = param.direction or Direction.BOTH
		self:viewRect(param.viewRect)
		self._sbH = param.scrollbarImgH and display.newScale9Sprite(param.scrollbarImgH):addTo(self)
		self._sbV = param.scrollbarImgV and display.newScale9Sprite(param.scrollbarImgV):addTo(self)
		self:isTouchOnContent(param.touchOnContent or true)
		if param.bg then
			local x, y = self._viewRect.x + self._viewRect.width / 2, self._viewRect.y + self._viewRect.height / 2
			if param.isScale9 then
				display.newScale9Sprite(param.bg, x, y, cc.size(self._viewRect.width, self._viewRect.height), param.capInsets):addTo(self, -1)
			else
				display.newSprite(param.bg, x, y):addTo(self, -1)
			end
		end
	end

	self._scrollSpeed = {x = 0, y = 0}
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onUpdate))
	self:setNodeEventEnabled(true)
end

function JScrollView:viewRect(rect)
	if rect then
		self:setClippingRegion(rect)
		self._viewRect = rect
		return self
	end
	return self._viewRect
end

function JScrollView:isTouchOnContent(bool)
	if type(bool) == "boolean" then
		if self._isTouchOnContent ~= bool then
			self._isTouchOnContent = bool
			return self
		end
	end
	return self._isTouchOnContent
end

function JScrollView:isBounceable(bool)
	if type(bool) == "boolean" then
		if self._isBounceable ~= bool then
			self._isBounceable = bool
			return self
		end
	end
	return self._isBounceable
end

--- 重置位置,主要用在纵向滚动时
function JScrollView:resetPosition()
	if Direction.VERTICAL == self._direction then
		local x, y = self._scrollNode:getPosition()
		local bound = self:getScrollNodeRect()
		local disY = self._viewRect.y + self._viewRect.height - bound.y - bound.height
		self._scrollNode:setPosition(x, y + disY)
	end
end

--- 判断一个node是否在滚动控件的显示区域中
-- @param node item scrollView中的项
-- @return boolean 
function JScrollView:isItemInViewRect(item)
	if "userdata" == type(item) then
		return cc.rectIntersectsRect(self:getViewRectInWorldSpace(), item:getCascadeBoundingBox())
	end
end

--- 将要显示的node加到scrollview中,scrollView只支持滚动一个node
-- @param node node 要显示的项
-- @return JScrollView 
function JScrollView:addScrollNode(node)
	self:addChild(node)
	self._scrollNode = node

	if not self._viewRect then
		self._viewRect = self:getScrollNodeRect()
		self:viewRect(self._viewRect)
	end
	-- node:setTouchSwallowEnabled(false)
	-- node:setTouchEnabled(true)
 --	node:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
 --		if self:isTouchInViewRect(event) then
 --			return "began" == event.name or "moved" == event.name or "ended" == event.name
 --		end
 --	end)
	self:addTouchNode()

	return self
end

--- 加一个大小为viewRect的touch node
function JScrollView:addTouchNode()
	local node = nil
	if self._touchNode then
		node = self._touchNode
	else
		node = display.newNode()		
		self._touchNode = node
		node:setTouchSwallowEnabled(false)
		node:setTouchEnabled(true)
		node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			return self:onTouch(event)
		end)
		self:addChild(node, -99)
	end
	node:setContentSize(self._viewRect.width, self._viewRect.height)
	node:setPosition(self._viewRect.x, self._viewRect.y)
	return self
end

function JScrollView:isTouchInViewRect(event)
	local viewRect = self:convertToWorldSpace(cc.p(self._viewRect.x, self._viewRect.y))
	viewRect.width = self._viewRect.width
	viewRect.height = self._viewRect.height
	return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end

function JScrollView:scrollTo(x, y)
	x = x or 0
	y = y or 0
	self._position = {x, y}
	self._scrollNode:setPosition(self._position)
end

function JScrollView:moveXY(orgX, orgY, speedX, speedY)
	if self._isBounceable then
		return orgX + speedX, orgY + speedY
	end

	local cascadeBound = self:getScrollNodeRect()
	local viewRect = self:getViewRectInWorldSpace()
	local x, y, disX, disY = orgX, orgY, 0, 0

	if speedX > 0 then
		if cascadeBound.x < viewRect.x then
			disX = viewRect.x - cascadeBound.x
			disX = disX / self._scaleToWorldSpace.x
			x = orgX + math.min(disX, speedX)
		end
	else
		if cascadeBound.x + cascadeBound.width > viewRect.x + viewRect.width then
			disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
			disX = disX / self._scaleToWorldSpace.x
			x = orgX + math.max(disX, speedX)
		end
	end

	if speedY > 0 then
		if cascadeBound.y < viewRect.y then
			disY = viewRect.y - cascadeBound.y
			disY = disY / self._scaleToWorldSpace.y
			y = orgY + math.min(disY, speedY)
		end
	else
		if cascadeBound.y + cascadeBound.height > viewRect.y + viewRect.height then
			disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
			disY = disY / self._scaleToWorldSpace.y
			y = orgY + math.max(disY, speedY)
		end
	end
	return x, y
end

function JScrollView:scrollBy(x, y)
	self._position.x, self._position.y = self:moveXY(self._position.x, self._position.y, x, y)
	self._scrollNode:setPosition(self._position)
end

function JScrollView:scrollAuto()
	return self:twiningScroll() or self:elasticScroll()
end

function JScrollView:twiningScroll()	
	if self:isSideShow() then
		return false
	end
	
	if math.abs(self._scrollSpeed.x) < 10 and math.abs(self._scrollSpeed.y) < 10 then
		return false
	end
	
	local disX, disY = self:moveXY(0, 0, self._scrollSpeed.x * 6, self._scrollSpeed.y * 6)
	transition.moveBy(self._scrollNode, {x = disX, y = disY, time = 0.3, easing = "sineOut", onComplete = function()
		self:elasticScroll()
	end})
end

function JScrollView:elasticScroll()
	local cascadeBound = self:getScrollNodeRect()
	local disX, disY = 0, 0
	local viewRect = self:getViewRectInWorldSpace()

	if cascadeBound.width < viewRect.width then
		disX = viewRect.x - cascadeBound.x
	else
		if cascadeBound.x > viewRect.x then
			disX = viewRect.x - cascadeBound.x
		elseif cascadeBound.x + cascadeBound.width < viewRect.x + viewRect.width then
			disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
		end
	end

	if cascadeBound.height < viewRect.height then
		disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
	else
		if cascadeBound.y > viewRect.y then
			disY = viewRect.y - cascadeBound.y
		elseif cascadeBound.y + cascadeBound.height < viewRect.y + viewRect.height then
			disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
		end
	end

	if 0 ~= disX or 0 ~= disY then
		transition.moveBy(self._scrollNode, {x = disX, y = disY, time = 0.3, easing = "backout", onComplete = function()
			self:callListener{name = "scrollEnd"}
		end})
	end
end

-- 是否显示到边缘
function JScrollView:isSideShow()
	local bound = self:getScrollNodeRect()
	local viewRect = self:getViewRectInWorldSpace()
	return bound.x > viewRect.x or bound.y > viewRect.y
		or viewRect.x + viewRect.width > bound.x + bound.width 
		or viewRect.y + viewRect.height > bound.y + bound.height
end

function JScrollView:getScrollNodeRect()
	return self._scrollNode:getCascadeBoundingBox()
end

function JScrollView:getViewRectInWorldSpace()
	local rect = self:convertToWorldSpace(cc.p(self._viewRect.x, self._viewRect.y))
	rect.width = self._viewRect.width
	rect.height = self._viewRect.height
	return rect
end

function JScrollView:callListener(event)
	if self._scrollListener and type(self._scrollListener) == "function" then
		event.scrollView = self
		self._scrollListener(event)
	end
end

function JScrollView:enableScrollBar()
	local bound = self:getScrollNodeRect()
	if self._sbV then
		self._sbV:setVisible(false)
		transition.stopTarget(self._sbV)
		self._sbV:setOpacity(128)
		local size = self._sbV:getContentSize()
		if self._viewRect.height < bound.height then
			local barH = self._viewRect.height * self._viewRect.height / bound.height
			if barH < size.width then
				-- 保证bar不会太小
				barH = size.width
			end
			self._sbV:setContentSize(size.width, barH)
			self._sbV:setPosition(self._viewRect.x + self._viewRect.width - size.width / 2, self._viewRect.y + barH / 2)
		end
	end
	if self._sbH then
		self._sbH:setVisible(false)
		transition.stopTarget(self._sbH)
		self._sbH:setOpacity(128)
		local size = self._sbH:getContentSize()
		if self._viewRect.width < bound.width then
			local barW = self._viewRect.width * self._viewRect.width / bound.width
			if barW < size.height then
				barW = size.height
			end
			self._sbH:setContentSize(barW, size.height)
			self._sbH:setPosition(self._viewRect.x + barW / 2, self._viewRect.y + size.height / 2)
		end
	end
end

function JScrollView:disableScrollBar()
	if self._sbV then
		transition.fadeOut(self._sbV, {time = 0.3, onComplete = function()
			self._sbV:setOpacity(128)
			self._sbV:setVisible(false)
		end})
	end
	if self._sbH then
		transition.fadeOut(self._sbH, {time = 1.5, onComplete = function()
			self._sbH:setOpacity(128)
			self._sbH:setVisible(false)
		end})
	end
end

function JScrollView:scaleToParent()
	local parent, node, scale = nil, self, {x = 1, y = 1}
	while true do
		scale.x = scale.x * node:getScaleX()
		scale.y = scale.y * node:getScaleY()
		parent = node:getParent()
		if not parent then
			break
		end
		node = parent
	end
	return scale
end

function JScrollView:onTouch(event)
	if "began" == event.name then
		if not self:isTouchInViewRect(event) then
			return false
		end
		if self._isTouchOnContent then
			if not cc.rectContainsPoint(self:getScrollNodeRect(), cc.p(event.x, event.y)) then
				return false
			end
		end
		self._prevX, self._prevY = event.x, event.y
		self._isTouchMoved = false
		local x, y = self._scrollNode:getPosition()
		self._position = {x = x, y = y}

		transition.stopTarget(self._scrollNode)
		self:callListener{name = "began", x = event.x, y = event.y}
		self:enableScrollBar()
		self._scaleToWorldSpace = self:scaleToParent()
		return true
	elseif "moved" == event.name then
		if math.abs(event.x - self._prevX) > 6 or math.abs(event.y - self._prevY) > 6 then
			self._isTouchMoved = true
			self._scrollSpeed.x, self._scrollSpeed.y = event.x - event.prevX, event.y - event.prevY

			if self._direction == Direction.VERTICAL then
				self._scrollSpeed.x = 0
			elseif self._direction == Direction.HORIZONTAL then
				self._scrollSpeed.y = 0
			end

			self:scrollBy(self._scrollSpeed.x, self._scrollSpeed.y)
			self:callListener{name = "moved", x = event.x, y = event.y}
		end
	elseif "ended" == event.name then
		if self._isTouchMoved then
			self._isTouchMoved = false
			self:scrollAuto()
			self:callListener{name = "ended", x = event.x, y = event.y}
			self:disableScrollBar()
		else
			self:callListener{name = "clicked", x = event.x, y = event.y}
		end
	end
end

--- 注册滚动控件的监听函数
-- @param function listener 监听函数
-- @return JScrollView
function JScrollView:onScrollListener(listener)
	self._scrollListener = listener
	return self
end

function JScrollView:onUpdate(dt)
	if self._isTouchMoved then
		local bound = self:getScrollNodeRect()
		if self._sbV then
			self._sbV:setVisible(true)
			local size = self._sbV:getContentSize()
			local posY = (self._viewRect.y - bound.y) * (self._viewRect.height - size.height) / (bound.height - self._viewRect.height) 
				+ self._viewRect.y + size.height / 2
			local x, y = self._sbV:getPosition()
			self._sbV:setPosition(x, posY)
		end
		if self._sbH then
			self._sbH:setVisible(true)
			local size = self._sbH:getContentSize()
			local posX = (self._viewRect.x - bound.x) * (self._viewRect.width - size.width) / (bound.width - self._viewRect.width)
				+ self._viewRect.x + size.width / 2
			local x, y = self._sbH:getPosition()
			self._sbH:setPosition(posX, y)
		end
	end
end

function JScrollView:onEnter()
	self:scheduleUpdate()
end

function JScrollView:onCleanup()
	self:unscheduleUpdate()
	self:setNodeEventEnabled(false)
end

return JScrollView