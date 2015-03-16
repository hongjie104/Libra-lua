
local Label = require("libra.ui.components.JLabel")
local Button = require("libra.ui.components.JButton")
local CheckBox = require("libra.ui.components.JCheckBox")
local CheckBoxGroup = require("libra.ui.components.JCheckBoxGroup")
local Panel = require("libra.ui.components.JPanel")
local CountDown = require("libra.ui.components.JCountDown")
local JAlert = require("libra.ui.components.JAlert")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    libraUIManager:getUIContainer():addTo(self)

    -- Label.new({text = "Hello, World", size = 64}):addToContainer():align(display.CENTER, display.cx, display.cy)
    
    -- local socketHandler = SocketHandler
    Button.new({normal = "btnRed2_normal.png", down1 = "btnRed2_down.png", 
        label = {text = "hello world!", size = 24}},
    -- Button.new({normal = "imgIcoBg30.png", scale9 = cc.size(60, 60), label = {text = "Hello, World", size = 24}},
    	{onTouchBegan = function (evt)
    		-- print("began")
    	end, onTouchEnded = function ()
            -- if self._countDown:isRunning() then
            --     self._countDown:pause()
            -- else
            --     self._countDown:resume()
            -- end
            print("Button ended")
        end}):addToContainer():align(display.CENTER, display.width, display.cy)

	-- logger:debug("fsdfdsfsd")

    -- local box1 = CheckBox.new({bg = "btnRed2_normal.png", selected = "btnHelp_d.png", unselected = "btnHelp_n.png", label = {text = "111", size = 24}})
    --     :alignSelectedIcon(display.LEFT_BOTTOM)
    -- local box2 = CheckBox.new({bg = "btnRed2_normal.png", selected = "btnHelp_d.png", unselected = "btnHelp_n.png", label = {text = "222", size = 24}})
    --     :alignSelectedIcon(display.LEFT_BOTTOM)

    -- local checkBoxGroup = CheckBoxGroup.new(function (selectedIndex)
    --     print(selectedIndex)
    -- end):addToContainer():addCheckBox(box1, box2):align(display.CENTER, display.cx, display.cy)
    -- checkBoxGroup:setSize(200, 200)
    -- checkBoxGroup:updateLayout()

    -- Panel.new({bg = "imgIcoBg30.png", isScale9 = true}):setSize(200, 200):align(display.CENTER, display.cx, display.cy):show()

    JAlert.new({bg = "imgIcoBg30.png", isScale9 = true}):setSize(300, 200):align(display.CENTER, display.cx, display.cy):show(true, true, function (isOK)
        print(isOK)
    end)

    -- self._countDown = CountDown.new({text = "Hello, World", size = 24}, function ()
    --     print("11111111111")
    -- end):addToContainer():align(display.CENTER, display.cx, display.cy - 50)
    -- self._countDown:start(4, 0)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
