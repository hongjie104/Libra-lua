--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-19 20:35:57
--

local JPageViewItem = class("JPageViewItem", function ()
	return display.newNode()
end)

function JPageViewItem:ctor()
	makeUIComponent(self)
end

return JPageViewItem