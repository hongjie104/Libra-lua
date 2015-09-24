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

	self.NULL = "nil"
end

function UIManager:getUIContainer()
	return self._uiContainer
end

function UIManager:activeContainer(val)
	if val then
		if self._activeContainer ~= val then
			self:removeActiveContainer()
			self._activeContainer = val
			if type(self._activeContainer) == "userdata" and type(self._activeContainer.isContainer) == "function" and self._activeContainer:isContainer() then
				self._activeContainer:initFocusComponent()
				self._activeContainer:addEventListener(KEY_EVENT.BACK_RELEASED, handler(self, self.onBackHandler))
			end
		end
		return self
	end
	return self._activeContainer
end

function UIManager:removeActiveContainer()
	if self._activeContainer then
		if type(self._activeContainer) == "userdata" and type(self._activeContainer.isContainer) == "function" and self._activeContainer:isContainer() then
			self._activeContainer:uninitFocusComponent()
			self._activeContainer:removeEventListenersByEvent(KEY_EVENT.BACK_RELEASED)
			self._activeContainer = nil
		end
	end
end

function UIManager:resetActiveContainer()
	local l = #self._showingPanel
	for i = l, 1, -1 do
		if self._showingPanel[i] ~= self._activeContainer then
			self:activeContainer(self._showingPanel[i])
			break
		end
	end
end

--- 处理一下返回键的逻辑
-- 如果激活面板中需要用到返回键，那就执行，否则就弹出退出游戏的窗口
function UIManager:onBackHandler()
	if self._activeContainer and self._activeContainer ~= self.NULL then
		if not self._activeContainer:doBackHandler() then
			-- todo
			-- 弹出退出游戏的窗口
			logger:info("弹出退出游戏的窗口")
		end
	end
end

-- @private
function UIManager:onKeyPadEvent(event)
	if self._activeContainer and self._activeContainer ~= self.NULL then
		if event.name == "Pressed" then
			if self._activeContainer.onKeyPressed and type(self._activeContainer.onKeyPressed) == "function" then
				self._activeContainer:onKeyPressed(event.code)
			else
				logger:error(self._activeContainer.class.__cname, "没有onKeyPressed方法")
			end
		elseif event.name == "Released" then
			if self._activeContainer.onKeyReleased and type(self._activeContainer.onKeyReleased) == "function" then
				self._activeContainer:onKeyReleased(event.code)
			else
				logger:error(self._activeContainer.class.__cname, "没有onKeyReleased方法")
			end
		end
	else
		logger:warn("UIManager中的self._activeContainer可能是nil")
	end
end

function UIManager:getContainer(name)
	for i, v in ipairs(self._showingPanel) do
		if v:name() == name then
			return v
		end
	end
end

function UIManager:forward(panelName, param)
	local panel = require(self._panelPath[panelName]).new(param)
	if type(panel.show) == "function" then
		panel:name(panelName)
		panel:show()
		self._showingPanel[#self._showingPanel + 1] = panel
		if #self._showingPanel > 1 then
			self:activeContainer():doForwardToNextHandler(param)
		end
		-- self:setTVControllerVisiable(false)
		self:activeContainer(panel)
		return panel
	else
		logger:error(panel.class.__cname, "没有show方法")
	end
end

function UIManager:back(param)
	local l = #self._showingPanel
	if l > 0 then
		--by zxf
		-- self:setTVControllerVisiable(false)
		self:removeActiveContainer()
		
		local panel = self._showingPanel[l]
		-- panel:close()
		panel:removeFromParent(true)
		table.remove(self._showingPanel, l)

		l = l - 1
		if l > 0 then
			self:activeContainer(self._showingPanel[l])
			self:activeContainer():doBackToCurHandler(param)
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

-- function UIManager:removePanel(panel)
-- 	for i, v in ipairs(self._showingPanel) do
-- 		if v == panel then
-- 			table.remove(self._showingPanel, i)
-- 			break
-- 		end
-- 	end
-- end

-- function UIManager:createTVController(callback)
-- 	if not self._okArmature then
-- 		ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync('ui/animation/ok/Hywx_Ui_Ok.ExportJson', function ()
-- 			self._okArmature = ccs.Armature:create("Hywx_Ui_Ok")
-- 			self._okArmature:getAnimation():play("Animation2")
-- 			self._enableTVController = true
-- 			self._okArmature:setVisible(false)
-- 			if callback and "function" == type(callback) then
-- 				callback()
-- 			end
-- 		end, false)
-- 	end
-- end

-- function UIManager:clearTVController()
-- 	if self._okArmature then
-- 		self._okArmature:getAnimation():stop()
-- 		self._okArmature:removeSelf()
-- 		self._okArmature = nil
-- 		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo('ui/animation/ok/Hywx_Ui_Ok.ExportJson')
-- 	end
-- end

-- function UIManager:getTVController()
-- 	if self._okArmature then
-- 		return self._okArmature
-- 	end
-- end

-- function UIManager:setTVControllerVisiable(val)
-- 	if self._okArmature and type(val) == "boolean" then
-- 		self._okArmature:setVisible(val)
-- 	end
-- end

-- function UIManager:enableTVController(val)
-- 	if type(val) == "boolean" then
-- 		self._enableTVController = val
-- 		if self._okArmature then
-- 			if not val then	
-- 				self._okArmature:setVisible(val)
-- 			end
-- 		end
-- 		return self
-- 	end
-- 	return self._enableTVController
-- end

-- function UIManager:moveTVController(x, y)
-- 	if self._okArmature and self._enableTVController and self:activeContainer():getComponentCount() > 0 then
-- 		if self:activeContainer():getComponentCount() > 0 then	
-- 			transition.stopTarget(self._okArmature)
-- 			transition.moveTo(self._okArmature, {time = 0.1, x = x, y = y, onComplete = function()
-- 				self._okArmature:setVisible(true)
-- 			end})
-- 		end
-- 	end
-- end

-- function UIManager:playOKAnimation(name)
-- 	if self._okArmature then
-- 		self._okArmature:getAnimation():play(name)
-- 	end
-- end

return UIManager