--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:01:02
--

local JContainer = class("JContainer", function ()
	return display.newNode()
end)

-- @param param {bg="背景图", size = cc.size() or nil, capInsets = cc.rect() or nil}
function JContainer:ctor(param)
	self._param = param or { }
	self._param.width = self._param.width or display.width
	self._param.height = self._param.height or display.height
	makeUIComponent(self)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	
	if self._param.size then
		self:setSize(self._param.size.width, self._param.size.height)
	else
		self:setSize()
	end
	self._componentList = { }
	self:align(display.CENTER, display.cx, display.cy)

	self:setNodeEventEnabled(true)
end

function JContainer:createUI(uiConfig)
	local uiComponent = nil
	for _, ui in ipairs(uiConfig) do
		uiComponent = require(ui.ui).new(ui.param):addToContainer(self)
		if ui.id then
			self[ui.id] = uiComponent
			uiComponent:name(ui.id)
		end
		for k, v in pairs(ui) do
			if k ~= "id" and k ~= 'ui' and k ~= 'param' then
				if type(uiComponent[k]) == "function" then
					if type(v) == "table" then
						local l = #v
						if l == 1 then
							uiComponent[k](uiComponent, v[1])
						elseif l == 2 then
							uiComponent[k](uiComponent, v[1], v[2])
						elseif l == 3 then
							uiComponent[k](uiComponent, v[1], v[2], v[3])
						elseif l == 4 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4])
						elseif l == 5 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5])
						elseif l == 6 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5], v[6])
						elseif l == 7 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5], v[6], v[7])
						elseif l == 8 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
						elseif l == 9 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9])
						elseif l == 10 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10])
						end
					else
						uiComponent[k](uiComponent, v)
					end
				end
			end
		end
	end
end

function JContainer:setSize(width, height)
	width = width or display.width
	height = height or display.height
	self._halfWidth, self._halfHeight = width / 2, height / 2
	self:actualWidth(width):actualHeight(height)
	if self._param and self._param.bg then
		if self._bg then
			if self._param.size then
				self._bg:setContentSize(size):pos(self._halfWidth, self._halfHeight)
			end
		else
			if self._param.size then
				self._bg = display.newScale9Sprite(self._param.bg, self._halfWidth, self._halfHeight, self._param.size, self._param.capInsets):addTo(self, -1):align(display.CENTER)
			else
				self._bg = display.newSprite(self._param.bg):addTo(self, -1):pos(display.cx, display.cy)
			end
		end
	end
	return self
end

function JContainer:getHalfHeight(val)
	return self._halfHeight
end

function JContainer:getHalfWidth(val)
	return self._halfWidth
end

function JContainer:getSize()
	return self._actualWidth, self._actualHeight
end

function JContainer:isContainer()
	return true
end

