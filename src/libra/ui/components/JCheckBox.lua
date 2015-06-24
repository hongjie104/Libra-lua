--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 11:14:10
--

local Label = require("libra.ui.components.JLabel")

local JCheckBox = class("JCheckBox", function (param)
	assert(param.selected, "JCheckBox:class() - invalid param:param.selected is nil")
	return display.newSprite(param.bg or param.selected)
end)

-- @param param {bg = "背景图", selected = "选中的图片", unselected = "未选中的图片", label = {font = "FONT", text = "text", size = 24}}
-- @param isSelected 初始状态是否是选中的，默认为不选中
function JCheckBox:ctor(param, isSelected)
	self._param = param
	isSelected = isSelected or false
	makeUIComponent(self)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	if not param.bg then
		self._selectedIcon = self
	end
	if isSelected then
		self:createSelectedIcon(param.selected)
	else
		if self._param.unselected then
			self:createSelectedIcon(param.unselected)
		else
			self:createSelectedIcon(param.selected)
			self._selectedIcon:hide()
		end
	end
	self._selected = not isSelected
	self:selected(isSelected, false)

	if self._param.label then
		self._label = Label.new(self._param.label):addTo(self):align(display.CENTER, self._actualWidth / 2, self._actualHeight / 2)
	end

	self:enabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))
end

function JCheckBox:group(val)
	if val then
		self._group = val
		return self
	end
	return self._group
end

function JCheckBox:enabled(bool)
	if type(bool) == "boolean" then
		if self._enabled ~= bool then
			self._enabled = bool
		end
		if self._param.unabled then
			self:setTexture(self._enabled and self._param.bg or self._param.unabled)
		end
		self:setTouchEnabled(self._enabled)
		return self
	end
	return self._enabled
end

function JCheckBox:selected(bool, callback, passive)
	if type(bool) == "boolean" then
		if self._selected ~= bool then
			if not self._group or not self._selected or passive then
				self._selected = bool
				if callback == nil then
					callback = true
				end
				if self._selected then
					if self._group then
						if callback then
							self._group:selectedCheckBox(self)
						end						
					end
					self._selectedIcon:setTexture(self._param.selected)
					self._selectedIcon:show()
				else
					if self._param.unselected then
						self._selectedIcon:setTexture(self._param.unselected)
					else
						self._selectedIcon:hide()
					end
				end
				if callback then
					self:dispatchEvent({name = CHECKBOX_EVENT.CHANGED})
				end
			end
		end
		return self
	end
	return self._selected
end

function JCheckBox:alignSelectedIcon(align, x, y)
	self._selectedIcon:align(align, x, y)
	return self
end

function JCheckBox:alignLabel(align, x, y)
	if self._label then
		self._label:alignLabel(align, x, y)
	end
	return self
end

-- @private
-- @param image 图片名
function JCheckBox:createSelectedIcon(image)
	if not self._selectedIcon then
		self._selectedIcon = display.newSprite(image):addTo(self)
	end
end

function JCheckBox:onTouch(evt)
	if evt.name == "began" then
		return true
	elseif evt.name == "ended" then
		if self:isPointIn(evt.x, evt.y) then
			self:selected(not self:selected())
		end
	end
end

return JCheckBox
