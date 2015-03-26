--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-17 20:58:50
--

COMPONENT_LIST = COMPONENT_LIST or { }
table.insertto(COMPONENT_LIST, {
	{name = "Button", path = "libra.ui.components.JButton"},
	{name = "CheckBox", path = "libra.ui.components.JCheckBox"},
	{name = "CheckBoxGroup"},
	{name = "Container"},
	{name = "CountDown"},
	{name = "Image"},
	{name = "Label", path = "libra.ui.components.JLabel"},
	{name = "ListView"},
	{name = "LoadingBar"},
	{name = "PageView"},
	{name = "Panel"},
	{name = "ScrollView"},
	{name = "TextField"},
})

UI_CONFIG = UI_CONFIG or { }
if cc.FileUtils:getInstance():isFileExist("app/uiConfig.lua") then
	table.insertto(UI_CONFIG, require("app.uiConfig"))
end