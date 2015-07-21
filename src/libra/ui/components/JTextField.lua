--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 10:34:53
--
local JTextField
JTextField = class("JTextField", function (param)
	if param.isEditBox then
		return JTextField.newEditBox(param)
	else
		return JTextField.newTextField(param)
	end
end)

function JTextField:ctor(param)
	makeUIComponent(self)
	if not param.isEditBox then
		self.getText = self.getStringValue
	end
end

--[[--

创建一个文字输入框，并返回 EditBox 对象。

可用参数：

-   image: 输入框的图像，可以是图像名或者是 Sprite9Scale 显示对象。用 display.newScale9Sprite() 创建 Sprite9Scale 显示对象。
-   imagePressed: 输入状态时输入框显示的图像（可选）
-   imageDisabled: 禁止状态时输入框显示的图像（可选）
-   listener: 回调函数
-   size: 输入框的尺寸，用 cc.size(宽度, 高度) 创建
-   x, y: 坐标（可选）

~~~ lua

local function onEdit(event, editbox)
	if event == "began" then
		-- 开始输入
	elseif event == "changed" then
		-- 输入框内容发生变化
	elseif event == "ended" then
		-- 输入结束
	elseif event == "return" then
		-- 从输入框返回
	end
end

local editbox = ui.newEditBox({
	image = "EditBox.png",
	listener = onEdit,
	size = cc.size(200, 40)
})

~~~

注意: 使用setInputFlag(0) 可设为密码输入框。

注意：构造输入框时，请使用setPlaceHolder来设定初始文本显示。setText为出现输入法后的默认文本。

注意：事件触发机制，player模拟器上与真机不同，请使用真机实测(不同ios版本貌似也略有不同)。

注意：changed事件中，需要条件性使用setText（如trim或转化大小写等），否则在某些ios版本中会造成死循环。

~~~ lua

--错误，会造成死循环

editbox:setText(string.trim(editbox:getText()))

~~~

~~~ lua

--正确，不会造成死循环
local _text = editbox:getText()
local _trimed = string.trim(_text)
if _trimed ~= _text then
	editbox:setText(_trimed)
end

~~~

@param table params 参数表格对象

@return EditBox 文字输入框

]]
function JTextField.newEditBox(param)
	local imageNormal = param.image
	local imagePressed = param.imagePressed
	local imageDisabled = param.imageDisabled

	if type(imageNormal) == "string" then
		imageNormal = display.newScale9Sprite(imageNormal)
	end
	if type(imagePressed) == "string" then
		imagePressed = display.newScale9Sprite(imagePressed)
	end
	if type(imageDisabled) == "string" then
		imageDisabled = display.newScale9Sprite(imageDisabled)
	end

	local editboxCls
	if cc.bPlugin_ then
		editboxCls = ccui.EditBox
	else
		editboxCls = cc.EditBox
	end
	local editbox = editboxCls:create(param.size, imageNormal, imagePressed, imageDisabled)

	if editbox then
		if param.listener then
			editbox:registerScriptEditBoxHandler(param.listener)
		end
		if param.x and param.y then
			editbox:setPosition(param.x, param.y)
		end
	end

	return editbox
end

--[[--

创建一个文字输入框，并返回 Textfield 对象。

可用参数：

-   listener: 回调函数
-   size: 输入框的尺寸，用 cc.size(宽度, 高度) 创建
-   x, y: 坐标（可选）
-   placeHolder: 占位符(可选)
-   text: 输入文字(可选)
-   font: 字体
-   fontSize: 字体大小
-   maxLength:
-   passwordEnable:开启密码模式
-   passwordChar:密码代替字符

~~~ lua

local function onEdit(textfield, eventType)
	if event == 0 then
		-- ATTACH_WITH_IME
	elseif event == 1 then
		-- DETACH_WITH_IME
	elseif event == 2 then
		-- INSERT_TEXT
	elseif event == 3 then
		-- DELETE_BACKWARD
	end
end

local textfield = UIInput.new({
	UIInputType = 2,
	listener = onEdit,
	size = cc.size(200, 40)
})

~~~

@param table param 参数表格对象

@return Textfield 文字输入框

]]
function JTextField.newTextField(param)
	local textfieldCls
	if cc.bPlugin_ then
		textfieldCls = ccui.TextField
	else
		textfieldCls = cc.TextField
	end
	local editbox = textfieldCls:create()
	editbox:setPlaceHolder(param.placeHolder)
	if param.x and param.y then
		editbox:setPosition(param.x, param.y)
	end	
	if param.listener then
		editbox:addEventListener(param.listener)
	end
	if param.size then
		editbox:setTextAreaSize(param.size)
	end
	if param.text then
		if editbox.setString then
			editbox:setString(param.text)
		else
			editbox:setText(param.text)
		end
	end
	if param.font then
		editbox:setFontName(param.font)
	end
	if param.fontSize then
		editbox:setFontSize(param.fontSize)
	end
	if param.maxLength and 0 ~= param.maxLength then
		editbox:setMaxLengthEnabled(true)
		editbox:setMaxLength(param.maxLength)
	end
	if param.passwordEnable then
		editbox:setPasswordEnabled(true)
	end
	if param.passwordChar then
		editbox:setPasswordStyleText(param.passwordChar)
	end
	-- if param.bg then
	--	 editbox:addChild(display.newSprite(param.bg), -1)
	-- end

	return editbox
end

return JTextField
