--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-19 21:10:58
--

local JLoadingBar = class("JLoadingBar", function ()
	return cc.ClippingRegionNode:create()
end)

--[[--

进度控件构建函数

可用参数有：

-   scale9 是否缩放
-   capInsets 缩放的区域
-   image 图片
-   viewRect 显示区域
-   percent 进度值 0到100
-	direction 方向，默认值从左到右

]]
function JLoadingBar:ctor(param)
	makeUIComponent(self)
	if param.scale9 then
		self._isScale9 = true
		local scale9sp = ccui.Scale9Sprite or cc.Scale9Sprite
		if string.byte(param.image) == 35 then
			self._bar = scale9sp:createWithSpriteFrameName(string.sub(param.image, 2), param.capInsets)
		else
			self._bar = scale9sp:create(param.capInsets, param.image)
		end
		self:setClippingRegion(cc.rect(0, 0, param.viewRect.width, param.viewRect.height))
	else
		self._bar = display.newSprite(param.image)
	end

	self._direction = param.direction or Direction.LEFT_TO_RIGHT

	self:viewRect(param.viewRect)
	self._bar:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
	self._bar:setPosition(0, 0)
	self:setPercent(param.percent or 0)
	self:addChild(self._bar)
end

-- 设置进度控件的进度
-- @param number percent 进度值 0到100
-- @return UILoadingBar#UILoadingBar 
function UILoadingBar:setPercent(percent)
	local rect = cc.rect(0, 0, self._viewRect.width, self._viewRect.height)
	local newWidth = rect.width * percent / 100

	if self._isScale9 then
		self._bar:setPreferredSize(cc.size(newWidth, rect.height))
		if Direction.LEFT_TO_RIGHT ~= self._direction then
			self._bar:setPosition(rect.width - newWidth, 0)
		end
	else
		if Direction.LEFT_TO_RIGHT == self._direction then
			rect.width = newWidth
			self:setClippingRegion(cc.rect(rect.x, rect.y, rect.width, rect.height))
		else
			rect.x = rect.x + rect.width - newWidth
			rect.width = newWidth
			self:setClippingRegion(cc.rect(rect.x, rect.y, rect.width, rect.height))
		end
	end

	return self
end

-- 设置进度控件的方向
-- @param integer dir 进度的方向
-- @return UILoadingBar#UILoadingBar 
function UILoadingBar:dirction(dir)
	if dir then
		self._direction = dir
		if Direction.LEFT_TO_RIGHT ~= self._direction then
			if self._bar.setFlippedX then
				self._bar:setFlippedX(true)
			end
		end
		return self
	end
	return self._direction
end

-- 设置进度控件的显示区域
-- @param table rect 显示区域
-- @return UILoadingBar#UILoadingBar 
function UILoadingBar:viewRect(rect)
	if rect then
		self._viewRect = rect
		self._bar:setContentSize(rect.width, rect.height)
		return self	
	end
	return self._viewRect
end

return JLoadingBar