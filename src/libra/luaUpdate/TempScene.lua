--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-16 16:07:24
--

local Label = require("libra.ui.components.JLabel")

local TempScene = class("TempScene", function ()
	return display.newScene("TempScene")
end)

function TempScene:ctor(scenePath)
	self._scenePath = scenePath
	Label.new({text = "Hello World!", size = 64}):addTo(self):align(display.CENTER, display.cx, display.cy)
end

function TempScene:onEnterTransitionFinish()
	display.replaceScene(require(self._scenePath).new())
end

return TempScene
