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
	self._index = 0
end

function JListViewItem:getContent()
	return self._content
end

function JListViewItem:index(int)
	if type(int) == "number" then
		self._index = int
		return self
	end
	return self._index
end

-- function JListViewItem:onTouchBegan()
-- 	-- body
-- end

-- function JListViewItem:onTouchEnded()
-- 	-- body
-- end

return JListViewItem
