--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-16 16:07:24
--

local TempScene = class("TempScene", function ()
	return display.newScene("TempScene")
end)

function TempScene:ctor(scenePath)
	self._scenePath = scenePath
end

function TempScene:onEnterTransitionFinish()
	display.replaceScene(require(self._scenePath).new())
end

return TempScene
