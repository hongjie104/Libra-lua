
local Button = require("libra.ui.components.JButton")

local ButtonScene = class("ButtonScene", function()
	return display.newScene("ButtonScene")
end)

function ButtonScene:ctor()

	local test = {
					{id = "_testBtn", ui = "libra.ui.components.JButton", param = {normal = "ui/ty_anniu02.png", label = {text = "123", size = 24}}, x = display.cx, y = display.cy},
					{id = "_testBtn1", ui = "libra.ui.components.JButton", param = {normal = "ui/ty_anniu02.png", label = {text = "hello world", size = 24}}, x = display.cx, y = display.cy + 50}
				}
	libraUIManager:getUIContainer():createUI(test)

	libraUIManager:getUIContainer():getUIComponent("_testBtn"):addEventListener(BUTTON_EVENT.CLICKED, function (event)
		print(string.format("%s clicked", event.target:name()))
	end)
	libraUIManager:getUIContainer():getUIComponent("_testBtn1"):addEventListener(BUTTON_EVENT.CLICKED, function (event)
		print(string.format("%s clicked", event.target:name()))
	end)

	Button.new({normal = "ui/ty_anniu02.png", label = {text = "ttt", size = 24}}):addToContainer():pos(display.cx, display.cy + 100)
		:addEventListener(BUTTON_EVENT.CLICKED, function (event)
			print(string.format("%s clicked", event.target:name()))
		end)
end

function ButtonScene:onEnter()
	sceneOnEnter(self)
end

function ButtonScene:onExit()
	sceneOnExit(self)
end

function ButtonScene:onEnterTransitionFinish()
	sceneOnEnterTransitionFinish(self)
end

return ButtonScene