function JContainer:addUIComponent(component, zOrder)
	if not table.indexof(self._componentList, component) then
		self:addChild(component)
		if type(zOrder) == "number" then
			component:zorder(zOrder)
		end
		self._componentList[#self._componentList + 1] = component
	end
	return self
end

function JContainer:getUIComponent(name)
	if name and name ~= '' then
		for _, v in ipairs(self._componentList) do
			if v:name() == name then return v end
		end
	end
end

function JContainer:removeUIComponent(component)
	local index = table.indexof(self._componentList, component)
	if index then
		table.remove(self._componentList, index)
		-- 这里不能使用removeSelf,因为在ui\init中将removeSelf方法进行了重写
		component:removeFromParent(true)
	end
end

function JContainer:clearComponents()
	self:removeAllChildren()
	self._componentList = { }
end

--- 初始化获得焦点的组件
function JContainer:initFocusComponent()
	return self:gainNextFocusComponent()
end

function JContainer:uninitFocusComponent()
	if self._focusComponent then
		self._focusComponent:lostFocus()
	end
end

-- @private
-- @param direction 获取哪个方向的焦点组件,默认是取上一个已获得焦点的组件
function JContainer:gainNextFocusComponent(direction)
	local focusChanged = false
	if self._focusComponent then
		if direction then
			local nextFocusComponetn = nil
			if Direction.LEFT_TO_RIGHT == direction then
				nextFocusComponetn = self._focusComponent:rightComponent()
			elseif Direction.RIGHT_TO_LEFT == direction then
				nextFocusComponetn = self._focusComponent:leftComponent()
			elseif Direction.TOP_TO_BOTTOM == direction then
				nextFocusComponetn = self._focusComponent:bottomComponent()
			elseif Direction.BOTTOM_TO_TOP == direction then
				nextFocusComponetn = self._focusComponent:topComponent()
			end
			-- 如果没有找到指定的控件，那么用grid来找找看
			if not nextFocusComponetn then
				if self._grid then
					local dataList = self._grid:getDataFrom( self._focusComponent, direction)
					if dataList and #dataList > 0 then
						nextFocusComponetn = dataList[1]
					end
				end
			end
			if nextFocusComponetn then
				self._focusComponent:lostFocus()
				self._focusComponent = nextFocusComponetn
				focusChanged = true
			end
		end
	else
		for i, v in ipairs(self._componentList) do
			if type(v.doAction) == "function" then
				self._focusComponent = v
				break
			end
		end
	end

	if self._focusComponent then
		self._focusComponent:gainFocus()
	else
		logger:info(self.class.__cname, "中没有找到_focusComponent")
		-- uiManager:setTVControllerVisiable(false)
	end
	return focusChanged
end

--- 构建网格，用于自动寻找某一个方向的控件
function JContainer:buildGrid(deep, showGrid)
	self._grid = require("libra.utils.Grid").new(self, deep, showGrid)
end

function JContainer:addGridComponent(component)
	if self._grid then
		if type(component.doAction) == "function" then
			self._grid:addData(component, component:x(), component:y())
		else
			logger:error(component:name(), "没有doAction方法,无法用addGridComponent添加到Grid中")
		end
	else
		logger:error(self._name, "没有buildGrid,无法执行方法:addGridComponent")
	end
end

function JContainer:clearGridComponents()
	if self._grid then
		self._grid:clearData()
	else
		logger:error(self._name, "没有buildGrid,无法执行方法:clearGridComponent")
	end
end

--- 刷新面板，因为数据层的变化，面板也要随之更新
function JContainer:update(param)
	-- body
end

--- 处理返回键的逻辑，如果需要用到返回键，那么该方法的返回值必须得是true
function JContainer:doBackHandler()
	return false
end

--- 处理上一container跳转至至当前Container
function JContainer:doBackToCurHandler(param)
end

--- 处理当前Container跳转至下一Container
function JContainer:doForwardToNextHandler(param)
end

function JContainer:onKeyPressed(key)
	if key == KEY.LEFT then
		self:dispatchEvent({name = KEY_EVENT.LEFT_PRESSED})
	elseif key == KEY.RIGHT then
		self:dispatchEvent({name = KEY_EVENT.RIGHT_PRESSED})
	elseif key == KEY.UP then
		self:dispatchEvent({name = KEY_EVENT.UP_PRESSED})
	elseif key == KEY.DOWN then
		self:dispatchEvent({name = KEY_EVENT.DOWN_PRESSED})
	elseif key == KEY.MENU then
		self:dispatchEvent({name = KEY_EVENT.MENU_PRESSED})
		if IS_DEBUG then
			-- 按下菜单键，记录下时间，此时间用来判断是否弹出debug菜单
			MENU_PRESSED_TIME = os.time()
		end
	elseif key == KEY.OK or key == 163 then
		self:dispatchEvent({name = KEY_EVENT.OK_PRESSED})
		if self._focusComponent then
			if type(self._focusComponent.onOkPressed) == "function" then
					self._focusComponent:onOkPressed()
			-- else
			-- 	logger:warn(self._focusComponent:name(), "没有onOkPressed方法")
			end
		end
	elseif key == KEY.BACK then
		self:dispatchEvent({name = KEY_EVENT.BACK_PRESSED})
	else
		logger:warn(getKeyCode(key), "key = ", key, "没注册按键按下监听")
	end
end

function JContainer:onKeyReleased(key)
	if key == KEY.LEFT then
		self:dispatchEvent({name = KEY_EVENT.LEFT_RELEASED, focusChanged = self:gainNextFocusComponent(Direction.RIGHT_TO_LEFT)})
	elseif key == KEY.RIGHT then
		self:dispatchEvent({name = KEY_EVENT.RIGHT_RELEASED, focusChanged = self:gainNextFocusComponent(Direction.LEFT_TO_RIGHT)})
	elseif key == KEY.UP then
		self:dispatchEvent({name = KEY_EVENT.UP_RELEASED, focusChanged = self:gainNextFocusComponent(Direction.BOTTOM_TO_TOP)})
	elseif key == KEY.DOWN then
		self:dispatchEvent({name = KEY_EVENT.DOWN_RELEASED, focusChanged = self:gainNextFocusComponent(Direction.TOP_TO_BOTTOM)})
	elseif key == KEY.MENU then
		self:dispatchEvent({name = KEY_EVENT.MENU_RELEASED})
		if IS_DEBUG then
			local t = os.time()
			if t - MENU_PRESSED_TIME > 2 then
				MENU_PRESSED_TIME = t
				-- libraIcon弹出
				libraIcon:unfold()
			end
		end
	elseif key == KEY.OK or key == 163 then
		self:dispatchEvent({name = KEY_EVENT.OK_RELEASED})
		if self._focusComponent then
			if type(self._focusComponent.onOkReleased) == "function" then
				self._focusComponent:onOkReleased()
			-- else
			-- 	logger:warn(self._focusComponent:name(), "没有onOkReleased方法")
			end

			if type(self._focusComponent.doAction) == "function" then
				self._focusComponent:doAction()
			else
				logger:warn(self._focusComponent:name(), "没有doAction方法")
			end
		else
			logger:warn(self._name, "没有focusComponent")
		end
	elseif key == KEY.BACK then
		self:dispatchEvent({name = KEY_EVENT.BACK_RELEASED})
	else
		logger:warn(getKeyCode(key), "key = ", key, "没注册按键松开事件监听")
	end
end

function JContainer:onEnter()
	-- do nothing
end

function JContainer:onCleanup()
	self:removeAllEventListeners()
	self:setNodeEventEnabled(false)
end

--- 画个容器的边框出来，用于debug，线条是黄色的
function JContainer:drawBorder()
	local lineBorder = {borderColor = cc.c4f(1.0, 1.0, 0.0, 1.0), borderWidth = 2}
	-- 先画水平的线
	display.newLine({{0, 0}, {self._actualWidth, 0}}, lineBorder):addTo(self, 999)
	display.newLine({{0, self._actualHeight}, {self._actualWidth, self._actualHeight}}, lineBorder):addTo(self, 999)
	-- 再画垂直的线
	display.newLine({{0, self._actualHeight}, {0, 0}}, lineBorder):addTo(self, 999)
	display.newLine({{self._actualWidth, self._actualHeight}, {self._actualWidth, 0}}, lineBorder):addTo(self, 999)
end

-- --- 获取容器所包含组件个数 
-- function JContainer:getComponentCount()
-- 	return #self._componentList
-- end

return JContainer