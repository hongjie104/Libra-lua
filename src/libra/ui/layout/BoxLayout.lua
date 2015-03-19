--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 15:36:21
--

local BoxLayout = class("BoxLayout", require("libra.ui.layout.BaseLayout"))

-- @param isHorizontal 是不是水平排列,默认是水平的
function BoxLayout:ctor(componentList, isHorizontal, gap)
	BoxLayout.super.ctor(self, componentList)
	self._isHorizontal = isHorizontal or true
	self._gap = gap or 0
end

function BoxLayout:updateLayout()
	if #self._componentList > 0 then
		local containerWidth, containerHeight = self._componentList[1]:getParent():getSize()
		if self._isHorizontal then
			local x = (containerWidth - self._componentList[1]:actualWidth()) / -2
			local y = (containerHeight - self._componentList[1]:actualHeight()) / 2
			for _, v in ipairs(self._componentList) do
				v:pos(x, y)
				x = x + v:actualWidth() + self._gap
			end
		else
			local x = (containerWidth - self._componentList[1]:actualWidth()) / -2
			local y = (containerHeight - self._componentList[1]:actualHeight()) / 2
			for _, v in ipairs(self._componentList) do
				v:pos(x, y)
				y = y - v:actualHeight() - self._gap
			end
		end
	end
end

return BoxLayout