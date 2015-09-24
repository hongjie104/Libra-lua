--
-- Author: zhouhongjie@apowo.com
-- Date: 2014-07-08 15:27:57
--

local nodeType = {startTag = 0, text = 1, endTag = 2, brTag = 3}

local function parseHtml(htmlText)
	local nodeList, node = {}, {}
	local char, charByte = nil, nil
	local isParseTaging = false

	local l = string.len(htmlText)
	for i = 1, l do
		char = string.sub(htmlText, i, i)
		charByte = string.byte(char)
		if charByte == 60 then
			-- <
			isParseTaging = true
			if node.type then
				nodeList[#nodeList + 1] = node
				node = {}
			end
			if string.byte(string.sub(htmlText, i + 1, i + 1)) == 47 then
				-- </ 这是闭合的标签
				node = {type = nodeType.endTag, text = ''}
			elseif string.sub(htmlText, i + 1, i + 3) == "br>" then
				-- <br>
				-- print("test get <br> !")
				node = {type = nodeType.brTag, text = ''}
			else
				--todo
				-- 这是非闭合的标签
				node = {type = nodeType.startTag, text = ''}
			end
		elseif charByte == 62 then
			-- >
			isParseTaging = false
			if node.type then
				nodeList[#nodeList + 1] = node
				node = {}
			end
		elseif charByte ~= 47 then
			if isParseTaging then
				node.text = node.text .. char
			else
				if not node.type then
					node.type = nodeType.text
					node.text = ''
				end
				node.text = node.text .. char
				-- 末尾文本也做为一个节点
				if i == l then
					nodeList[#nodeList + 1] = node
				end
			end
		end
	end

	for i, v in ipairs(nodeList) do
		if v.type == nodeType.startTag then
			local ary = string.split(v.text, ' ')
			v.tag = ary[1]
			-- 标签属性
			v.props = {}
			for i = 2, #ary do
				v.props[#v.props + 1] = string.split(ary[i], '=')
			end
			v.text = nil
		elseif v.type == nodeType.endTag then
			v.tag = string.split(v.text, ' ')[1]
			v.text = nil
		elseif v.type == nodeType.brTag then
			v.tag = "br"
			v.text = nil
		end
	end

	return nodeList
end

function createRichText(htmlText, lineWidth, font, fontsize, defaultColor, outlineColor, hrefHandler)
	local labelList = { }
	local nodeSize = {width=0, height=0}

	local function createLabel(props, node, x, y, a)
		local label = display.newTTFLabel(props):addTo(node)
		local labelH = label:getContentSize().height
		label:pos(x, y - labelH)
		label:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
		if a.href then
			label._href = a.href

			-- 加个下划线
			local str = '_'
			props.text = str
			local t = display.newTTFLabel(props)
			for i = 1, checkint(label:getContentSize().width / t:getContentSize().width) - 1 do
				str = str .. '_'
			end
			t:setString(str)
			t:pos(x, y - labelH):addTo(node)
			t:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])

			-- 注册点击事件
			label:setTouchEnabled(true)
			label:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				if event.name == 'began' then
					return true
				elseif event.name == 'ended' then
					-- print('打开连接:' .. label._href)
					if type(hrefHandler) == "function" then
						hrefHandler(label._href)
					end
				end
			end)
		end
		return label
	end

	local function pushBackLabel(label)
		labelList[#labelList + 1] = label

		-- 更新容器尺寸
		if nodeSize.width < 
			(label:getPositionX() + 
				label:getContentSize().width) then
			nodeSize.width = label:getPositionX() + label:getContentSize().width
		end
		if nodeSize.height > label:getPositionY() then
			nodeSize.height = label:getPositionY()
		end
	end

	local lineWidth = lineWidth or 400
	local node = display.newNode()

	local nodeList = parseHtml(htmlText)
	-- 默认的字体属性
	local fontProps = {x = 0, y = 0, size = fontsize or FONT_SIZE, font = font or FONT, align = cc.ui.TEXT_ALIGN_LEFT, color = defaultColor or display.COLOR_WHITE}
	-- a属性
	local a = { }
	local label = nil
	local leftWidth, leftStr, lineHeight = lineWidth, nil, 0
	local x, y = 0, 0
	-- 当前行数
	local curLine = 1

	for i, v in ipairs(nodeList) do
		if v.type == nodeType.startTag then
			local props = v.props
			if v.tag == 'font' then
				fontProps.size = fontsize or FONT_SIZE
				fontProps.font = font or FONT
				fontProps.color = defaultColor or display.COLOR_WHITE
				for ii, vv in ipairs(props) do
					if vv[1] == 'size' then
						print(vv[2])
						fontProps.size = checkint(string.gsub(string.gsub(vv[2], "\"", ""), "'", ""))
						print("fontProps.size = ", fontProps.size)
					elseif vv[1] == 'color' then
						-- 因为颜色Str为“#ff00ff”,所以要从第三个算起
						local colorStr = string.sub(vv[2], 3)
						fontProps.color = cc.c3b(
												checkint(string.format("%d", '0x' .. string.sub(colorStr, 1, 2))), 
												checkint(string.format("%d", '0x' .. string.sub(colorStr, 3, 4))), 
												checkint(string.format("%d", '0x' .. string.sub(colorStr, 5, 6)))
											)
					end
				end
			elseif v.tag == 'a' then
				for ii, vv in ipairs(props) do
					if vv[1] == 'href' then
						a.href = vv[2]
					end
				end
			end   
		elseif v.type == nodeType.endTag then
			-- 重置默认文本格式
			fontProps.size = fontsize or FONT_SIZE
			fontProps.font = font or FONT
			fontProps.color =defaultColor or display.COLOR_WHITE
			if v.tag == 'a' then
				a.href = nil
			end
		elseif v.type == nodeType.brTag then
			-- print("test append <br> !")
			curLine = curLine + 1
			x = 0
			y = y - lineHeight
			leftWidth = lineWidth
		else
			-- 文本内容
			-- print("开始计算宽度")
			fontProps.text, leftStr, lineHeight = getSubStrByWidth(v.text, leftWidth, fontProps.font, fontProps.size)
			-- print("计算宽度结束")
			if fontProps.text then
				-- print("开始创建行")
				label = createLabel(fontProps, node, x, y, a)
				-- print("创建行结束")
				if outlineColor then
					label:enableOutline(outlineColor, 2)
				end

				label._line = curLine

				pushBackLabel(label)
			end
			y = y - lineHeight
			curLine = curLine + 1
			-- 算出这一行还剩下多少宽度
			leftWidth = leftWidth - label:getContentSize().width
			while leftStr and leftStr ~= '' do
				-- 如果有leftStr吗，说明这一段文字的宽度超过了一行中的剩下的宽度
				-- 那就转到下一行，继续进行截取
				x = 0
				-- print("开始计算宽度")
				fontProps.text, leftStr, lineHeight = getSubStrByWidth(leftStr, lineWidth, fontProps.font, fontProps.size)
				-- print("计算宽度结束")
				fontProps.font = FONT
				if fontProps.text then
					-- print("开始创建行")
					label = createLabel(fontProps, node, x, y, a)
					-- print("创建行结束")
					if outlineColor then
						label:enableOutline(outlineColor, 2)
					end

					label._line = curLine

					pushBackLabel(label)
				end
				y = y - lineHeight
				curLine = curLine + 1
			end
			-- 截取完毕，剩下的宽度是总宽度减去当前行中其他label宽度的总和
			local totalWidth = 0
			for i, v in ipairs(labelList) do
				if v._line == curLine - 1 then
					totalWidth = totalWidth + v:getContentSize().width
				end
			end
			leftWidth = lineWidth - totalWidth

			if leftWidth < fontProps.size then
				leftWidth = lineWidth
			end
			if leftWidth < lineWidth then
				x = x + label:getContentSize().width
				y = y + lineHeight
				curLine = curLine - 1
			else
				x = 0
			end
		end
	end

	nodeSize.height = math.abs(nodeSize.height)
	node:setContentSize(cc.size(nodeSize.width, nodeSize.height))
	return node
end

--- 创建一个由Widget包装的richText(CCNode)控件
-- Widget可以接受ListView等容器控件的布局
function getRichTextWidget(htmlText, lineWidth, hrefHandler)
	local richText = getRichText(htmlText, lineWidth, hrefHandler)
	richText:setAnchorPoint(CCPoint(0, 1))
	richText:setPosition(CCPoint(0, richText:getContentSize().height * 2))

	local widget = Widget:create()
	widget:setAnchorPoint(CCPoint(0, 0))
	widget:setSize(richText:getContentSize())
	widget:ignoreContentAdaptWithSize(false)
	widget:addNode(richText)

	return widget
end