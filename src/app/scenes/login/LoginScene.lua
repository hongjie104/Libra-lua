--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-20 10:23:31
--

local LoginScene = class("LoginScene", function ()
	return display.newScene("LoginScene")
end)

function LoginScene:ctor()
	display.newSprite("ui/login_bg.jpg", display.cx, display.cy):addTo(self)
end

function LoginScene:onEnter()
	sceneOnEnter(self)
end

function LoginScene:onEnterTransitionFinish()
	-- body
end

function LoginScene:onExit()
	sceneOnExit(self)
end

function LoginScene:onExitTransitionStart()
	-- body
end

return LoginScene