--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-26 17:49:14
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
	__ = assert(require("framework.cc.utils.Gettext").gettextFromFile(langFile), 
			string.format("framework.cc.utils.Gettext gettextFromFile(%s) return nil", langFile))
end

function _(text, ...)
	text = __(text)
	return string.format(text, ...)
end