--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:44:18
--

local Button = require("libra.ui.components.JButton")

local JPanel = class("JPanel", require("libra.ui.components.JContainer"))

-- @param param {bg="背景图", size = cc.size() or nil, capInsets = cc.rect() or nil, closeBtnParam = "关闭按钮参数" or nil}
function JPanel:ctor(param)
	param = param or { }
	JPanel.super.ctor(self, param)
	-- 添加一个有色layer以吞噬掉触摸事件，顺带可以支持面板有一个全屏的背景色
	local cc4b = param.bgColor or cc.c4b(0, 0, 0, 0)
	self._bgLayer = display.newColorLayer(cc4b):pos((self._actualWidth - display.width) / 2, (self._actualHeight - display.height) / 2):addTo(self, -2)

	if self._param.closeBtnParam then
		self._closeBtn = Button.new(self._param.closeBtnParam):addToContainer(self):pos(self._actualWidth, self._actualHeight)
		self._closeBtn:addEventListener(BUTTON_EVENT.CLICKED, handler(self, self.close))
	end

	self._isShowing = false
end

function JPanel:show(animation, container)
	if not self._isShowing then
		self:addToContainer(container)
		self._isShowing = true
		if animation then
			if type(self[animation]) == "function" then
				self[animation](self)
			end
		end
	end
	return self
end

--- 从中心向外展开
-- @private
function JPanel:showFromCenter()
	self:scale(.2)
	transition.scaleTo(self, {time = .3, scale = 1, easing = "BACKOUT"})
end

--- 从上面飞下来
-- @private
function JPanel:showFromTop()
	self:y(self._actualHeight / 2 + display.height)
	transition.moveTo(self, {time = .3, y = display.cy, easing = "BACKOUT"})
end

--- 从左边飞来
-- @private
function JPanel:showFromLeft()
	self:x(self._actualWidth / -2 - display.width)
	transition.moveTo(self, {time = .3, x = display.cx, easing = "BACKOUT"})
end

--- 从右边飞来
-- @private
function JPanel:showFromLeft()
	self:x(self._actualWidth / 2 + display.width)
	transition.moveTo(self, {time = .3, x = display.cx, easing = "BACKOUT"})
end

--- 关闭面板
-- @param animation 关闭的动画
-- @param direct 是否直接关闭，不播放关闭动画
function JPanel:close(animation, direct)
	if self._isShowing then
		self._isShowing = false
		-- 之所以在关闭前把所有组件都unscheduleUpdate一下
		-- 是因为JListView控件在父容器的scale不为1时，其onUpdate方法会导致崩溃。。。
		-- 所以关闭onUpdate，然后再改变面板大小
		for _, v in ipairs(self._componentList) do
			if v.unscheduleUpdate and type(v.unscheduleUpdate) == "function" then
				v:unscheduleUpdate()
			end
		end
		if not direct and animation and type(self[animation]) == "function" then
			self[animation](self)
		else
			-- self:removeSelf()
			uiManager:back()
		end
	end
	return self
end

--- 从中心向里关闭
-- @private
function JPanel:closeFromCenter()
	transition.scaleTo(self, {time = .2, scale = .5, easing = "BACKIN", onComplete = function ()
		-- self:removeSelf()
		uiManager:back()
	end})
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

function JPanel:onCleanup()
	JPanel.super.onCleanup(self)
	if self._closeBtn then
		self._closeBtn:removeAllNodeEventListeners()
	end
end

return JPanel