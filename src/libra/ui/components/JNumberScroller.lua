--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-23 21:15:12
--

local Label = import(".JLabel")

local NumCol = class("NumCol", function ()
	return display.newNode()
end)

function NumCol:ctor(param)
	param = param or { }

	param.text = '0'
	if param.outlineColor then
		self._zeroLabel = cc.ui.UILabel.newTTFLabel_(param):addTo(self):align(display.BOTTOM_LEFT)
		self._zeroLabel:enableOutline(param.outlineColor, 2)
	else
		self._zeroLabel = Label.new(param):addTo(self):align(display.BOTTOM_LEFT)
	end
	self._fontHeight = param.fontHeight or self._zeroLabel:getContentSize().height

	local str = '9'
	for i = 8, 1, -1 do
		str = str .. '\n' .. i
	end
	param.text = str
	if param.outlineColor then
		self._numsLabel = cc.ui.UILabel.newTTFLabel_(param):addTo(self):align(display.BOTTOM_LEFT, 0, self._fontHeight)
		self._numsLabel:enableOutline(param.outlineColor, 2)
	else
		self._numsLabel = Label.new(param):addTo(self):align(display.BOTTOM_LEFT, 0, self._fontHeight)
	end

	self._curNum = 0
end

function NumCol:curNum(int)
	if int then
		if self._curNum ~= int then
			self:scrollTo(int, .1)
		end
		return self
	end
	return self._curNum
end

function NumCol:actualWidth()
	return self._numsLabel:getContentSize().width
end

function NumCol:getFontHeight()
	return self._fontHeight
end

function NumCol:scrollTo(num, time, direction)
	self._targetNum = num
	time = time or .1
	if self._targetNum ~= self._curNum then
		direction = direction or Direction.TOP_TO_BOTTOM
		self:doScroll(time, direction)
	end
end

function NumCol:doScroll(time, direction)
	if self._targetNum ~= self._curNum then
		if direction == Direction.TOP_TO_BOTTOM then
			transition.moveBy(self, {time = time, y = -self._fontHeight, onComplete = function ()
				self._curNum = self._curNum + 1
				if self._curNum == 1 then
					self._zeroLabel:y(self._fontHeight + self._numsLabel:getContentSize().height)
				elseif self._curNum == 10 then
					self._curNum = 0
					self._zeroLabel:y(0)
					self._numsLabel:y(self._fontHeight)
					self:y(0)
				end
				self:doScroll(time, direction)
			end})
		else
			if self._curNum == 0 then
				self._numsLabel:y(self._fontHeight * -9)
			end
			transition.moveBy(self, {time = time, y = self._fontHeight, onComplete = function ()
				self._curNum = self._curNum - 1
				if self._curNum < 0 then
					self._curNum = 9
				elseif self._curNum == 0 then
					self._zeroLabel:y(0)
					self._numsLabel:y(self._fontHeight)
					self:y(0)
				end
				self:doScroll(time, direction)
			end})
		end
	end
end

--===========================================================================================

local JNumberScroller = class("JNumberScroller", function ()
	return cc.ClippingRegionNode:create()
end)

function JNumberScroller:ctor(param)
	makeUIComponent(self)
	param = param or { }
	local length = param.length or 3
	if length < 1 then
		length = 1
	end
	local gap = param.gap or 5
	self._labelList = { }
	local label, x = nil, -gap
	for i = 1, length do
		label = NumCol.new(param):addTo(self)
		self._labelList[i] = label
		label:pos(x + gap, label:getContentSize().height / 2)
		x = x + gap + label:actualWidth()
	end

	self:setClippingRegion({x = 0, y = 0, width = length * self._labelList[1]:actualWidth() + gap * (#self._labelList - 1), height = self._labelList[1]:getFontHeight()})

	self._curNum = 0
end

function JNumberScroller:scrollTo(num, direction)
	if num ~= self._curNum then
		self._curNum = num
		local mode = 0
		for i = #self._labelList, 1, -1 do
			self._labelList[i]:scrollTo(num % 10, .1, direction)
			num = math.floor(num / 10)
		end
	end
end

function JNumberScroller:curNum(int)
	if int then
		if self._curNum ~= int then
			self:scrollTo(int)
		end
		return self
	end
	return self._curNum
end

return JNumberScroller