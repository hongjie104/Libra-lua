--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-09-15 19:44:11
--

local ResUrlPHP = 'http://127.0.0.1/filelist'

local InitScene = class("InitScene", function ()
	return display.newScene("InitScene")
end)

function InitScene:ctor()

end

function InitScene:init()
	if UPDATE then
		-- 热更新的资源都在这个目录下
		cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath() .. "upd/")
	end
	cc.FileUtils:getInstance():addSearchPath("res/")
	self:enterApp()
end

function InitScene:enterApp()
	if UPDATE then
		require("update")
	else
		require("app.MyApp").new():run()
	end
end

function InitScene:onEnterTransitionFinish()
	if UPDATE then
		-- 先获取热更新资源地址
		-- local request = network.createHTTPRequest(function(event)
		-- 	self:onResUrlResponse(event, index)
		-- end, ResUrlPHP, "GET")
		-- request:setTimeout(20)
		-- request:start()

		self:init()
	else
		self:init()
	end
end

--- 收到php传来的服务器列表数据的回调函数
function InitScene:onResUrlResponse(event)
	local request = event.request
	if event.name == "completed" then
		if request:getResponseStatusCode() ~= 200 then
			self:init()
		else
			local resUrldataRecv = request:getResponseData()
			print("热更新php传回的值", resUrldataRecv)
			-- local json = json.decode(resUrldataRecv)

			-- 资源下载路径
			-- resUrl = json.data.platform.downLoad_url

			self:init()
		end
	elseif event.name == 'failed' then
		self:init()
	end
end

cc.Director:getInstance():runWithScene(InitScene.new())