--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-16 21:38:43
--

local JButton = import(".JButton")

local JAlert = class("JAlert", require('libra.ui.components.JPanel'))

-- @param param {bg="背景图", isScale9 = true}
function JAlert:ctor(param)
	JAlert.super.ctor(self, param)
end

function JAlert:show(isShowOK, isShowCancel, onClicked)
	self._onClicked = onClicked
	if isShowOK then
		self._okBtn = JButton.new({label = {text = "ok"}, normal = "btnRed2_normal.png", down = "btnRed2_down.png"}, 
			{onTouchEnded = handler(self, self.onOKClicked)}):addTo(self)
	end
	if isShowCancel then
		self._cancelBtn = JButton.new({label = {text = "cancel"}, normal = "btnRed2_normal.png", down = "btnRed2_down.png"}, 
			{onTouchEnded = handler(self, self.onCancelClicked)}):addTo(self)
	end
	if self._okBtn and self._cancelBtn then
		self._okBtn:align(display.CENTER_BOTTOM, self._okBtn:actualWidth() / -2, self._actualHeight / -2)
		self._cancelBtn:align(display.CENTER_BOTTOM, self._cancelBtn:actualWidth() / 2, self._actualHeight / -2)
	elseif self._okBtn then
		self._okBtn:align(display.CENTER_BOTTOM, 0, self._actualHeight / -2)
	elseif self._cancelBtn then
		self._cancelBtn:align(display.CENTER_BOTTOM, 0, self._actualHeight / -2)
	end
	JAlert.super.show(self)
end

function JAlert:onOKClicked()
	if self._onClicked then
		if type(self._onClicked) == "function" then
			self._onClicked(true)
		end
	end
end

function JAlert:onCancelClicked()
	if self._onClicked then
		if type(self._onClicked) == "function" then
			self._onClicked(false)
		end
	end
end

return JAlert