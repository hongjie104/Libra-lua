--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 13:27:42
--

local Button = require("libra.ui.components.JButton")

local LibraToolbar = class("LibraToolbar", function ()
	return cc.ClippingRegionNode:create()
end)

function LibraToolbar:ctor(container, goBackCallback)
	self._container = container
	self._goBackCallback = goBackCallback
	makeUIComponent(self)
	self:setNodeEventEnabled(true)

	local funcList = {
		{
			func = function (event)
				require("libra.log4q.LogPanel").new():show(self._container)
				self:goBack()
			end,
			label = {text = "log"}
		},
		{
			func = function (event)
				self:goBack()
			end,
			label = {text = "dsfd"}
		}
	}

	self._btns = { }
	local btnW, btnH, btnGap = 94, 50, 6
	local btn = nil
	for i, v in ipairs(funcList) do
		btn = Button.new({normal = "ui/ty_anniu02.png", label = v.label}):addTo(self):pos(btnW / -2, btnH / 2)
		btn:addEventListener(BUTTON_EVENT.CLICKED, v.func)
		btn.outX = btnW / 2 + (i - 1) * (btnW + btnGap)
		btn.backX = btnW / -2
		self._btns[i] = btn
	end

	self:setClippingRegion(cc.rect(0, 0, #funcList * (btnW + btnGap), btnH))

	self._bg = display.newNode():addTo(self, -1):pos(-display.width, -display.height)
	self._bg:setContentSize(cc.size(display.width * 2, display.height * 2))
	self._bg:setTouchEnabled(true)
	self._bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == 'began' then
			return true
		elseif event.name == "ended" then
			self:goBack()
		end
	end)
end

function LibraToolbar:comeOut()
	for i, v in ipairs(self._btns) do
		transition.moveTo(v, {time = .2, x = v.outX})
	end
end

function LibraToolbar:goBack()
	for i, v in ipairs(self._btns) do
		transition.moveTo(v, {time = .2, x = v.backX})
	end
	require("framework.scheduler").performWithDelayGlobal(function ()
		self._goBackCallback()
		self:removeSelf()
	end, .2)
end

function LibraToolbar:onCleanup()
	self:setNodeEventEnabled(false)
	self._bg:removeAllNodeEventListeners()
end

--=====================================================

local LibraIcon = class("LibraIcon", require('libra.ui.components.JContainer'))

function LibraIcon:ctor(param)
	LibraIcon.super.ctor(self, param)

	self._icon = Button.new({normal = "uiEditor/uiEditorIco.jpg"}):addToContainer(self)
	-- self._icon = Button.new({normal = "uiEditor/closeBtn_down.png"}):addToContainer(self)

	self._iconWidthHarf, self._iconHeightHarf = self._icon:actualWidth() / 2, self._icon:actualHeight() / 2
	self._icon:setPosition(self._iconWidthHarf, self._iconHeightHarf)

	self._icon:addEventListener(BUTTON_EVENT.TOUCH_MOVED, function (evt)
		local newX, newY = evt.x, evt.y
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
		self._icon:setPosition(newX, newY)

		if self._toolbar then
			self._toolbar:setPosition(newX + 15, newY - 25)
		end
	end)

	self._icon:addEventListener(BUTTON_EVENT.CLICKED, function ()
		if not self._icon:isTouchMoved() then
			if self._toolbar then
				self._toolbar:goBack()
			else
				self._toolbar = LibraToolbar.new(self, function ()
					self._toolbar = nil
				end):addToContainer(self, -1)

				local x, y = self._icon:getPosition()
				x = x + 15
				y = y - 25
				self._toolbar:setPosition(x, y)
				self._toolbar:comeOut()
			end
		end
	end)
end

return LibraIcon
