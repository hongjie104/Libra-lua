--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-24 13:15:28
--

local scheduler = require("framework.scheduler")
local SocketTCP = require('framework.cc.net.SocketTCP')
local LineSelecter = import('.LineSelecter')

local function getBaseByteArray()
	local utils = require("framework.cc.utils.init")
	return utils.ByteArray.new(utils.ByteArray.ENDIAN_LITTLE)
end

local SocketHandler = class("SocketHandler")

function SocketHandler:ctor()
	self:init()
	self._length = 0
	self._opCodeHandler = {}
	-- 每次发送的数据量，控制数据量是为了防止pack的时候出错
	self._sendLengthAtOnce = 4000

	-- 消息发送的一个缓存池子，发送时会将发送的内容放在映射中，等服务器返回对应消息结果，再把该条消息从映射中删除
	self._msgPoolMap = { }

	-- 导入谷歌协议Protobuf
	require('libra.net.socket.protobuf')
	-- 注册协议
	self:registerPB()

	-- 网络连接是否连上了
	self._isConnecting = false
	-- 重连的次数
	self._reconnectCount = 0

	-- 当前发送消息协议的索引值
	-- 每个消息里都包含这个索引值
	-- 当收到服务器返回相同索引值时说明消息发送成功
	-- 此时索引值自增1
	self._protoIndex = 1

	self._protoPackage = "PS.ProtoBuf."

	-- by zxf
	-- self:registerOpCodeHandler(10, self.onReconnect)
	-- self:registerOpCodeHandler(11, self.onCommandResult)
	self:registerOpCodeHandler(10001, self.onReconnect)
	self:registerOpCodeHandler(10002, self.onCommandResult)
end

--- 注册协议文件，这样谷歌协议才能被解析
function SocketHandler:registerPB()
	local pbPath = "res/sound/bg.mp3"
	if device.platform == 'android' then
		pbPath = cc.FileUtils:getInstance():fullPathForFilename('sound/bg.mp3')
	end
	
	if device.platform == "windows" or cc.FileUtils:getInstance():isFileExist(pbPath) then
		protobuf.register(cc.HelperFunc:getFileData(pbPath))
	else
		logger:error("找不到协议:", pbPath)
	end
end

-- @private
function SocketHandler:init()
	self._buf = getBaseByteArray()
end

--- 解析协议
function SocketHandler:decode(pbName, msg)
	return protobuf.decode(self._protoPackage .. pbName, msg)
end

--- 加密协议
function SocketHandler:encode(opName, param)
	return protobuf.encode(opName, param)
end

--- 清除协议缓存。消息A有可选参数，当第一次收到消息A时，参数内容将会缓存起来，
--- 当再次收到消息A时，假如其中的可选参数是空，那么将会以上一次的值进行赋值。
--- 所以需要清空缓存，以保证每次收到消息A时，参数都是实时的
function SocketHandler:clearDefaultCache(pbName)
	return protobuf.clearDefaultCache(self._protoPackage .. pbName)
end

--- 建立连接,该方法只在登录界面中的登录按钮事件中响应
-- @param account 登录账号
-- @param password 登录密码
function SocketHandler:startConnect(account, password)
	self._account = account
	self._password = password
	-- 不知道还要不要这个参数，先给个默认值1
	self._serverID = 1
	self._reconnectCount = 0
	if self._lineSelecter then
		self._lineSelecter:removeSelf()
	end
	self._lineSelecter = LineSelecter.new(handler(self, self.onStartToConnect))
	self:checkBetterIP()
end

