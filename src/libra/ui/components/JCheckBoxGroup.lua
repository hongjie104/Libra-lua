--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 13:29:58
--

local JCheckBoxGroup = class("JCheckBoxGroup", require("libra.ui.components.JContainer"))

-- @param isHorizontal 是不是水平排列,默认是水平的
function JCheckBoxGroup:ctor(isHorizontal, gap)
	JCheckBoxGroup.super.ctor(self)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	self._checkBoxList = { }
	self._selectedCheckBox = nil
end

function JCheckBoxGroup:selectedCheckBox(val)
	if val then
		self._selectedCheckBox = val
		local index = -1
		for i, v in ipairs(self._checkBoxList) do
			if v == self._selectedCheckBox then
				v:selected(true, false, true)
				index = i
			else
				v:selected(false, false, true)
			end
		end
		self:dispatchEvent({name = CHECKBOX_GROUP_EVENT.SELECTED, index = index})
		return self
	end
	return self._selectedCheckBox
end

function JCheckBoxGroup:addUIComponent(component, zOrder)
	if type(component.selected) == "function" and type(component.group) == "function" then
		if not table.indexof(self._checkBoxList, component) then
			if not self._selectedCheckBox then
				self._selectedCheckBox = component
			end
			self._checkBoxList[#self._checkBoxList + 1] = component
			component:selected(false, false)
			component:group(self)
		end
	end
	if self._selectedCheckBox then
		self._selectedCheckBox:selected(true, false)
	end
	JCheckBoxGroup.super.addUIComponent(self, component, zOrder)
	return self
end

return JCheckBoxGroup