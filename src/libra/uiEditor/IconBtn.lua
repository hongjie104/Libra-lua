--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 13:27:42
--

local IconBtn = class("IconBtn", require('libra.ui.components.JButton'))

function IconBtn:ctor(param, onClicked)
	IconBtn.super.ctor(self, param, onClicked)

	self._iconWidthHarf, self._iconHeightHarf = self:actualWidth() / 2, self:actualHeight() / 2
	self:setPosition(self._iconWidthHarf, self._iconHeightHarf)

	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (evt)
		if evt.name == "began" then
			return true
		elseif evt.name == "moved" then
			local newX, newY = self:x() + evt.x - evt.prevX, self:y() + evt.y - evt.prevY
			if newX - self._iconWidthHarf < 0 then
				newX = self._iconWidthHarf
			elseif newX + self._iconWidthHarf > display.width then
				newX = display.width - self._iconWidthHarf
			end
			if newY - self._iconHeightHarf < 0 then
				newY = self._iconHeightHarf
			elseif newY + self._iconHeightHarf > display.height then
				newY = display.height - self._iconHeightHarf
			end
			self:setPosition(newX, newY)
		end
	end)
end

return IconBtn
