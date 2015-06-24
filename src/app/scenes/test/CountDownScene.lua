--
-- Author: Your Name
-- Date: 2015-06-24 22:03:52
--

local CountDown = require("libra.ui.components.JCountDown")

local CountDownScene = class("CountDownScene", function ()
	return display.newScene("CountDownScene")
end)

function CountDownScene:ctor()
	CountDown.new():addToContainer():pos(display.cx, display.cy):start(3, 0, 2)
		:addEventListener(COUNT_DOWN_EVENT.COMPLETED, function (event)
			event.target:removeSelf()
		end)
end

function CountDownScene:onEnter()
	sceneOnEnter(self)
end

function CountDownScene:onExit()
	sceneOnExit(self)
end

function CountDownScene:onEnterTransitionFinish()
	sceneOnEnterTransitionFinish(self)
end

return CountDownScene