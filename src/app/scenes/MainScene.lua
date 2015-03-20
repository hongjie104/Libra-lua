
local Label = require("libra.ui.components.JLabel")
local Button = require("libra.ui.components.JButton")
local CheckBox = require("libra.ui.components.JCheckBox")
local CheckBoxGroup = require("libra.ui.components.JCheckBoxGroup")
local Panel = require("libra.ui.components.JPanel")
local CountDown = require("libra.ui.components.JCountDown")
local JAlert = require("libra.ui.components.JAlert")
-- local TableView = require("libra.ui.components.JTableView")
local JScrollView = require("libra.ui.components.JScrollView")
local JListView = require("libra.ui.components.JListView")
local JImage = require("libra.ui.components.JImage")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()

    -- local test = {
    --                 {id = "_testBtn", ui = "libra.ui.components.JButton", param = {normal = "btnRed2_normal.png", down1 = "btnRed2_down.png", label = {text = "hello world", size = 24}}, x = display.cx, y = display.cy},
    --                 {id = "_testBtn1", ui = "libra.ui.components.JButton", param = {normal = "btnRed2_normal.png", down1 = "btnRed2_down.png", label = {text = "hello world", size = 24}}, x = display.cx, y = display.cy + 50}
    --             }
    -- libraUIManager:getUIContainer():createUI(test)
    
    --[[
    local node = JImage.new("COVER.jpg"):align(display.CENTER, 400, 400)
    local rect = node:getBoundingBox()
    rect.width, rect.height = 400, 400
    self._scrollView = JScrollView.new({viewRect = rect})
        :addScrollNode(node):addToContainer():onScrollListener(function (evt)
            -- dump(evt)
        end)
    --]]

    -- JListView.new({viewRect = {x = 0, y = 0, width = 200, height = 200}}):addToContainer()

    ----[[
    self._listDataList = {}
    for i = 1, 50 do
        self._listDataList[i] = i
    end

    self.lv = JListView.new({
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        -- bgScale9 = true,
        -- async = true,
        -- viewRect = cc.rect(360, 40, 400, 80),
        viewRect = cc.rect(360, 40, 120, 40),
        -- direction = Direction.HORIZONTAL,
        -- scrollbarImgV = "barH.png"
        }):onTouchListener(handler(self, self.touchListener8))
        :addTo(self)

    self.lv:setDelegate(handler(self, self.sourceDelegate))

    self.lv:reload()

    Button.new({normal = "btnRed2_normal.png", down = "btnRed2_down.png"}, function ()
        table.remove(self._listDataList, 3)
        self.lv:reload(false)
    end):align(display.CENTER, display.cx + 200, display.cy):addTo(self)
    --]]
end

----[[
function MainScene:touchListener8(event)
    local listView = event.listView
    if "clicked" == event.name then
        print("async list view clicked idx:" .. event.itemPos)
    end
end

function MainScene:sourceDelegate(listView, tag, idx)
    -- print(string.format("TestUIListViewScene tag:%s, idx:%s", tostring(tag), tostring(idx)))
    if TAG.COUNT_TAG == tag then
        return #self._listDataList
    elseif TAG.CELL_TAG == tag then
        local item = self.lv:dequeueItem()
        local content
        if not item then
            content = cc.ui.UILabel.new(
                    {text = "item" .. idx,
                    size = 20,
                    align = cc.ui.TEXT_ALIGN_CENTER,
                    color = display.COLOR_WHITE})
            item = self.lv:newItem(content)
        else
            content = item:getContent()
        end
        content:setString("item:" .. self._listDataList[idx])
        item:actualWidth(120):actualHeight(30)
        return item
    else
    end
end
--]]

function MainScene:onEnter()
    sceneOnEnter(self)
end

function MainScene:onExit()
    sceneOnExit(self)
end

return MainScene
