
local CheckBox = require("libra.ui.components.JCheckBox")
local CheckBoxGroup = require("libra.ui.components.JCheckBoxGroup")

local CheckBoxScene = class("CheckBoxScene", function()
	return display.newScene("CheckBoxScene")
end)

function CheckBoxScene:ctor()
	CheckBox.new({selected = "ui/lt002_1.png", unselected = "ui/lt002_2.png", label = {text = "checkBox"}}):addToContainer():pos(display.cx, display.cy)
		:addEventListener(CHECKBOX_EVENT.CHANGED, function (event)
			print(event.target:selected())
		end)

	CheckBoxGroup.new(true, 10):addToContainer()
		:addUIComponent(CheckBox.new({selected = "ui/lt002_1.png", unselected = "ui/lt002_2.png", label = {text = "checkBox1"}}):pos(100, display.cy - 50))
		:addUIComponent(CheckBox.new({selected = "ui/lt002_1.png", unselected = "ui/lt002_2.png", label = {text = "checkBox2"}}):pos(250, display.cy - 50))
		:addUIComponent(CheckBox.new({selected = "ui/lt002_1.png", unselected = "ui/lt002_2.png", label = {text = "checkBox3"}}):pos(400, display.cy - 50))
		:addEventListener(CHECKBOX_GROUP_EVENT.SELECTED, function (event)
			print(event.index)
		end)
end

function CheckBoxScene:onEnter()
	sceneOnEnter(self)
end

function CheckBoxScene:onExit()
	sceneOnExit(self)
end

function CheckBoxScene:onEnterTransitionFinish()
	sceneOnEnterTransitionFinish(self)
end

return CheckBoxScene
