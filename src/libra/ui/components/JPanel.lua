--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:44:18
--

local JPanel = class("JPanel", require("libra.ui.components.JContainer"))

-- @param param {bg="背景图", isScale9 = true}
function JPanel:ctor(param)
	JPanel.super.ctor(self, param)
	-- 添加一个layer以吞噬掉触摸事件
	display.newLayer():align(display.CENTER):addTo(self, -2)
	self._isShowing = false
	self:setNodeEventEnabled(true)
	-- self:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
	self:align(display.CENTER, display.cx, display.cy)
end

function JPanel:show(container)
	if not self._isShowing then
		self:addToContainer(container)
		self._isShowing = true
		self:scale(.2)
		transition.scaleTo(self, {time = .3, scale = 1, easing = "BACKOUT"})
	end
	return self
end

function JPanel:close()
	if self._isShowing then
		self._isShowing = false
		-- 之所以在关闭前把所有组件都unscheduleUpdate一下
		-- 是因为JListView控件在父容器的scale不为1时，其onUpdate方法会导致崩溃。。。
		-- 所以关闭onUpdate，然后再改变面板大小
		for _, v in ipairs(self._componentList) do
			if v.unscheduleUpdate then
				v:unscheduleUpdate()
			end
		end
		transition.scaleTo(self, {time = .2, scale = .5, easing = "BACKIN", onComplete = function ()
			self:removeSelf()
		end})
	end
	return self
end

function JPanel:isShowing()
	return self._isShowing
end

function JPanel:onEnter()
	-- do nothing
end

function JPanel:onCleanup()
	self:setNodeEventEnabled(false)
end

return JPanel