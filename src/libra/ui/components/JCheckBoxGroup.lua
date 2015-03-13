--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 13:29:58
--

local JCheckBoxGroup = class("JCheckBoxGroup", require("libra.ui.components.JContainer"))

-- @param isHorizontal 是不是水平排列,默认是水平的
function JCheckBoxGroup:ctor(isHorizontal, gap)
	JCheckBoxGroup.super.ctor(self)

	self._checkBoxList = {}
	self:setLayout(require("libra.ui.layout.BoxLayout").new(self._checkBoxList, isHorizontal, gap))

	self._selectedCheckBox = nil
end

function JCheckBoxGroup:selectedCheckBox(val)
	if val then
		self._selectedCheckBox = val
		for _, v in ipairs(self._checkBoxList) do
			v:selected(v == self._selectedCheckBox, false)
		end
		return self
	end
	return self._selectedCheckBox
end

function JCheckBoxGroup:addCheckBox(...)
	for _, v in pairs({...}) do
		if not table.indexof(self._checkBoxList, v) then
			if not self._selectedCheckBox then
				self._selectedCheckBox = v
			end
			self._checkBoxList[#self._checkBoxList + 1] = v
			self:addComponent(v)
			v:selected(false, false)
			v:group(self)
		end
	end
	self._selectedCheckBox:selected(true, false)
	return self
end

return JCheckBoxGroup