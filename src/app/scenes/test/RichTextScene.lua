--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-06-28 19:07:08
--

local RichTextScene = class("RichTextScene", function ()
	return display.newScene("RichTextScene")
end)

function RichTextScene:ctor()
	local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(cc.size(200, 100))
 
    local re1 = ccui.RichElementText:create( 1, cc.c3b(255, 255, 255), 255, "我是白色" , "Arial", 24)
    local re2 = ccui.RichElementText:create( 2, cc.c3b(255, 255,   0), 255, "这个是黄色的" , "Arial", 10 )
    local re3 = ccui.RichElementText:create( 3, cc.c3b(0,   0, 255), 255, "再看看蓝色的" , "Arial", 24 )
    local re4 = ccui.RichElementText:create( 4, cc.c3b(0, 255,   0), 255, "还有绿色" , "Arial", 10 )
    local re5 = ccui.RichElementText:create( 5, cc.c3b(255,  0,   0), 255, "最后是红色的" , "Arial", 10 )
 
    -- local reimg = ccui.RichElementImage:create( 6, cc.c3b(255, 255, 255), 255, cocosui/sliderballnormal.png )
 
    -- 添加ArmatureFileInfo, 由ArmatureDataManager管理
    -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo( cocosui/100/100.ExportJson )
    -- local arr = ccs.Armature:create( 100 )
    -- arr:getAnimation():play( Animation1 )
 
    -- local recustom = ccui.RichElementCustomNode:create( 1, cc.c3b(255, 255, 255), 255, arr )
    -- local re6 = ccui.RichElementText:create( 7, cc.c3b(255, 127,   0), 255, "Have fun!!" , "Arial", 10 )
    richText:pushBackElement(re1)
    richText:insertElement(re2, 1)
    richText:pushBackElement(re3)
    richText:pushBackElement(re4)
    richText:pushBackElement(re5)
    -- richText:insertElement(reimg, 2)
    -- richText:pushBackElement(recustom)
    -- richText:pushBackElement(re6)
 
    richText:addTo(self):pos(display.cx, display.cy)
end

return RichTextScene