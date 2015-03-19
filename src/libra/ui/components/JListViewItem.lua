--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-19 14:02:08
--

local JListViewItem = class("JListViewItem", function ()
	return display.newNode()
end)

function JListViewItem:ctor(content)
	assert(content, "JListViewItem:class() - invalid content:content is nil")
	makeUIComponent(self)

	self._content = content:addTo(self)
end

function JListViewItem:getContent()
	return self._content
end

return JListViewItem
