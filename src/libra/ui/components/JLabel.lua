--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-12 20:52:33
--

local JLabel = class("JLabel", function (param)
	assert(param, "JLabel:class() - invalid param:param is nil")
	if param.isBMFont then
		return display.newBMFontLabel(param)
	else
		return display.newTTFLabel(param)
	end
end)

function JLabel:ctor()
	makeUIComponent(self)
end

return JLabel