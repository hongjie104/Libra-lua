--
-- 测试cocostudio动画
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-27 07:36:37
--

local CCSScene = class("CCSScene", function()
	return display.newScene("CCSScene")
end)

function CCSScene:ctor()

	local function animationEvent(armatureBack, movementType, movementID)
		logger:info("movementType", movementType)
		logger:info("movementID", movementID)
		-- if movementType == ccs.MovementEventType.loopComplete then
		-- if movementID == "Fire" then
		-- local actionToRight = cc.MoveTo:create(2, cc.p(display.right - 50, display.cy))
		-- armatureBack:stopAllActions()
		-- armatureBack:runAction(cc.Sequence:create(actionToRight,cc.CallFunc:create(callback1)))
		-- armatureBack:getAnimation():play("Walk")
		-- elseif movementID == "FireMax" then
		-- local actionToLeft = cc.MoveTo:create(2, cc.p(display.left + 50, display.cy))
		-- armatureBack:stopAllActions()
		-- armatureBack:runAction(cc.Sequence:create(actionToLeft, cc.CallFunc:create(callback2)))
		-- armatureBack:getAnimation():play("Walk")
		-- end
		-- end
	end

	local function onFrameEvent(bone,evt,originFrameIndex,currentFrameIndex)
		logger:info("bone", bone)
		logger:info("evt", evt)
		logger:info("originFrameIndex", originFrameIndex)
		logger:info("currentFrameIndex", currentFrameIndex)
		-- if (not gridNode:getActionByTag(frameEventActionTag)) or (not gridNode:getActionByTag(frameEventActionTag):isDone()) then
		-- gridNode:stopAllActions()

		-- local action =  cc.ShatteredTiles3D:create(0.2, cc.size(16,12), 5, false)
		-- action:setTag(frameEventActionTag)
		-- gridNode:runAction(action)
		-- end
	end

	local function dataLoaded(percent)
		if percent >= 1 then
			local armature = ccs.Armature:create("tansuo024")
			armature:getAnimation():play("tansuo024_1")
			armature:addTo(self):pos(display.cx, display.cy)

			armature:getAnimation():setMovementEventCallFunc(animationEvent)
			armature:getAnimation():setFrameEventCallFunc(onFrameEvent)
		end
	end

	ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync("animation/tansuo024.ExportJson", dataLoaded)
end

function CCSScene:onEnter()
	sceneOnEnter(self)
end

function CCSScene:onExit()
	sceneOnExit(self)
end

function CCSScene:onEnterTransitionFinish()
	sceneOnEnterTransitionFinish(self)
end

return CCSScene
