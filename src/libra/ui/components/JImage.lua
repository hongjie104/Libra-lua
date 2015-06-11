--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-12 22:46:39
--

local JImage = class("JImage", function(filename, param)
    if param and param.size then
        return display.newScale9Sprite(filename, param.x, param.y, param.size, param.capInsets)
    else
        return display.newSprite(filename)
    end
end)

function JImage:ctor(filename, param)
	makeUIComponent(self)
end

return JImage