function SocketHandler:onStartToConnect(ip, port)
	if ip and port then
		if not self._socket then
			self._socket = SocketTCP.new(ip, port)
			self._socket:setName("socket")
			-- 新连接或者连接另外服务器，重置重连计数
			self._reconnectCount = 0
			self._socket:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self, self.onStatus))
			self._socket:addEventListener(SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
			self._socket:addEventListener(SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
			self._socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
			self._socket:addEventListener(SocketTCP.EVENT_DATA, handler(self,self.onData))
		end

		-- 此时已经连接但是由于某些原因没有登录成功，使用已有连接重试
		if self._socket.isConnected then
			-- 不是断线重连
			self._reconnectCount = 0
			self._isConnecting = true
			self:sendLoginMsg()
		else
			self._socket:connect(ip, port)
		end
	else
		logger:warn('两个ip都无法连接。。。')
		self._isReconnecting = false
		self:reconnect()
	end
end

--- socket的各种状态
function SocketHandler:onStatus(event)
	-- 和服务器建立连接后立马发个登录的消息
	if event.name == SocketTCP.EVENT_CONNECTED then
		self._isConnecting = true
		self:sendLoginMsg()
	elseif event.name == SocketTCP.EVENT_CONNECT_FAILURE then
		self._isConnecting = false
		if self._isReconnecting then
			self._isReconnecting = false
			self:reconnect()
		end
		logger:info('网络连接失败')
		-- newUIManager:closeLoading()
		-- newUIManager:showMsgPanel(_('网络连接失败'))
	elseif event.name == SocketTCP.EVENT_CLOSE then
		self._isConnecting = false
		self._isReconnecting = false
		logger:info('网络连接关闭中')
	elseif event.name == SocketTCP.EVENT_CLOSED then
		self._isConnecting = false
		self._isReconnecting = false
		logger:info('网络连接已关闭')
		-- newUIManager:closeLoading()
		-- newUIManager:showMsgPanel(_('网络已断开'))
	end
end

--- 发送登录消息
function SocketHandler:sendLoginMsg()	
	local isVisitorStr = self._isVisitor and "True" or "False"
	-- 发送登录消息给服务器
	-- 登录的消息使用的是json格式的string,这是历史原因造成的,就这样吧
	local loginStr = string.format("{\"Command\":\"Login\",\"Account\":\"%s\",\"Password\":\"%s\",\"ServerID\":\"%d\",\"Platform\":\"%s\",\"Device\":\"%s\",\"Reconnect\":\"%d\",\"IsVisitor\":\"%s\"}", 
			self._account, self._password, self._serverID, "apowo", device.getOpenUDID(), self._reconnectCount, "False")
	logger:info('发送登录消息:', loginStr)
	self._reconnectCount = self._reconnectCount + 1
	loginStr = crypto.encodeBase64(loginStr .. "\n")
	local pack = string.pack("<A", loginStr)
	self._socket:send(pack)
end

function SocketHandler:checkBetterIP()
	if self._lineSelecter then
		self._lineSelecter:checkBetterIP()
	end
end

--- 收到服务器传来的数据
function SocketHandler:onData(event)
	local byteString = event.data
	self:appendData(byteString)
	-- print("self._buf:getAvailable()", self._buf:getAvailable(), " pos: " , self._buf:getPos(), " len: " , self._buf: getLen())
	repeat
		-- 如果当前包长等于0，说明上个包已经读完，重新获得新包的长度
		if self._length == 0 then
			if self._buf:getAvailable() < 8 then
				logger:info("那啥，长度不够8，break了,长度为：", self._buf:getAvailable())
				break
			else
				self._length = self._buf:readInt()
				self:discardCurrentMsg(false)
				-- print("package length: " .. self._length)
			end
			-- logger:info("self._length: " .. self._length .. " available: " .. self._buf:getAvailable())
		end
		-- 如果包长小于缓冲区可读数据长度，说明包数据还没完全发过来，等发过来再继续读。
		if self._length > self._buf:getAvailable() then
			-- logger:info("break: self._length: " .. self._length)
			break
		end
		self:processData()
		self:discardCurrentMsg(true)
	until self._buf:getAvailable() < 8
end

function SocketHandler:appendData(byteString)
	local pos = self._buf:getPos()
	local l = self._buf:getLen()
	self._buf:setPos(self._buf:getLen() + 1)
	self._buf:writeBuf(byteString)
	self._buf:setPos(pos)
	local str = ''
	for i = l + 1, self._buf:getLen() do
		str = str .. string.byte(self._buf._buf[i]) .. " "
	end
	logger:info("收到的消息长度:", self._buf:getLen() - l, "内容:", str)
end

function SocketHandler:discardCurrentMsg(resetLength) 
	--logger:info("discarding processed message, resetLength: " .. tostring(resetLength))
	local pos = self._buf:getPos()
	if pos > 1000 then -- 只在缓存超过1KB才重新清理
		local remainingLength = self._buf:getAvailable()
		local remainingMsg = self._buf:readString(remainingLength)
		self:init()
		self._buf:writeBuf(remainingMsg)
		self._buf:setPos(1)
	end

	if resetLength then
		self._length = 0
	end
end

function SocketHandler:processData()
	local str = ''
	for i = self._buf:getPos(), self._buf:getPos() + self._length - 1 do
		str = str .. string.byte(self._buf._buf[i]) .. " "
	end
	logger:info("开始处理的消息长度:", self._length, "内容:", str)

	local opCode = self._buf:readInt()
	local msg = self._buf:readStringBytes(self._length - 4)
	local handlerList = self._opCodeHandler[opCode]
	if handlerList ~= nil then
		logger:info('开始解析谷歌协议:', self:getProtoBufLabel(opCode), "opCode = ", opCode)
		for i, v in ipairs(handlerList) do
			v(self, msg)
		end
	else
		logger:warn('没有解析的谷歌协议:', self:getProtoBufLabel(opCode), "opCode = ", opCode)
	end
end

function SocketHandler:send(opCode, opName, param, isReconnetSend, protoIndex)
	if isReconnetSend == nil then isReconnetSend = false end
	self._protoIndex = protoIndex or self._protoIndex
	if not isReconnetSend then
		-- 12是flush，不放进_msgPoolMap
		if opCode ~= 12 then
			self._msgPoolMap[self._protoIndex] = {opName = opName, opCode = opCode, param = param}
		end
	end
	if opName then
		opName = self._protoPackage .. opName
	end
	if self._isConnecting then
		local stringbuffer, stringLength = nil, 0
		if opName then
			logger:info('发送谷歌协议:' .. opName, '协议:', self:getProtoBufLabel(opCode), 'opCode = ', opCode, 'self._protoIndex = ' .. self._protoIndex)
			stringbuffer = protobuf.encode(opName, param)
			stringLength = #stringbuffer
			-- logger:info('协议长度:', stringLength)
		else
			logger:info('发送谷歌协议:' , self:getProtoBufLabel(opCode), "opCode = ", opCode, 'self._protoIndex = ' .. self._protoIndex)
		end

		-- 记录一下上下文消息，供收到错误消息时上报
		-- self._lastSentOp = opName
		-- self._lastSentOpCode = opCode
		-- self._lastSentParam = param

		local ba = getBaseByteArray()
		-- 1000000是告诉服务器，发的是谷歌协议
		ba:writeInt(1000000)
		ba:writeInt(stringLength + 8)
		ba:writeInt(opCode)
		ba:writeInt(self._protoIndex)
		if stringbuffer then
			-- 每次只发self._sendLengthAtOnce长度的数据
			if stringLength > self._sendLengthAtOnce then
				ba:writeStringBytes(string.sub(stringbuffer, 1, self._sendLengthAtOnce))
				self._leftStringBuff = string.sub(stringbuffer, self._sendLengthAtOnce + 1)
			else
				ba:writeStringBytes(stringbuffer)
			end
		end
		self._socket:send(ba:getPack())
		-- 再发送剩下的数据
		self:sendLeft()

		-- 12是flush，就不自增了
		if opCode ~= 12 then
			self._protoIndex = self._protoIndex + 1
		end
		if not isReconnetSend then
			-- 显示loading
			if self._showLoadingHandler then scheduler.unscheduleGlobal(self._showLoadingHandler) self._showLoadingHandler = nil end
			if device.platform ~= "windows" then
				self._showLoadingHandler = scheduler.performWithDelayGlobal(function ()
					-- 3秒后没有收到消息，就发个消息给服务器flush一下，同时显示一个loading
					-- loading过程中还没有收到服务器发来的消息，就重连,收到消息了，loading消失
					-- if self._isConnecting then
					-- 	-- 发个flush协议给服务器
					-- 	-- self._socket:send("IDMessage", 12, {id = 0})
					-- end
					-- newUIManager:showLoading(function ()
					-- 	if self._isConnecting then -- 这个是延迟运行的，可能状态已经变化，加入检查
					-- 		self:disconnect()
					-- 		-- 自动重连
					-- 		self:reconnect()
					-- 	end
					-- end, 2)
				end, 2)
			end
		end
	else
		-- 自动重连
		self:reconnect()
	end
end

--- @private
function SocketHandler:sendLeft()
	if self._leftStringBuff then
		logger:info('发送剩下的数据,长度:', #self._leftStringBuff)
		local ba = getBaseByteArray()
		if #self._leftStringBuff > self._sendLengthAtOnce then
			ba:writeStringBytes(string.sub(self._leftStringBuff, 1, self._sendLengthAtOnce))
			self._leftStringBuff = string.sub(self._leftStringBuff, self._sendLengthAtOnce + 1)
		else
			ba:writeStringBytes(self._leftStringBuff)
			self._leftStringBuff = nil
		end
		self._socket:send(ba:getPack())
		self:sendLeft()
	end
end

--- 发送JSON格式的协议,一般用在GM命令上
function SocketHandler:sendJson(command, paramTable)
	if self._isConnecting then
		local paramStr = nil
		for k, v in pairs(paramTable) do
			if paramStr then
				paramStr = string.format("%s,%s", paramStr, v)
			else
				paramStr = v
			end
		end
		
		local str = string.format("{\"Cmd\":\"%s\",\"Par\":[%s]}", command, paramStr)
		str = crypto.encodeBase64(str .. "\n")
		self._socket:send(string.pack("<A", str))
		logger:info('发送Json命令', command, '参数:', paramStr)
	else
		logger:warn("连接断开，发送" .. command .. "失败")
	end
end

--- 重连
function SocketHandler:reconnect()
	if self._isReconnecting ~= true then
		-- newUIManager:closeLoading()
		-- newUIManager:showAlert(_("当前网络不佳,是否尝试重新连接服务器?"), true, 
		-- 	function ()
		-- 		newUIManager:showLoading()
		-- 		self:init()
		-- 		self._length = 0
		-- 		self._isReconnecting = true
		-- 		self:checkBetterIP()
		-- 	end, function ()
		-- 		socket:disconnect()
		-- 		replaceScene(require("app.scenes.login.LoginScene").new())
		-- 	end, _('重新连接'), _('返回登录'),
		-- 	nil,
		-- 	true
		-- )
	end
end

--- 主动断开
function SocketHandler:disconnect()
	if self._socket then
		if self._isConnecting then
			self._socket:disconnect()
			-- self._socket:close()
		end
	end
end

function SocketHandler:registerOpCodeHandler(opCode, handler)
	local handlerList = self._opCodeHandler[opCode]
	if handlerList == nil then
		handlerList = {}
		self._opCodeHandler[opCode] = handlerList
	end
	handlerList[#handlerList + 1] = handler
end

--- 取消注册 
function SocketHandler:unRegisterOpCodeHandler(opCode, handler)
	local handlerList = self._opCodeHandler[opCode]
	if handlerList then
		for i, v in ipairs(handlerList) do
			if v == handler then
				handlerList[i] = nil
				return
			end
		end
	end
end

--- 重连成功了，判断下断线之前是否有未发送成功的协议，有的话，就再发一次
function SocketHandler:onReconnect()
	-- newUIManager:closeLoading()
	self._isReconnecting = false

	local keyList = { }
	for i in pairs(self._msgPoolMap) do
		table.insert(keyList, i)
	end
	table.sort(keyList, function(v1, v2) return v1 < v2 end)
	for i, v in ipairs(keyList) do
		socket:send(self._msgPoolMap[v].opName, self._msgPoolMap[v].opCode, self._msgPoolMap[v].param, true)
	end
end

function SocketHandler:onCommandResult(msg)
	if self._showLoadingHandler then scheduler.unscheduleGlobal(self._showLoadingHandler) self._showLoadingHandler = nil --[[newUIManager:closeLoading()]] end
	local result = socketHandler:decode("CommandResult", msg)
	socketHandler._msgPoolMap[result.id] = nil
	logger:info("索引值:", result.id, '的消息已处理完毕')
	-- self._lastCommandIndex = result.id
end

--- 获取协议号对应的协议名称字符串
function SocketHandler:getProtoBufLabel(opCode)
	if protoBufLabel and type(protoBufLabel) == "table" then
		return protoBufLabel[opCode]
	end
end

return SocketHandler