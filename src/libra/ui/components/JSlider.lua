--
-- 滑动控件
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-19 21:20:06
--

local JSlider = class("JSlider", function()
    return display.newNode()
end)

-- JSlider.BAR             = "bar"
-- JSlider.BUTTON          = "button"
-- JSlider.BAR_PRESSED     = "bar_pressed"
-- JSlider.BUTTON_PRESSED  = "button_pressed"
-- JSlider.BAR_DISABLED    = "bar_disabled"
-- JSlider.BUTTON_DISABLED = "button_disabled"

-- JSlider.PRESSED_EVENT = "PRESSED_EVENT"
-- JSlider.RELEASE_EVENT = "RELEASE_EVENT"
-- JSlider.STATE_CHANGED_EVENT = "STATE_CHANGED_EVENT"
-- JSlider._valueCHANGED_EVENT = "_valueCHANGED_EVENT"

-- JSlider.BAR_ZORDER = 0     -- background bar
-- JSlider.BARFG_ZORDER = 1   -- foreground bar
-- JSlider.BUTTON_ZORDER = 2

--[[
local barImageName = "bar"
    local barfgImageName = "barfg"
    local buttonImageName = "button"
]]
JSlider.BAR_IMG = "bar"
JSlider.BAR_FG_IMG = "barfg"
JSlider.BTN_IMG = "btnImg"

--[[--

滑动控件的构建函数

图片对应的状态:

-   bar 滑动图片
-   button 背景图片


可用参数有：

-   isScale9 图片是否可缩放
-   min 最小值
-   max 最大值
-   touchInButton 是否只在触摸在滑动块上时才有效，默认为真

]]
--- 滑动控件的构建函数
-- @param number direction 滑动的方向
-- @param table images 各种状态对应的图片路径=>{JSlider.BAR_IMG = "bar", JSlider.BAR_FG_IMG = "barfg", JSlider.BTN_IMG = "btnImg"}
-- @param table param 参数表
function JSlider:ctor(direction, images, param)
	makeUIComponent(self)
    self._fsm = { }
    cc(self._fsm):addComponent("components.behavior.StateMachine"):exportMethods()
    self._fsm:setupState({
        initial = {state = "normal", event = "startup", defer = false},
        events = {
            {name = "disable", from = {"normal", "pressed"}, to = "disabled"},
            {name = "enable",  from = {"disabled"}, to = "normal"},
            {name = "press",   from = "normal",  to = "pressed"},
            {name = "release", from = "pressed", to = "normal"},
        },
        callbacks = {
            onchangestate = handler(self, self.onChangeState),
        }
    })

    param = param or { }
    self._direction = direction
    self._isHorizontal = direction == Direction.LEFT_TO_RIGHT or direction == Direction.RIGHT_TO_LEFT
    self._imageList = images
    self._isScale9 = param.isScale9
    self._scale9Size = nil
    self._min = checknumber(param.min or 0)
    self._max = checknumber(param.max or 100)
    self._value = self._min
    self._buttonPositionRange = {min = 0, max = 0}
    self._buttonPositionOffset = {x = 0, y = 0}
    self._touchInButtonOnly = true
    if type(param.touchInButton) == "boolean" then
        self._touchInButtonOnly = param.touchInButton
    end

    self._buttonRotation = 0
    self._barSprite = nil
    self._buttonSprite = nil
    self._currentBarImage = nil
    self._currentButtonImage = nil

    self:updateImage()
    self:updateButtonPosition()

    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
end

--- 设置滑动控件的大小
-- @param number width 宽度
-- @param number height 高度
-- @return JSlider#JSlider 
function JSlider:setSliderSize(width, height)
    self._scale9Size = {width, height}
    if self._barSprite then
        if self._isScale9 then
            self._barSprite:setContentSize(cc.size(self._scale9Size[1], self._scale9Size[2]))
            self:setFgBarSize(cc.size(self._scale9Size[1], self._scale9Size[2]))
        else
            self:setContentSizeAndScale_(self._barSprite, cc.size(self._scale9Size[1], self._scale9Size[2]))
            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(self._scale9Size[1], self._scale9Size[2]))
        end
    end
    return self
end

