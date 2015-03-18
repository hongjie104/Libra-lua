
local Label = require("libra.ui.components.JLabel")
local Button = require("libra.ui.components.JButton")
local CheckBox = require("libra.ui.components.JCheckBox")
local CheckBoxGroup = require("libra.ui.components.JCheckBoxGroup")
local Panel = require("libra.ui.components.JPanel")
local CountDown = require("libra.ui.components.JCountDown")
local JAlert = require("libra.ui.components.JAlert")
local TableView = require("libra.ui.components.JTableView")

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

    TableView.new(cc.size(100, 100)):addToContainer():pos(display.cx, display.cy)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
