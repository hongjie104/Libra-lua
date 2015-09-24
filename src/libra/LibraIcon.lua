--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 13:27:42
--

local Button = require("libra.ui.components.JButton")

local LibraToolbar = class("LibraToolbar", require("libra.ui.components.JContainer"))

function LibraToolbar:ctor(goBackCallback)
	LibraToolbar.super.ctor(self)
	self._goBackCallback = goBackCallback

	local funcList = {
		{
			func = function (event)
				self:goBack(function ()
					-- local p = require("libra.log4q.LogPanel").new()
					-- p:show(self)
					-- uiManager:activeContainer(p)
					uiManager:forward("logPanel")
				end)
			end,
			label = {text = "log"}
		},
		-- {
		-- 	func = function (event)
		-- 		-- require("libra.debug.DebugPanel").new():show(self)
		-- 		-- self:goBack()
		-- 	end,
		-- 	label = {text = "debug"}
		-- }
	}

	self:buildGrid(10)
	self._btns = { }
	local btnW, btnH, btnGap = 94, 50, 6
	local btn = nil
	for i, v in ipairs(funcList) do
		btn = Button.new({normal = "ui/ty_anniu02.png", label = v.label}):addToContainer(self):pos(btnW / -2, btnH / 2)
		btn:addEventListener(BUTTON_EVENT.CLICKED, v.func)
		btn.outX = btnW / 2 + (i - 1) * (btnW + btnGap)
		btn.backX = btnW / -2
		self._btns[i] = btn
		self:addGridComponent(btn)
	end

	self._bg = display.newColorLayer(cc.c4b(0, 0, 0, 150)):addTo(self, -1):pos(-display.width, -display.height)
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
		transition.moveTo(v, {time = .2, x = v.outX, easing = "BACKOUT"})
	end
end

function LibraToolbar:goBack(callback)
	for i, v in ipairs(self._btns) do
		transition.moveTo(v, {time = .2, x = v.backX, onComplete = function ()
			self._goBackCallback()
			self:removeSelf()
			if callback and type(callback) == "function" then
				callback()
			end
		end})
	end
end

function LibraToolbar:onCleanup()
	self:setNodeEventEnabled(false)
	self._bg:removeAllNodeEventListeners()
end

--- 处理返回键的逻辑，如果需要用到返回键，那么该方法的返回值必须得是true
function LibraToolbar:doBackHandler()
	self:goBack()
	return true
end

--=====================================================

local LibraIcon = class("LibraIcon", require('libra.ui.components.JContainer'))

function LibraIcon:ctor(param)
	LibraIcon.super.ctor(self, param)

	self._icon = Button.new({normal = "uiEditor/uiEditorIco.jpg"}):addToContainer(self)

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
				self:fold()
			else
				self:unfold()
			end
		end
	end)
end

-- 折叠
function LibraIcon:fold()
	if self._toolbar then
		self._toolbar:goBack()
	end
end

-- 展开
function LibraIcon:unfold()
	if not self._toolbar then
		self._toolbar = LibraToolbar.new(function ()
			self._toolbar = nil
			uiManager:resetActiveContainer()
		end):addToContainer(self, -1)

		local x, y = self._icon:getPosition()
		x = x + 15 + display.cx
		y = y - 25 + display.cy
		self._toolbar:setPosition(x, y)
		self._toolbar:comeOut()

		uiManager:activeContainer(self._toolbar)
	end
end

return LibraIcon
