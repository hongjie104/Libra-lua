--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-12 21:01:09
--

local function createScale9Sprite(img, size, capInsets)
	local s = display.newScale9Sprite(img, 0, 0, size, capInsets):align(display.CENTER, -size.width / 2, -size.height / 2)
	s:ignoreAnchorPointForPosition(true)
	return s
end

local Label = require("libra.ui.components.JLabel")

local JButton = class("JButton", function (param)
	--assert(param.normal, "JButton:class() - invalid param:param.normal is nil")
	if param.size then
		return display.newNode()
	else
		return display.newSprite(param.normal)
	end
end)

--- 构造函数
-- @param param {normmal = "按钮正常状态时图片", down = "按钮按下状态图片", unabled = "按钮不可用状态图片",  label = {text = "按钮文字", size = 24}}
-- size = ccsize 如果有值,说明是九宫图, capInsets = CCRect, labelImg = "图片名",labelImgX = 图片横坐标, labelImgY = 图片纵坐标
function JButton:ctor(param)
	self._param = param
	makeUIComponent(self)
	self:setNodeEventEnabled(true)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	--zxf
	if param.size then
		self:actualWidth(param.size.width)
		self:actualHeight(param.size.height)
	elseif param.size and param.normal then
		self._scale9Sprite = createScale9Sprite(param.normal, param.size, param.capInsets):addTo(self)
		self:actualWidth(param.size.width)
		self:actualHeight(param.size.height)
	end

	if self._param.label then
		if param.size then
			self._label = Label.new(self._param.label):addTo(self):align(display.CENTER, 0, self._actualHeight / 2)
		else
			self._label = Label.new(self._param.label):addTo(self):align(display.CENTER, self._actualWidth / 2, self._actualHeight / 2)
		end
	end

	if self._param.labelImg then
		self._img = display.newSprite(self._param.labelImg, self._param.labelImgX, self._param.labelImgY):addTo(self)
	end

	self:enabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))
end

function JButton:enabled(bool)
	if type(bool) == "boolean" then
		if self._enabled ~= bool then
			self._enabled = bool
		end
		if self._param.unabled then
			self:updateTexture(self._enabled and self._param.normal or self._param.unabled)
		end
		self:setTouchEnabled(self._enabled)
		return self
	end
	return self._enabled
end

--- 触发点击事件
function JButton:doAction()
	self:dispatchEvent({name = BUTTON_EVENT.CLICKED})
end

function JButton:alignLabel(align, x, y)
	if self._label then
		self._label:align(align, x, y)
	end
	return self
end

function JButton:isTouchMoved()
	return self._isTouchMoved
end

function JButton:onTouch(evt)
	if evt.name == "began" then
		self._isTouchMoved = false
		self._prevX, self._prevY = evt.x, evt.y
		if self._param.down then
			self:updateTexture(self._param.down)
		else
			self:scale(.9)
		end
		self:onTouchBegan(evt)
		return true
	elseif evt.name == "moved" then
		if math.abs(evt.x - self._prevX) > 10 or math.abs(evt.y - self._prevY) > 10 then
			self._isTouchMoved = true
		end
		self:onTouchMoved(evt)
	elseif evt.name == "ended" then
		if self._param.down then
			self:updateTexture(self._param.normal)
		else
			self:scale(1)
		end

		if self:isPointIn(evt.x, evt.y) then
			self:onTouchEnded(evt)
			self:doAction()
		end
		self._isTouchMoved = false
	end
end

function JButton:updateTexture(texture)
	if self._scale9Sprite then
		self._scale9Sprite:removeSelf()
		self._scale9Sprite = createScale9Sprite(texture, self._param.size, self._param.capInsets):addTo(self)
	else
		self:setTexture(texture)
	end
end

function JButton:updateLabel(str)
	if self._label then
		self._label:setString(str)
	end	
end

function JButton:onOkPressed()
	if self._param.down then
		self:updateTexture(self._param.down)
	-- else
	-- 	self:scale(.9)
	end
end

function JButton:onOkReleased()
	if self._param.down then
		self:updateTexture(self._param.normal)
	-- else
	-- 	self:scale(1)
	end
end

function JButton:onTouchBegan(evt)
	self:dispatchEvent({name = BUTTON_EVENT.TOUCH_BEGAN, x = evt.x, y = evt.y})
end

function JButton:onTouchMoved(evt)
	self:dispatchEvent({name = BUTTON_EVENT.TOUCH_MOVED, x = evt.x, y = evt.y})
end

function JButton:onTouchEnded(evt)
	self:dispatchEvent({name = BUTTON_EVENT.TOUCH_ENDED, x = evt.x, y = evt.y})
end

function JButton:onCleanup()
	self:removeAllEventListeners()
	self:setNodeEventEnabled(false)
end

return JButton