--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-07-01 15:58:19
--

local Box2DScene = class("Box2DScene", function ()
	return display.newScene("Box2DScene")
end)

function Box2DScene:ctor()
	self.world = CCPhysicsWorld:create(0, GRAVITY)

	-- add world to scene
	self:addChild(self.world)
end

return Box2DScene