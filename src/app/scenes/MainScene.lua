
local Label = require("libra.ui.JLabel")
local Button = require("libra.ui.JButton")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- Label.new({text = "Hello, World", size = 64}):addTo(self):align(display.CENTER, display.cx, display.cy)
    
    Button.new({normal = "btnRed2_normal.png", down1 = "btnRed2_down.png", label = {text = "Hello, World", size = 24}},
    -- Button.new({normal = "imgIcoBg30.png", scale9 = cc.size(60, 60), label = {text = "Hello, World", size = 24}},
    	{onTouchBegan = function (evt)
    		print("began")
    	end, onTouchMoved = function ()
    		print("moved")
    	end, onTouchEnded = function ()
    		print("ended")
        end}):addTo(self):align(display.CENTER, display.cx, display.cy)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
