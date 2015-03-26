--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-24 21:54:40
--

local UIPreviewPanel = class("UIPreviewPanel", require("libra.uiEditor.Panel"))

function UIPreviewPanel:ctor(uiConfig)
	UIPreviewPanel.super.ctor(self, display.width, display.height)
	-- 创建一个纯黑色的背景
	self._bg:removeSelf()
	self._bg = display.newColorLayer(cc.c4b(0, 0, 0, 255)):addTo(self, -1)

	self:createUI(uiConfig.uiConfig)
	for i, v in ipairs(uiConfig.uiConfig) do
		self[v.id]:setTouchEnabled(true)
		self[v.id]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				return true
			elseif event.name == "ended" then
				if self[v.id]:isPointIn(event.x, event.y) then
					-- dump(self[v.id].class)
					dump(self.class.super)
				end
			end
		end)
	end
end

return UIPreviewPanel