-- 设置滑动控件的是否起效
-- @param boolean enabled 有效与否
-- @return JSlider#JSlider 
function JSlider:setSliderEnabled(enabled)
    self:setTouchEnabled(enabled)
    if enabled and self._fsm:canDoEvent("enable") then
        self._fsm:doEventForce("enable")
        self:dispatchEvent({name = JSlider.STATE_CHANGED_EVENT, state = self._fsm:getState()})
    elseif not enabled and self._fsm:canDoEvent("disable") then
        self._fsm:doEventForce("disable")
        self:dispatchEvent({name = JSlider.STATE_CHANGED_EVENT, state = self._fsm:getState()})
    end
    return self
end

-- start --

--------------------------------
-- 设置滑动控件停靠位置
-- @function [parent=#JSlider] align
-- @param integer align 停靠方式
-- @param integer x X方向位置
-- @param integer y Y方向位置
-- @return JSlider#JSlider 

-- end --

function JSlider:align(align, x, y)
    display.align(self, align, x, y)
    self:updateImage()
    return self
end

-- start --

--------------------------------
-- 滑动控件是否有效
-- @function [parent=#JSlider] isButtonEnabled
-- @return boolean#boolean 

-- end --

function JSlider:isButtonEnabled()
    return self._fsm:canDoEvent("disable")
end

-- start --

--------------------------------
-- 得到滑动进度的值
-- @function [parent=#JSlider] getSliderValue
-- @return number#number 

-- end --

function JSlider:getSliderValue()
    return self._value
end

-- start --

--------------------------------
-- 设置滑动进度的值
-- @function [parent=#JSlider] setSliderValue
-- @param number value 进度值
-- @return JSlider#JSlider 

-- end --

function JSlider:setSliderValue(value)
    assert(value >= self._min and value <= self._max, "JSlider:setSliderValue() - invalid value")
    if self._value ~= value then
        self._value = value
        self:updateButtonPosition()
        self:dispatchEvent({name = JSlider._valueCHANGED_EVENT, value = self._value})
    end
    return self
end

-- start --

--------------------------------
-- 设置滑动控件的旋转度
-- @function [parent=#JSlider] setSliderButtonRotation
-- @param number rotation 旋转度
-- @return JSlider#JSlider 

-- end --

function JSlider:setSliderButtonRotation(rotation)
    self._buttonRotation = rotation
    self:updateImage()
    return self
end

function JSlider:addSliderValueChangedEventListener(callback)
    return self:addEventListener(JSlider._valueCHANGED_EVENT, callback)
end

-- start --

--------------------------------
-- 注册用户滑动监听
-- @function [parent=#JSlider] onSliderValueChanged
-- @param function callback 监听函数
-- @return JSlider#JSlider 

-- end --

function JSlider:onSliderValueChanged(callback)
    self:addSliderValueChangedEventListener(callback)
    return self
end

function JSlider:addSliderPressedEventListener(callback)
    return self:addEventListener(JSlider.PRESSED_EVENT, callback)
end

-- start --

--------------------------------
-- 注册用户按下监听
-- @function [parent=#JSlider] onSliderPressed
-- @param function callback 监听函数
-- @return JSlider#JSlider 

-- end --

function JSlider:onSliderPressed(callback)
    self:addSliderPressedEventListener(callback)
    return self
end

function JSlider:addSliderReleaseEventListener(callback)
    return self:addEventListener(JSlider.RELEASE_EVENT, callback)
end

-- start --

--------------------------------
-- 注册用户抬起或离开监听
-- @function [parent=#JSlider] onSliderRelease
-- @param function callback 监听函数
-- @return JSlider#JSlider 

-- end --

function JSlider:onSliderRelease(callback)
    self:addSliderReleaseEventListener(callback)
    return self
end

function JSlider:addSliderStateChangedEventListener(callback)
    return self:addEventListener(JSlider.STATE_CHANGED_EVENT, callback)
end

-- start --

--------------------------------
-- 注册滑动控件状态改变监听
-- @function [parent=#JSlider] onSliderStateChanged
-- @param function callback 监听函数
-- @return JSlider#JSlider 

-- end --

function JSlider:onSliderStateChanged(callback)
    self:addSliderStateChangedEventListener(callback)
    return self
end

function JSlider:onTouch(event, x, y)
    if event == "began" then
        if not self:checkTouchInButton_(x, y) then return false end
        local posx, posy = self._buttonSprite:getPosition()
        local buttonPosition = self:convertToWorldSpace(cc.p(posx, posy))
        self._buttonPositionOffset.x = buttonPosition.x - x
        self._buttonPositionOffset.y = buttonPosition.y - y
        self._fsm:doEvent("press")
        self:dispatchEvent({name = JSlider.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
        return true
    end

    local touchInTarget = self:checkTouchInButton_(x, y)
    x = x + self._buttonPositionOffset.x
    y = y + self._buttonPositionOffset.y
    local buttonPosition = self:convertToNodeSpace(cc.p(x, y))
    x = buttonPosition.x
    y = buttonPosition.y
    local offset = 0

    if self._isHorizontal then
        if x < self._buttonPositionRange.min then
            x = self._buttonPositionRange.min
        elseif x > self._buttonPositionRange.max then
            x = self._buttonPositionRange.max
        end
        if self._direction == Direction.LEFT_TO_RIGHT then
            offset = (x - self._buttonPositionRange.min) / self._buttonPositionRange.length
        else
            offset = (self._buttonPositionRange.max - x) / self._buttonPositionRange.length
        end
    else
        if y < self._buttonPositionRange.min then
            y = self._buttonPositionRange.min
        elseif y > self._buttonPositionRange.max then
            y = self._buttonPositionRange.max
        end
        if self._direction == Direction.TOP_TO_BOTTOM then
            offset = (self._buttonPositionRange.max - y) / self._buttonPositionRange.length
        else
            offset = (y - self._buttonPositionRange.min) / self._buttonPositionRange.length
        end
    end

    self:setSliderValue(offset * (self._max - self._min) + self._min)

    if event ~= "moved" and self._fsm:canDoEvent("release") then
        self._fsm:doEvent("release")
        self:dispatchEvent({name = JSlider.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget})
    end
end

function JSlider:checkTouchInButton_(x, y)
    if not self._buttonSprite then return false end
    if self._touchInButtonOnly then
        return self._buttonSprite:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    else
        return self:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    end
end

function JSlider:updateButtonPosition()
    if not self._barSprite or not self._buttonSprite then return end

    local x, y = 0, 0
    local barSize = self._barSprite:getContentSize()
    barSize.width = barSize.width * self._barSprite:getScaleX()
    barSize.height = barSize.height * self._barSprite:getScaleY()
    local buttonSize = self._buttonSprite:getContentSize()
    local offset = (self._value - self._min) / (self._max - self._min)
    local ap = self:getAnchorPoint()

    if self._isHorizontal then
        x = x - barSize.width * ap.x
        y = y + barSize.height * (0.5 - ap.y)
        self._buttonPositionRange.length = barSize.width - buttonSize.width
        self._buttonPositionRange.min = x + buttonSize.width / 2
        self._buttonPositionRange.max = self._buttonPositionRange.min + self._buttonPositionRange.length
        
        local lbPos = cc.p(0, 0)
        if self.barfgSprite_ and self._scale9Size then
            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(offset * self._buttonPositionRange.length, self._scale9Size[2]))
            lbPos = self:getbgSpriteLeftBottomPoint_()
        end
        if self._direction == Direction.LEFT_TO_RIGHT then
            x = self._buttonPositionRange.min + offset * self._buttonPositionRange.length
        else
            if self.barfgSprite_ and self._scale9Size then
                lbPos.x = lbPos.x + (1-offset)*self._buttonPositionRange.length
            end
            x = self._buttonPositionRange.min + (1 - offset) * self._buttonPositionRange.length
        end
        if self.barfgSprite_ and self._scale9Size then
            self.barfgSprite_:setPosition(lbPos)
        end
    else
        x = x - barSize.width * (0.5 - ap.x)
        y = y - barSize.height * ap.y
        self._buttonPositionRange.length = barSize.height - buttonSize.height
        self._buttonPositionRange.min = y + buttonSize.height / 2
        self._buttonPositionRange.max = self._buttonPositionRange.min + self._buttonPositionRange.length

        local lbPos = cc.p(0, 0)
        if self.barfgSprite_ and self._scale9Size then
            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(self._scale9Size[1], offset * self._buttonPositionRange.length))
            lbPos = self:getbgSpriteLeftBottomPoint_()
        end
        if self._direction == Direction.TOP_TO_BOTTOM then
            y = self._buttonPositionRange.min + (1 - offset) * self._buttonPositionRange.length
            if self.barfgSprite_ and self._scale9Size then
                lbPos.y = lbPos.y + (1-offset)*self._buttonPositionRange.length
            end
        else
            y = self._buttonPositionRange.min + offset * self._buttonPositionRange.length
            if self.barfgSprite_ then
            end
        end
        if self.barfgSprite_ and self._scale9Size then
            self.barfgSprite_:setPosition(lbPos)
        end
    end

    self._buttonSprite:setPosition(x, y)
end

function JSlider:updateImage()
    local state = self._fsm:getState()

    local barImageName = JSlider.BAR_IMG
    local barfgImageName = JSlider.BAR_FG_IMG
    local buttonImageName = JSlider.BTN_IMG

    local barImage = self._imageList[barImageName]
    local barfgImage = self._imageList[barfgImageName]
    local buttonImage = self._imageList[buttonImageName]
    if state ~= "normal" then
        barImageName = barImageName .. "_" .. state
        buttonImageName = buttonImageName .. "_" .. state
    end

    if self._imageList[barImageName] then
        barImage = self._imageList[barImageName]
    end
    if self._imageList[buttonImageName] then
        buttonImage = self._imageList[buttonImageName]
    end

    if barImage then
        if self._currentBarImage ~= barImage then
            if self._barSprite then
                self._barSprite:removeFromParent(true)
                self._barSprite = nil
            end

            if self._isScale9 then
                self._barSprite = display.newScale9Sprite(barImage)
                if not self._scale9Size then
                    local size = self._barSprite:getContentSize()
                    self._scale9Size = {size.width, size.height}
                else
                    self._barSprite:setContentSize(cc.size(self._scale9Size[1], self._scale9Size[2]))
                end
            else
                self._barSprite = display.newSprite(barImage)
                if self._scale9Size then
                    self:setContentSizeAndScale_(self._barSprite, cc.size(self._scale9Size[1], self._scale9Size[2]))
                end
            end
            self:addChild(self._barSprite, JSlider.BAR_ZORDER)
        end

        self._barSprite:setAnchorPoint(self:getAnchorPoint())
        self._barSprite:setPosition(0, 0)
    else
        printError("JSlider:updateImage() - not set bar image for state %s", state)
    end

    if barfgImage then
        if not self.barfgSprite_ then
            if self._isScale9 then
                self.barfgSprite_ = display.newScale9Sprite(barfgImage)
                self.barfgSprite_:setContentSize(cc.size(self._scale9Size[1], self._scale9Size[2]))
            else
                self.barfgSprite_ = display.newSprite(barfgImage)
            end

            self:addChild(self.barfgSprite_, JSlider.BARFG_ZORDER)
            self.barfgSprite_:setAnchorPoint(cc.p(0, 0))
            self.barfgSprite_:setPosition(self._barSprite:getPosition())
        end
    end

    if buttonImage then
        if self._currentButtonImage ~= buttonImage then
            if self._buttonSprite then
                self._buttonSprite:removeFromParent(true)
                self._buttonSprite = nil
            end
            self._buttonSprite = display.newSprite(buttonImage)
            self:addChild(self._buttonSprite, JSlider.BUTTON_ZORDER)
        end

        self._buttonSprite:setPosition(0, 0)
        self._buttonSprite:setRotation(self._buttonRotation)
        self:updateButtonPosition()
    else
        printError("JSlider:updateImage() - not set button image for state %s", state)
    end
end

function JSlider:onChangeState(event)
    if self:isRunning() then
        self:updateImage()
    end
end

function JSlider:setFgBarSize(size)
    if not self.barfgSprite_ then
        return
    end
    self.barfgSprite_:setContentSize(size)
end

function JSlider:getbgSpriteLeftBottomPoint_()
    if not self._barSprite then
        return cc.p(0, 0)
    end

    local posX, posY = self._barSprite:getPosition()
    local size = self._barSprite:getBoundingBox()
    local ap = self._barSprite:getAnchorPoint()
    posX = posX - size.width*ap.x
    posY = posY - size.height*ap.y

    local point = cc.p(posX, posY)
    return point
end

function JSlider:setContentSizeAndScale_(node, s)
    if not node then
        return
    end

    local size = node:getContentSize()
    local scaleX
    local scaleY
    scaleX = s.width/size.width
    scaleY = s.height/size.height
    node:setScaleX(scaleX)
    node:setScaleY(scaleY)
end


return JSlider
