require("config")
require("framework.init")
require("libra.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
	MyApp.super.ctor(self)
end

function MyApp:run()
	-- self:enterScene("test.ButtonScene")
	-- self:enterScene("test.CheckBoxScene")
	-- self:enterScene("test.CountDownScene")
	self:enterScene("test.CCSScene")
	-- self:enterScene("MainScene")
end

return MyApp
