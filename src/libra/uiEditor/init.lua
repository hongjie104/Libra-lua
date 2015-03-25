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
table.insertto(UI_CONFIG, {
	{name = "测试面板", uiConfig = {
		{id = "_testBtn", ui = "libra.ui.components.JButton", param = {normal = "btnRed2_normal.png", down1 = "btnRed2_down.png", label = {text = "hello world", size = 24}}, x = display.cx, y = display.cy},
		{id = "_testBtn1", ui = "libra.ui.components.JButton", param = {normal = "btnRed2_normal.png", down1 = "btnRed2_down.png", label = {text = "hello world", size = 24}}, x = display.cx, y = display.cy + 50}
		}},
})