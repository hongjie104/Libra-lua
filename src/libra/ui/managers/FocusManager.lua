--
-- UI焦点管理
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-24 19:48:12
--

local FocusManager = class("FocusManager")

function FocusManager:ctor()
	-- 当前获得焦点的组件
	self._curFocusComponent = nil
	-- 焦点组件所在的容器
	self._curFocusContainer = nil
	-- 存放焦点的容器，它应该在所有的UI之上
	self._focusNode = display.newNode():addTo(libraUIManager:getUIContainer(), 99998)
	self._focusNode:setTouchEnabled(false)
	self._focusNode:setTouchSwallowEnabled(false)
	-- 焦点图片
	self._focusSprite = display.newScale9Sprite("ui/border.png", display.cx, display.cy, cc.size(9, 9)):addTo(self._focusNode)
end

function FocusManager:init()

end

function FocusManager:curFocusComponent(component)
	if self._curFocusComponent ~= component then
		-- if self._curFocusComponent then
		-- 	-- self._curFocusComponent:lostFocus()
		-- end
		self._curFocusComponent = component
		-- self._curFocusComponent:getFocus()
	end
end

return FocusManager