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
end

function JPanel:show(container)
	if not self._isShowing then
		self:addToContainer(container)
		self._isShowing = true
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

return JPanel