require("config")
require("framework.init")
require("libra.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
	MyApp.super.ctor(self)
end

function MyApp:run()
	self:enterScene("MainScene")
end

return MyApp
