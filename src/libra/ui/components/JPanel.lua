--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:44:18
--

local JPanel = class("JPanel", require("libra.ui.components.JContainer"))

-- @param param {bg="背景图", isScale9 = true}
function JPanel:ctor(param)
	JPanel.super.ctor(self, param)
	-- 添加一个layer以吞噬掉触摸事件
	display.newLayer():align(display.CENTER, display.cx, display.cy):addTo(self, -2)

	self._isShowing = false

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onUpdate))
	self:setNodeEventEnabled(true)
end

function JPanel:show(container)
	if not self._isShowing then
		self:addToContainer(container)
		self._isShowing = true
		self:scaleToShow()
	end
	return self
end

function JPanel:close()
	if self._isShowing then
		self._isShowing = false
		self:removeSelf()
	end
	return self
end

function JPanel:isShowing()
	return self._isShowing
end

function JPanel:scaleToShow()
	self._curScale = .2
	self:setScaleToKeepCenter(self._curScale)
	self:scheduleUpdate()
end

function JPanel:setScaleToKeepCenter(val)
	self:scale(val)
	self:setPosition(display.cx - display.cx * val, display.cy - display.cy * val)
end

function JPanel:onUpdate(dt)
	self._curScale = self._curScale + .05
	self:setScaleToKeepCenter(self._curScale)
	if self._curScale >= 0.9 then
		self._curScale = 1
		self:setScaleToKeepCenter(self._curScale)
		self:unscheduleUpdate()
	end
end

function JPanel:onEnter()
	-- do nothing
end

function JPanel:onCleanup()
	self:setNodeEventEnabled(false)
end

return JPanel