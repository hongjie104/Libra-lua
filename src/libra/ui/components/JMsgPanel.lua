--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-24 22:02:05
--

local JMsgPanel = class("JMsgPanel", function (param)
	assert(param, "JMsgPanel:class() - invalid param:param is nil")
	if param.isScale9 then
		param.imgSize = param.imgSize or cc.size(400, 300)
		return display.newScale9Sprite(param.img, param.x, param.y, param.imgSize, param.capInsets)
	else
		return display.newSprite(param.img, param.x, param.y)
	end
end)

function JMsgPanel:ctor(param)
	makeUIComponent(self)
	param.imgSize = param.imgSize or self:getContentSize()
	param.x = param.imgSize.width / 2
	param.y = param.imgSize.height / 2
	param.align = param.align or cc.TEXT_ALIGNMENT_CENTER
	require("libra.ui.components.JLabel").new(param):addTo(self)
end

function JMsgPanel:show(container)
	if not self._isShowing then
		container = container or uiManager:getUIContainer()
		local size = container:getContentSize()
		self:pos(size.width / 2, size.height / 2):addToContainer(container)
		self._isShowing = true
		self:performWithDelay(function ()
			self:removeSelf()
		end, 2)
	end
	return self
end

return JMsgPanel