--
-- 玩家数据管理类
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-01 16:14:16
--

local UserManager = class("UserManager")

function UserManager:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self._account, self._password = nil, nil
	self._gender = 1
	self._age = 1
end

function UserManager:age(val)
	if val then
		self._age = val
		return self
	end
	return self._age
end

function UserManager:gender(val)
	if val then
		self._gender = val
		return self
	end
	return self._gender
end

function UserManager:password(val)
	if val then
		self._password = val
		return self
	end
	return self._password
end

function UserManager:account(val)
	if val then
		self._account = val
		return self
	end
	return self._account
end

return UserManager