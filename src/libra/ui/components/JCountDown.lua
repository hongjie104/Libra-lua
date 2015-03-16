--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-14 21:16:03
--

local JCountDown = class("JCountDown", require("libra.ui.components.JLabel"))

function JCountDown:ctor(param, onFinished)
	JCountDown.super.ctor(self, param)
	self._onFinished = onFinished

 	local seq = transition.sequence({
        cc.DelayTime:create(1),
        cc.CallFunc:create(handler(self, self.onCountDownActionHandler)),
    })
    self._countDownAction = cc.RepeatForever:create(seq)
end

function JCountDown:start(second, minute, hour)
	second = second or 0
	minute = minute or 0
	hour = hour or 0
	
	self._hour, self._minute, self._second = hour, minute, second
	if not self._isRunning then
		self:runAction(self._countDownAction)
		self._isRunning = true
	end
	self:updateDisplay()
end

function JCountDown:pause()
	if self._isRunning then
		transition.pauseTarget(self)
		self._isRunning = false
	end
end

function JCountDown:resume()
	if not self._isRunning then
		transition.resumeTarget(self)
		self._isRunning = true
	end
end

function JCountDown:stop()
	if self._isRunning then
		transition.stopTarget(self)
		self._isRunning = false
	end
end

function JCountDown:isRunning()
	return self._isRunning
end

function JCountDown:onCountDownActionHandler()
	self._second = self._second - 1
	if self._hour == 0 then
		if self._minute == 0 then
			if self._second == 0 then
				if self._onFinished then
					if type(self._onFinished) == "function" then
						self._onFinished()
					end
				end
			end
		end
	end
	if self._second < 0 then
		self._second = 59
		self._minute = self._minute - 1
		if self._minute < 0 then
			self._minute = 59
			self._hour = self._hour - 1
			if self._hour < 0 then
				self._hour, self._minute, self._second = 0, 0, 0
				self:stop()
			end
		end
	end
	self:updateDisplay()
end

function JCountDown:updateDisplay()
	self:setString(string.format("%02s:%02s:%02s", self._hour, self._minute, self._second))
end

function JCountDown:onCleanup()
	self:stop()
end

return JCountDown