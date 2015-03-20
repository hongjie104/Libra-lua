--
-- 一些功能性的全局方法
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-20 10:25:49
--

LANG = LANG or 'zh-cn'

--- 多语言方法
-- @param text 文本内容
-- @return 返回翻译之后的文本
local function __(text)
	return text
end

--- 判断当前是否存在多语言文件
local langFile = "res/lang/" .. LANG .. ".mo"
if cc.FileUtils:getInstance():isFileExist(langFile) then
	__ = assert(require("framework.cc.utils.Gettext").gettextFromFile(langFile))
end

function _(text, ...)
	text = __(text)
	return string.format(text, ...)
end

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
-- @param configType 配置文件，取lua文件名
-- @return 返回配置文件中物品的配置信息
function getConfig(propType, configType, compareStr)
	compareStr = compareStr and compareStr or 'ID'
	local config = require('app.config.' .. configType)
	if config then
		return queryByType(config, compareStr, checkint(propType))
	end
end

--===========================================================================================

--- 清除无用纹理
function releaseCaches()
	-- logger:info("清除了没有用到的纹理")
	-- cc.AnimationCache:purgeSharedAnimationCache()
	-- cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	-- CCTextureCache:sharedTextureCache():removeUnusedTextures()
	-- CCArmatureDataManager:purge()
end

--===========================================================================================

function sceneOnEnter(scene)
	-- 进入场景之前先清理一次内存
	releaseCaches()

	-- 添加UI层
	libraUIManager:getUIContainer():addTo(scene)
    if LUA_UI_EDITOR then
        import("libra.uiEditor.UIEditorContainer").new():addToContainer()
    end

    if device.platform == "android" then
		-- avoid unmeant back
		scene:performWithDelay(function()
			-- keypad layer, for android
			local layer = display.newLayer()
			layer:addKeypadEventListener(function(event)
				if event == "back" then app.exit() end
			end)
			scene:addChild(layer)

			layer:setKeypadEnabled(true)
		end, 0.5)
	end
end

function sceneOnExit(scene)
	-- 清除数据
	-- CCArmatureDataManager:purge()
	-- SceneReader:sharedSceneReader():purge()
	-- ActionManager:purge()
	
	-- GUIReader:purge()
	-- skeletonDataPool:clearTmpSkeletonData()
	-- if msgPanelList then
	-- 	for i, v in ipairs(msgPanelList) do
	-- 		v:close()
	-- 	end
	-- 	msgPanelList = { }
	-- end
end

function getStringLength(str)
	if str == "" then
		return 0
	end
	local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	local strLen = #str
	local index = strLen
	local indexList = { }	
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
	return #indexList
end

--- 从 package.path 中查找指定模块的文件名，如果失败返回 false。
-- @param string moduleName
-- @return string
-- function findModulePath(moduleName)
--     local filename = string.gsub(moduleName, "%.", "/") .. ".lua"
--     local paths = string.split(package.path, ";")
--     for i, path in ipairs(paths) do
--         if string.sub(path, -5) == "?.lua" then
--             path = string.sub(path, 1, -6)
--             if not string.find(path, "?", 1, true) then
--                 local fullpath = path .. filename
--                 if io.exists(fullpath) then
--                     return fullpath
--                 end
--             end
--         end
--     end
--     return false
-- end

function findModulePath(moduleName)
	for k, v in pairs(package.loaded) do
		if string.find(k, moduleName) then
			return k
		end
	end
end

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
