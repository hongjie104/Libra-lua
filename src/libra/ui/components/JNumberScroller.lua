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
	self._zeroLabel = Label.new(param):addTo(self):align(display.BOTTOM_LEFT)--:y(self._numsLabel:actualHeight())
	self._fontHeight = self._zeroLabel:getContentSize().height

	local str = '9'
	for i = 8, 1, -1 do
		str = str .. '\n' .. i
	end
	param.text = str
	self._numsLabel = Label.new(param):addTo(self):align(display.BOTTOM_LEFT, 0, self._fontHeight)

	self._curNum = 0
end

function NumCol:actualWidth()
	return self._numsLabel:getContentSize().width
end

-- function NumCol:startScroll(onCheck)
-- 	self._onCheck = onCheck
-- 	self:scroll()
-- end

-- function NumCol:scroll()
-- 	transition.moveBy(self, {time = .1, y = -self._fontHeight, onComplete = function ()
-- 		self._curNum = self._curNum + 1
-- 		if self._curNum == 1 then
-- 			self._zeroLabel:y(self._fontHeight + self._numsLabel:getContentSize().height)
-- 		elseif self._curNum == 10 then
-- 			self._curNum = 0
-- 			self._zeroLabel:y(0)
-- 			self._numsLabel:y(self._fontHeight)
-- 			self:y(0)
-- 		end
-- 		if type(self._onCheck) == "function" then
-- 			self._onCheck()
-- 		end
-- 	end})
-- end

function NumCol:scroll(times, time)
	self._totalTimes = times
	self._curTimes = 0
	self:doScroll(time)
end

function NumCol:doScroll(time)
	if self._curTimes ~= self._totalTimes then
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
			self._curTimes = self._curTimes + 1
			print("self._curTimes", self._curTimes, self._totalTimes)
			self:doScroll(time)
		end})
	else
		print("okokok")
	end
end

--===========================================================================================

local JNumberScroller = class("JNumberScroller", require("libra.ui.components.JContainer"))

function JNumberScroller:ctor(param)
	JNumberScroller.super.ctor(self, param)
	local length = param and param.length or 3
	if length < 1 then
		length = 1
	end
	local gap = param and param.gap or 5
	local size = param and param.size or 24
	self._labelList = { }
	local label, x = nil, -gap
	for i = 1, length do
		label = NumCol.new(param):addTo(self)
		self._labelList[i] = label
		label:pos(x + gap, label:getContentSize().height / 2)
		x = x + gap + label:actualWidth()
	end

	self._targetNum = -1
	self._curNum = 0

	-- self._checkHandler = handler(self, self.check)
end

function JNumberScroller:scrollTo(num)
	if self._targetNum ~= self._curNum then
		self._targetNum = num

		local times, time, mod = 1, .01, 0
		for i = #self._labelList, 1, -1 do
			mod = num % 10
			num = math.floor(num / 10)
			times = num * 10 + mod
			self._labelList[i]:scroll(times, time)
			time = time * 10
		end
	end
end

-- function JNumberScroller:check()
-- 	self._curNum = self._curNum + 1
-- 	if (self._curNum + 1) % 10 == 0 then
-- 		self._labelList[#self._labelList - 1]:startScroll()
-- 	end
-- 	self:scrollTo(self._targetNum)
-- end

return JNumberScroller