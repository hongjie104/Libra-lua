--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-16 11:31:11
--

local SocketTCP = require('framework.cc.net.SocketTCP')
require("framework.cc.utils.init")

local SocketHandler = class('SocketHandler')

--- 建立连接
-- @param ip 服务器ip
-- @param port 端口
function SocketHandler:connect(ip, port)
	local ip = "localhost"
	local port = 3630
	if not self._socket then
		self._socket = SocketTCP.new(ip, port)
		self._socket:setName("socket")
		self._socket:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self, self.onStatus))
		self._socket:addEventListener(SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
		self._socket:addEventListener(SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
		self._socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
		self._socket:addEventListener(SocketTCP.EVENT_DATA, handler(self,self.onData))
	end
	self._socket:connect(ip, port)
end

--- socket的各种状态
function SocketHandler:onStatus(event)
	-- 和服务器建立连接后立马发个登录的消息
	if event.name == SocketTCP.EVENT_CONNECTED then
		self._isConnecting = true
		logger:info("连接LUA代码热更新服务器成功")
	elseif event.name == SocketTCP.EVENT_CONNECT_FAILURE then
		self._isConnecting = false
		logger:info("链接LUA代码热更新服务器失败")
	elseif event.name == SocketTCP.EVENT_CLOSE then
		self._isConnecting = false
		logger:info('LUA代码热更新服务器关闭中')
	elseif event.name == SocketTCP.EVENT_CLOSED then
		self._isConnecting = false
		logger:info('LUA代码热更新服务器已关闭')
	end
end

--- 收到服务器传来的数据
function SocketHandler:onData(event)
	local dataList = string.split(event.data, ' ')
	for _, data in ipairs(dataList) do
		if package.loaded[data] then
			package.loaded[data] = nil
			require(data)
			logger:info(string.format("热更新lua代码:%s", data))
		end
	end
	-- 先把UI都删掉
	uiManager:getUIContainer():removeAllChildren(true)
	-- 然后当前场景也要重载一下
	local runningSceneName = display.getRunningScene().class.__cname
	local modulePath = findModulePath("app%.scenes%.%a*%." .. runningSceneName)
	package.loaded[modulePath] = nil
	require(modulePath)
	display.replaceScene(require("libra.luaUpdate.TempScene").new(modulePath))
end

return SocketHandler