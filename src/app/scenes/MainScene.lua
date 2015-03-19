
local Label = require("libra.ui.components.JLabel")
local Button = require("libra.ui.components.JButton")
local CheckBox = require("libra.ui.components.JCheckBox")
local CheckBoxGroup = require("libra.ui.components.JCheckBoxGroup")
local Panel = require("libra.ui.components.JPanel")
local CountDown = require("libra.ui.components.JCountDown")
local JAlert = require("libra.ui.components.JAlert")
-- local TableView = require("libra.ui.components.JTableView")
local JScrollView = require("libra.ui.components.JScrollView")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    libraUIManager:getUIContainer():addTo(self)
    if LUA_UI_EDITOR then
        import("libra.uiEditor.UIEditorContainer").new():addToContainer()
    end

    local test = {
                    {id = "_testBtn", ui = "libra.ui.components.JButton", param = {normal = "btnRed2_normal.png", down1 = "btnRed2_down.png", label = {text = "hello world", size = 24}}, x = display.cx, y = display.cy},
                    {id = "_testBtn1", ui = "libra.ui.components.JButton", param = {normal = "btnRed2_normal.png", down1 = "btnRed2_down.png", label = {text = "hello world", size = 24}}, x = display.cx, y = display.cy + 50}
                }
    -- libraUIManager:getUIContainer():createUI(test)
    
    ----[[
    local node = display.newSprite("COVER.jpg")--:align(display.CENTER, display.cx, display.cy)
    local rect = node:getBoundingBox()
    rect.width, rect.height = 200, 800
    self._scrollView = JScrollView.new({viewRect = rect})
        :align(display.CENTER, display.cx, display.cy)
        :addScrollNode(node):addToContainer():onScroll(function (evt)
            dump(evt)
        end)
    --]]
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
