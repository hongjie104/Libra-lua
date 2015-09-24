--
-- 一些功能性的全局方法
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-20 10:25:49
--

DATA_CONFIG_PACKAGE = DATA_CONFIG_PACKAGE or "app.config."

import(".lang")
import(".transition")
import(".richText")

local scheduler = require("framework.scheduler")

localDump = import(".LocalDump").new()

--===========================================================================================

--- 使用二分法查找
-- @param table 数据表
-- @param key 查找的键，默认是type
-- @param val 查找的值
-- @return 数据表中的元素
function queryByType(table, key, val)
	if table then
		key = key or 'type'
		local leftIndex = 1
		local middleIndex = 1
		local rightIndex = #table

		while leftIndex <= rightIndex do
			midIndex= math.floor((leftIndex + rightIndex)/2)
			local midItem = table[midIndex]

			if midItem[key] == val then
				return midItem
			elseif val < midItem[key] then
				rightIndex = midIndex - 1
			else
				leftIndex = midIndex + 1
			end
		end
	end
end

--===========================================================================================

--- 根据type读取相应的配置文件
-- @param propType 物品Type
-- @param configName 配置文件，取lua文件名
-- @return 返回配置文件中物品的配置信息
function getConfig(propType, configName, compareStr)
	compareStr = compareStr and compareStr or 'ID'
	local config = require(DATA_CONFIG_PACKAGE .. configName)
	if config then
		return queryByType(config, compareStr, checkint(propType))
	end
end

--===========================================================================================

--- 清除无用纹理
function releaseCaches()
	logger:info("清除了没有用到的纹理")
	cc.AnimationCache:destroyInstance()
	display.removeUnusedSpriteFrames()
end

--===========================================================================================

function sceneOnEnter(scene)
	-- 进入场景之前先清理一次内存
	releaseCaches()

	-- 添加UI层
	local uiContainer = uiManager:getUIContainer()
	if uiContainer:getParent() ~= scene then
		uiContainer:removeFromParent(false)
	end
	uiContainer:addTo(scene, 999)

	if LUA_UI_EDITOR then
		import("libra.uiEditor.UIEditorContainer").new():addToContainer()
	end

	if not IS_TV then
		if device.platform == "android" then
			-- avoid unmeant back
			scene:performWithDelay(function()
				-- keypad layer, for android
				local layer = display.newNode()
				layer:setKeypadEnabled(true)
				layer:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
					if event.key == "back" then app.exit() end
				end)
				scene:addChild(layer)
			end, 0.5)
		end
	end
end

function sceneOnExit(scene)
	local uiContainer = uiManager:getUIContainer()
	if uiContainer:getParent() == scene then
		uiContainer:removeFromParent(false)
	end

	-- uiManager:clearTVController()
	-- 清除数据
	ccs.ArmatureDataManager:destroyInstance()
	-- SceneReader:sharedSceneReader():purge()
	-- ActionManager:purge()
	-- GUIReader:purge()
end

function sceneOnEnterTransitionFinish(scene)
	-- focusManager:init()
	-- if scene.hasTVController and type(scene.hasTVController) == "function" and scene.hasTVController() then
	-- 	uiManager:createTVController(function()
	-- 		uiManager:getTVController():addTo(scene, 1000)
	-- 	end)
	-- end
end

function replaceScene(newScene, transitionType, time, more)
	uiManager:clear()
	display.replaceScene(newScene, transitionType, time, more)
end

--===========================================================================================

