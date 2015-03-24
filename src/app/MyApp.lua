
require("config")
require("cocos.init")
require("framework.init")
require("libra.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()    
    self:enterScene("MainScene")
    -- self:enterScene("login.LoginScene")
end

return MyApp
