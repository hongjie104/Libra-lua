--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:00:17
--

local UIManager = class("UIManager")

function UIManager:ctor()
	-- ui容器，所有的ui组件都应该放在这里容器之中
	self._uiContainer = require("libra.ui.components.JContainer").new()
	self._uiContainer:setSize(display.width, display.height)
	self._uiContainer:retain()

	-- 注册按键事件
	self._uiContainer:setKeypadEnabled(true)
	self._uiContainer:addNodeEventListener(cc.KEYPAD_EVENT, handler(self, self.onKeyPadEvent))

	-- 当前激活的面板容器
	self._activeContainer = self._uiContainer

	-- 面板路径列表
	-- 示例:
	--[[
	self._panelPath = {
		loginPanel = "app.view.login.LoginPanel",
		gamePanel = "app.view.login.GamePanel"
	}
	]]
	self._panelPath = { }
	self._showingPanel = { }
end

function UIManager:getUIContainer()
	return self._uiContainer
end

function UIManager:activeContainer(val)
	if val then
		self:removeActiveContainer()
		self._activeContainer = val
		self._activeContainer:initFocusComponent()
		return self
	end
	return self._activeContainer
end

function UIManager:removeActiveContainer()
	if self._activeContainer then
		self._activeContainer:uninitFocusComponent()
		self._activeContainer = nil
	end
end

-- @private
function UIManager:onKeyPadEvent(event)
	if self._activeContainer then
		if event.name == "Pressed" then
			self._activeContainer:onKeyPressed(event.code)
		elseif event.name == "Released" then
			self._activeContainer:onKeyReleased(event.code)
		end
	end
end

function UIManager:getContainer(name)
	for i, v in ipairs(self._showingPanel) do
		if v:name() == name then
			return v
		end
	end
end

function UIManager:forward(panelName)
	local panel = require(self._panelPath[panelName]).new()
	if type(panel.show) == "function" then
		panel:name(panelName)
		panel:show()
		self._showingPanel[#self._showingPanel + 1] = panel
		self:activeContainer(panel)
		return panel
	end
end

function UIManager:back()
	local l = #self._showingPanel
	if l > 0 then
		local panel = self._showingPanel[l]
		panel:close()
		table.remove(self._showingPanel, l)

		l = l - 1
		if l > 0 then
			self:activeContainer(self._showingPanel[l])
		else
			self:removeActiveContainer()
		end
	end
end

function UIManager:clear()
	self:removeActiveContainer()
	for i, v in ipairs(self._showingPanel) do
		-- 直接关闭，不需要动画
		v:close(nil, true)
	end
	self._showingPanel = { }
end

return UIManager