function strToTable(str)
	if str == "" then
		return { },{ }
	end
	local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	local strLen = #str
	local index = strLen
	local indexList = { }	
	local strList = { }	
	for i = 1, string.len(str) do
		local tmp = string.byte(str, -index)
		local arrLen = #arr
		while arr[arrLen] do
			if tmp == nil then
				break
			end
			if tmp >= arr[arrLen] then
				index = index - arrLen
				break
			end
			arrLen = arrLen - 1
		end
		tmp = strLen - index
		if table.indexof(indexList, tmp) == false then
			indexList[#indexList + 1] = tmp
			if #indexList == 1 then
				strList[#strList + 1] = string.sub(str, 1, tmp)
			else
				strList[#strList + 1] = string.sub(str, indexList[#indexList - 1] + 1, indexList[#indexList])
			end
		end
	end
	return strList, indexList
end

function splitStrWith(str, splitChar)
	local strTable, indexTable = strToTable(str)
	local arr, count = { }, 1
	for i, v in ipairs(strTable) do
		if i > 1 then
			arr[count] = splitChar
			count = count + 1
		end
		arr[count] = v
		count = count + 1
	end
	local str = ''
	for i, v in ipairs(arr) do
		str = str .. v
	end
	return str
end

--- 获取带有中文的string的长度
function getStringLength(str)
	local strTable, indexTable = strToTable(str)
	return #indexTable
end

--- 获取自动换行的string
-- @param str 源String
-- @param fontName 字体名
-- @param fontSize 字体大小
-- @param lineWidth 一行的宽度
-- @return 带有换行符的字符串
function getWrapStr(str, lineWidth, fontName, fontSize)
	lineWidth = lineWidth or 360
	fontName = fontName or display.DEFAULT_TTF_FONT
	fontSize = fontSize or display.DEFAULT_TTF_FONT_SIZE
	if type(str) == "number" then
		str = tostring(str)
	elseif (not str) or (str == "") then
		-- debugLayer:warn("getWrapStr 传入字符串为空")
		return "", 0, 1, 0, FONT_SIZE, 0
	end

	local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	local label = display.newTTFLabel({text = '', font = fontName, size = fontSize})

	local strLen = #str
	local index = strLen
	local indexList = { }
	local tmpLineWidth = lineWidth
	for i = 1, string.len(str) do
		local tmp = string.byte(str, -index)
		local arrLen = #arr
		while arr[arrLen] do
			if tmp == nil then
				break
			end
			if tmp >= arr[arrLen] then
				index = index - arrLen
				break
			end
			arrLen = arrLen - 1
		end
		tmp = strLen - index
		if table.indexof(indexList, tmp) == false then
			indexList[#indexList + 1] = tmp
		end
	end
	
	-- 指定一个差不多的初始值 numStr（可以用指定宽度 width 除以字体大小），
	-- 截出 0 到 numStr 位置的字符串，用 getStrWidth 计算宽度，如果比我们指定的宽度 width 大，numStr--，
	-- 继续比较；否则 numStr++ 继续。直到 numStr 个字符宽度和我们指定宽度刚好相等（很小的概率），
	-- 或者 numStr 个字符长度不够，但 numStr+1 长度又多了的情况下，
	-- 可以确定这一行可以放这 numStr 个字符。然后继续处理下一行，直至字符串结束。
	local newStr = ''
	local numIndex = #indexList
	-- 每一行理论上的字数
	local numStr = checkint(lineWidth / fontSize)

	-- 截取一行文字的索引值
	local startIndex = 1
	local endIndexInIndexList = numStr
	if endIndexInIndexList > numIndex then
		endIndexInIndexList = numIndex
	end
	local endIndex = indexList[endIndexInIndexList]
	-- 一行文字
	local lineStr = ''
	local lineW, lineH = 0, 0
	local maxLineWidth = 1
	local minLineWidth = lineWidth + 1000
	-- 最后一行的宽度
	local lastLineWidth = 0
	-- 行数
	local lineNum = 0
	label:setString(lineStr)
	local size = nil
	while endIndexInIndexList <= numIndex do
		lineStr = string.sub(str, startIndex, endIndex)
		label:setString(lineStr)
		size = label:getContentSize()
		lineW, lineH = size.width, size.height
		if lineW > lineWidth then
			-- 要减少一个字符，直到w <= lineWidth
			repeat
				endIndexInIndexList = endIndexInIndexList - 1
				endIndex = indexList[endIndexInIndexList]
				lineStr = string.sub(str, startIndex, endIndex)
				label:setString(lineStr)
				size = label:getContentSize()
				lineW, lineH = size.width, size.height
			until lineW <= lineWidth
		elseif lineW < lineWidth then
			-- 要增加一个字符，直到w >= lineWidth
			repeat
				endIndexInIndexList = endIndexInIndexList + 1
				if endIndexInIndexList > numIndex then
					break
				end
				endIndex = indexList[endIndexInIndexList]
				lineStr = string.sub(str, startIndex, endIndex)
				label:setString(lineStr)
				size = label:getContentSize()
				lineW, lineH = size.width, size.height
			until lineW >= lineWidth
			-- 刚刚超出了预设宽度，所以减去一个字符
			endIndexInIndexList = endIndexInIndexList - 1
			endIndex = indexList[endIndexInIndexList]
			lineStr = string.sub(str, startIndex, endIndex)
		end
		if maxLineWidth < lineW then
			maxLineWidth = lineW
		end
		if minLineWidth > lineW then
			minLineWidth = lineW
		end
		lastLineWidth = lineW
		-- 一行文字确定完毕
		newStr = newStr .. lineStr .. '\n'
		lineNum = lineNum + 1
		-- 继续判断后面的文字
		startIndex = endIndex + 1
		if endIndexInIndexList >= numIndex then
			break
		end
		endIndexInIndexList = endIndexInIndexList + numStr
		if endIndexInIndexList > numIndex then
			endIndexInIndexList = numIndex
		end
		endIndex = indexList[endIndexInIndexList]
	end
	return newStr, maxLineWidth, minLineWidth, lineNum, lineH, lastLineWidth
end

--- 截取某个宽度的string
-- @param str 源String
-- @param lineWidth 宽度
-- @param fontName 字体名
-- @param fontSize 字体大小
-- @return 截取出的字符串
-- @return 剩下的字符串
function getSubStrByWidth(str, lineWidth, fontName, fontSize)
	if str == nil or #str == 0 then 
		return 
	end

	fontName = fontName or display.DEFAULT_TTF_FONT
	fontSize = fontSize or display.DEFAULT_TTF_FONT_SIZE
	local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}

	local strLen = #str
	local index = strLen
	local indexList = { }
	local tmpLineWidth = lineWidth
	for i = 1, string.len(str) do
		local tmp = string.byte(str, -index)
		local arrLen = #arr
		while arr[arrLen] do
			if tmp == nil then
				break
			end
			if tmp >= arr[arrLen] then
				index = index - arrLen
				break
			end
			arrLen = arrLen - 1
		end
		tmp = strLen - index
		if table.indexof(indexList, tmp) == false then
			indexList[#indexList + 1] = tmp
		end
	end

	local wrapHelpLabel = display.newTTFLabel({text = str, font = fontName, size = fontSize})

	-- 优化效率
	-- if wrapHelpLabel:getContentSize().width <= lineWidth then
	-- 	-- 不用截
	-- 	return str, nil, wrapHelpLabel:getContentSize().height
	-- else
		local numIndex = #indexList
		-- 理论上的字数
		local numStr = math.floor(lineWidth / fontSize)
		if numStr < 1 then
			return nil, str, 0
			-- numStr = 1
		end
		-- 截取一行文字的索引值
		local startIndex = 1
		local endIndexInIndexList = numStr
		if endIndexInIndexList > numIndex then
			endIndexInIndexList = numIndex
		end
		local endIndex = indexList[endIndexInIndexList]

		-- 一行文字
		local lineStr = string.sub(str, startIndex, endIndex)

		local lineW = 1
		wrapHelpLabel:setString(lineStr)
		if lineW > lineWidth then
			-- 要减少一个字符，直到w <= lineWidth
			repeat
				endIndexInIndexList = endIndexInIndexList - 1
				endIndex = indexList[endIndexInIndexList]
				lineStr = string.sub(str, startIndex, endIndex)
				wrapHelpLabel:setString(lineStr)
				lineW = wrapHelpLabel:getContentSize().width
			until lineW <= lineWidth
		elseif lineW < lineWidth then
			-- 要增加一个字符，直到w >= lineWidth
			repeat
				endIndexInIndexList = endIndexInIndexList + 1
				if endIndexInIndexList > numIndex then
					break
				end
				endIndex = indexList[endIndexInIndexList]
				lineStr = string.sub(str, startIndex, endIndex)
				wrapHelpLabel:setString(lineStr)
				lineW = wrapHelpLabel:getContentSize().width
			until lineW >= lineWidth
			-- 刚刚超出了预设宽度，所以减去一个字符
			endIndexInIndexList = endIndexInIndexList - 1
			endIndex = indexList[endIndexInIndexList]
			lineStr = string.sub(str, startIndex, endIndex)
		end
		return lineStr, string.sub(str, endIndex + 1), wrapHelpLabel:getContentSize().height
	-- end
end

--===========================================================================================

--- 从 package.path 中查找指定模块的文件名，如果失败返回 nil
function findModulePath(moduleName)
	for k, v in pairs(package.loaded) do
		if string.find(k, moduleName) then
			return k
		end
	end
end

--- 获取目标目录下所有的文件列表
function getpathes(rootpath, pathes)
	require "lfs"
	local pathes = pathes or { }
	local ret, files, iter = pcall(lfs.dir, rootpath)
	if not ret then
		return pathes
	end
	for entry in files, iter do
		local next = false
		if entry ~= '.' and entry ~= '..' then
			local path = rootpath .. '/' .. entry
			local attr = lfs.attributes(path)
			if attr == nil then
				next = true
			end

			if next == false then 
				if attr.mode == 'directory' then
					getpathes(path, pathes)
				else
					table.insert(pathes, path)
				end
			end
		end
		next = false
	end
	return pathes
end

--===========================================================================================

function getNumberLength(num)
	if num == 0 then return 0 end
	return 1 + getNumberLength(checkint(num / 10))
end

--===========================================================================================

--- 序列化一个对象
function serialize(obj)
	local lua = ""
	local t = type(obj)
	if t == "number" then
		lua = lua .. obj
	elseif t == "boolean" then
		lua = lua .. tostring(obj)
	elseif t == "string" then
		lua = lua .. string.format("%q", obj)
	elseif t == "table" then
		lua = lua .. "{"
		local key = nil
		for k, v in pairs(obj) do
			if type(k) == "table" then
				key = serialize(k)
			else
				key = k
			end
			if type(key) == "number" then
				lua = lua .. serialize(v) .. ","
			else
				lua = lua .. key .. "=" .. serialize(v) .. ","
			end
		end
		-- 去掉最后一个逗号
		if string.sub(lua, -1) == ',' then
			lua = string.sub(lua, 1, -2)
		end
		local metatable = getmetatable(obj)
		if metatable ~= nil and type(metatable.__index) == "table" then
			for k, v in pairs(metatable.__index) do
				lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
			end
		end
		lua = lua .. "}"
	elseif t == "nil" then
		return nil
	else
		error("can not serialize a " .. t .. " type.")
	end
	return lua
end

--- 反序列化一个对象
function unserialize(lua)
	local t = type(lua)
	if t == "nil" or lua == "" then
		return nil
	elseif t == "number" or t == "string" or t == "boolean" then
		lua = tostring(lua)
	else
		error("can not unserialize a " .. t .. " type.")
	end
	lua = "return " .. lua
	local func = loadstring(lua)
	if func then
		return func()
	end
end

--===========================================================================================

local shakeNode = nil
local shakeHandler = nil
local isShakeing = false
local shakeAry = nil
local totalShake, curShake = 0, 1
local shakeNodeX, shakeNodeY = 0, 0

function stopShake()
	curShake = 1
	if shakeHandler then
		scheduler.unscheduleGlobal(shakeHandler)
		shakeHandler = nil
		shakeNode:pos(shakeNodeX, shakeNodeY)
	end
end

function shaking()
	if shakeNode then
		shakeNode:pos(shakeNodeX + shakeAry[curShake][1], shakeNodeY + shakeAry[curShake][2])
		curShake = curShake + 1
		if curShake > totalShake then
			stopShake()	
		end
	else
		stopShake()
	end
end

--- 震动
function shake(node)
	shakeAry = { }
	for i = 1, 8 do
		shakeAry[i] = {math.random(-20, 20), math.random(-20, 20)}
	end
	totalShake, curShake = #shakeAry, 1
	shakeNode = node
	shakeNodeX = shakeNode:x()
	shakeNodeY = shakeNode:y()
	shakeHandler = scheduler.scheduleGlobal(shaking, .1)
end

--==========================================================================

--字符串中每个字符后加换行符"\n", 包括其中含有中文字符

function addLineBreak(obj)
	local res = ""

	if "string" == type(obj) then 
		local pos = 1
		while pos <= #obj do
			local tmp = ""
			if string.byte(obj,pos) > 127 then -- 判断是否是中文字符
				tmp = string.sub(obj, pos, pos + 2)
				pos = pos + 3
			else
				tmp = string.sub(obj, pos, pos)
				pos = pos + 1
			end
			res = res .. tmp .. "\n" 
		end
	end
	return res
end

