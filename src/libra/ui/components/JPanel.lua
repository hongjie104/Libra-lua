--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:44:18
--

local JPanel = class("JPanel", require("libra.ui.components.JContainer"))

-- @param param {bg="背景图", isScale9 = true}
function JPanel:ctor(param)
	JPanel.super.ctor(self, param)
	-- 添加一个有色layer以吞噬掉触摸事件，顺带可以支持面板有一个全屏的背景色
	local cc4b = param.bgColor or cc.c4b(0, 0, 0, 0)
	self._bgLayer = display.newColorLayer(cc4b):pos((self._actualWidth - display.width) / 2, (self._actualHeight - display.height) / 2):addTo(self, -2)

	self._isShowing = false
	self:setNodeEventEnabled(true)
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

function JPanel:setSize(width, height)
	JPanel.super.setSize(self, width, height)
	if self._bgLayer then
		self._bgLayer:pos((self._actualWidth - display.width) / 2, (self._actualHeight - display.height) / 2)
	end	
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