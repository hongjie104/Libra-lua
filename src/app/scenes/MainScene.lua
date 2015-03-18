
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
    -- Button.new({normal = "btnRed2_normal.png", down1 = "btnRed2_down.png", 
    --     label = {text = "hello world!", size = 24}},
    -- -- Button.new({normal = "imgIcoBg30.png", scale9 = cc.size(60, 60), label = {text = "Hello, World", size = 24}},
    --     function ()
    --         print("button is clicked")
    --         -- if self._countDown:isRunning() then
    --         --     self._countDown:pause()
    --         -- else
    --         --     self._countDown:resume()
    --         -- end
    --     end):addToContainer():align(display.CENTER, display.width, display.cy)

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

    -- local alert = JAlert.new({bg = "imgIcoBg30.png", isScale9 = true}):setSize(300, 200):align(display.LEFT_TOP, display.cx, display.cy):show(true, true, function (isOK)
    --     print(isOK)
    -- end)

    -- self._countDown = CountDown.new({text = "Hello, World", size = 24}, function ()
    --     print("11111111111")
    -- end):addToContainer():align(display.CENTER, display.cx, display.cy - 50)
    -- self._countDown:start(4, 0)

    -- local s = display.newSprite("imgIcoBg30.png"):addTo(self)--:pos(display.cx, display.cy)
    -- s:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
    -- display.newCircle(3, {x = 0, y = 0, fillColor = cc.c4f(1, 0, 0, 1)}):addTo(s)
    -- s:setRotation(45)

    local test = {id = "_testBtn", ui = "libra.ui.components.JButton", param = {normal = "btnRed2_normal.png", down1 = "btnRed2_down.png", 
        label = {text = "hello world!", size = 24}}, x = display.cx, y = display.cy, alignLabel = {display.LEFT_TOP}}
    self[test.id] = require(test.ui).new(test.param):addToContainer()--:pos(test.x, test.y)
    for k,v in pairs(test) do
        if k ~= "id" and k~= ui and k ~= param then
            if type(self[test.id][k]) == "function" then
                if type(v) == "table" then
                    if #v == 1 then
                        self[test.id][k](self[test.id], v[1])
                    elseif #v == 2 then
                        self[test.id][k](self[test.id], v[1], v[2])
                    elseif #v == 3 then
                        self[test.id][k](self[test.id], v[1], v[2], v[3])
                    elseif #v == 4 then
                        self[test.id][k](self[test.id], v[1], v[2], v[3], v[4])
                    elseif #v == 5 then
                        self[test.id][k](self[test.id], v[1], v[2], v[3], v[4], v[5])
                    end
                else
                    self[test.id][k](self[test.id], v)
                end
            end
        end
    end
    -- self[test.id]["alignLabel"](self[test.id], display.LEFT_TOP)
    self._testBtn:onClicked(function ()
        print("aaa")
    end)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
