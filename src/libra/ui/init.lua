--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-12 20:42:49
--

local function actualWidth(self, int)
	if int then
		if self._actualWidth ~= int then
			self._actualWidth = int
			self:setContentSize(self._actualWidth, self._actualHeight)
		end
		return self
	end
	return self._actualWidth
end

local function actualHeight(self, int)
	if int then
		if self._actualHeight ~= int then
			self._actualHeight = int
			self:setContentSize(self._actualWidth, self._actualHeight)
		end
		return self
	end
	return self._actualHeight
end

local function name(self, str)
	if str then
		self._name = str
		return self
	end
	return self._name
end

local function addToContainer(self, container, zOrder)
	local container = container or uiManager:getUIContainer()
	assert(type(container.isContainer) == "function" and container:isContainer(), "libra.ui.init.addToContainer() - invalid container")
	if container ~= self then
		container:addUIComponent(self, zOrder)
	end
	return self
end

local function removeSelf(self)
	local container = self:getParent()
	if type(container.isContainer) == "function" and container:isContainer() then
		container:removeUIComponent(self)
	else
		-- uiManager:removePanel(self)
		self:removeFromParent(true)
	end
	return self
end

--- 获得焦点
local function gainFocus(self)
	if not self._border then
		if self.doGainFocus and type(self.doGainFocus) == "function" then
			self._border = self:doGainFocus(x, y)	
		else 
			local border = display.newScale9Sprite("ui/border.png", self:actualWidth() / 2, self:actualHeight() / 2, cc.size(self:actualWidth(), self:actualHeight()))
			border:addTo(self)
			self._border = border
		end
	end

	--local rect = self:convertToWorldSpace(cc.p(self:x(), self:y()))
	-- uiManager:moveTVController(self:x(), self:y())
end

--- 失去焦点
local function lostFocus(self)
	if self.doLostFocus and type(self.doLostFocus) == "function" then
		self:doLostFocus()
	else
		if self._border then
			self._border:removeSelf()
		end
		self._border = nil
	end
end

local function leftComponent(self, component)
	if component then
		if component._isuiComponent then
			self._leftComponent = component
			component._rightComponent = self
		else
			logger:error(component:name(), "is not Libra UI Component")
		end
	else
		return self._leftComponent
	end
end

local function rightComponent(self, component)
	if component then
		if component._isuiComponent then
			self._rightComponent = component
			component._leftComponent = self
		else
			logger:error(component:name(), "is not Libra UI Component")
		end
	else
		return self._rightComponent
	end
end

local function topComponent(self, component)
	if component then
		if component._isuiComponent then
			self._topComponent = component
			component._bottomComponent = self
		else
			logger:error(component:name(), "is not Libra UI Component")
		end
	else
		return self._topComponent
	end
end

local function bottomComponent(self, component)
	if component then
		if component._isuiComponent then
			self._bottomComponent = component
			component._topComponent = self
		else
			logger:error(component:name(), "is not Libra UI Component")
		end
	else
		return self._bottomComponent
	end
end

function makeUIComponent(component)
	component._isuiComponent = true

	component:setCascadeOpacityEnabled(true)
	component:setCascadeColorEnabled(true)

	component._actualWidth, component._actualHeight = 0, 0
	component.actualWidth = actualWidth
	component.actualHeight = actualHeight

	local size = component:getContentSize()
	component:actualWidth(size.width)
	component:actualHeight(size.height)

	component._name = component.class.__cname
	component.name = name
	
	component.addToContainer = addToContainer
	component.removeSelf = removeSelf

	-- 焦点相关
	component.gainFocus = gainFocus
	component.lostFocus = lostFocus
	component.leftComponent = leftComponent
	component.rightComponent = rightComponent
	component.topComponent = topComponent
	component.bottomComponent = bottomComponent
end

import(".event")
import(".uiConstants")

UI_CONFIG = UI_CONFIG or { }

uiManager = require(UI_MANAGER_PATH or "libra.ui.managers.UIManager").new()
-- focusManager = require("libra.ui.managers.FocusManager").new()