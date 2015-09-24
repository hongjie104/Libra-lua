--
-- 线路选择器
-- 根据收到的两个ip，同时建立socket进行连接，哪一个socket连接最快，就选择哪一个ip
-- Author: zhouhongjie@apowo.com
-- Date: 2014-07-12 09:38:08
--

local SocketTCP = require('framework.cc.net.SocketTCP')

local LineSelecter = class('LineSelecter')

function LineSelecter:ctor(onStartToConnect)
	-- self._socket1 = SocketTCP.new(serverData[serverListKey.serverIP1], serverData[serverListKey.serverPort], false)
	self._socket1 = SocketTCP.new("77.66.77.66", 2346, false)
	self._socket1:setName("socket1")
	local handler1 = handler(self, self.onStatus1)
	self._socket1:addEventListener(SocketTCP.EVENT_CONNECTED, handler1)
	self._socket1:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler1)

	-- self._socket2 = SocketTCP.new(serverData[serverListKey.serverIP2], serverData[serverListKey.serverPort], false)
	-- self._socket2 = SocketTCP.new("222.73.208.109", 2501, false)
	-- self._socket2 = SocketTCP.new("222.73.31.231", 2222, false)
	self._socket2 = SocketTCP.new("88.0.0.128", 2222, false)
	self._socket2:setName("socket2")
	local handler2 = handler(self, self.onStatus2)
	self._socket2:addEventListener(SocketTCP.EVENT_CONNECTED, handler2)
	self._socket2:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler2)

	self._onStartToConnectHandler = onStartToConnect
end

--- socket的各种状态
function LineSelecter:onStatus1(event)
	if event.name == SocketTCP.EVENT_CONNECTED then
		self._socket1Status = 1
		if self._socket2Status ~= 1 then
			logger:info('使用', self._socket1.host, self._socket1.port, "连接")
			self._onStartToConnectHandler(self._socket1.host, self._socket1.port)
		end
		self._socket1:close()
		logger:info('socket1断开')
	elseif event.name == SocketTCP.EVENT_CONNECT_FAILURE then
		logger:info('socket1 连接失败')
		self._socket1Status = 2
		if self._socket2Status == 2 then
			logger:warn('socket1 和socket2 都连接失败了')
			self._onStartToConnectHandler()
		end
	end
end

--- socket的各种状态
function LineSelecter:onStatus2(event)
	if event.name == SocketTCP.EVENT_CONNECTED then
		self._socket2Status = 1
		if self._socket1Status ~= 1 then
			logger:info('使用', self._socket2.host, self._socket2.port, "连接")
			self._onStartToConnectHandler(self._socket2.host, self._socket2.port)
		end
		self._socket2:close()
		logger:info('socket2断开')
	elseif event.name == SocketTCP.EVENT_CONNECT_FAILURE then
		logger:info('socket2 连接失败')
		self._socket2Status = 2
		if self._socket1Status == 2 then
			logger:warn('socket1 和socket2 都连接失败了')
			self._onStartToConnectHandler()
		end
	end
end

function LineSelecter:checkBetterIP()
	-- socket状态，0：连接中，1：连接成功，2：连接失败
	self._socket1Status, self._socket2Status = 0, 0
	self._socket1:connect()
	self._socket2:connect()
	logger:info(self._socket1.host .. ':' .. self._socket1.port ..  '开始连接了')
	logger:info(self._socket2.host .. ':' .. self._socket2.port ..  '开始连接了')
end

function LineSelecter:removeSelf()
	self._socket1:removeAllEventListeners()
	self._socket2:removeAllEventListeners()
	self._socket1:close()
	self._socket2:close()
	self._socket1 = nil
	self._socket2 = nil
end

return LineSelecter