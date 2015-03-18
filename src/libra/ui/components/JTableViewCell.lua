--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 17:12:51
--

local JTableViewCell = class("JTableViewCell", function ()
	return cc.TableViewCell:create()
end)

function JTableViewCell:ctor()
	display.newSprite("btnHelp_n.png"):addTo(self)
end

return JTableViewCell
