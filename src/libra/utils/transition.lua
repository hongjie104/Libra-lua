--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-07-22 11:17:00
--

function transition.jumpTo(target,args)
    assert(not tolua.isnull(target), "transition.jumpTo() - target is not cc.Node")
    local tx, ty = target:getPosition()
    local x = args.x or tx
    local y = args.y or ty
    local frequency = args.frequency or 1
    local action = cc.JumpTo:create(args.time, cc.p(x,y), args.height, frequency)
    return transition.execute(target, action, args) 
end