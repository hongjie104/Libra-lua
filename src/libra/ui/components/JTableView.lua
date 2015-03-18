--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-18 16:30:16
--

local JTableViewCell = import(".JTableViewCell")

local JTableView = class("JTableView", function (size)
	return cc.TableView:create(size)
end)

function JTableView:ctor(size)
	makeUIComponent(self)

	self:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    self:registerScriptHandler(handler(self, self.onCellSizeForTable), cc.Handler.TABLECELL_SIZE_FOR_INDEX)
    self:registerScriptHandler(handler(self, self.onTableCellAtIndex), cc.Handler.TABLECELL_AT_INDEX)
    self:registerScriptHandler(handler(self, self.onNumberOfCellsInTableView), cc.Handler.TABLEVIEW_NUMS_OF_CELLS)
    self:registerScriptHandler(handler(self, self.onTableCellTouched), cc.Handler.TABLECELL_TOUCHED)

    self:reloadData()

    self:addChild(display.newSprite("imgIcoBg30.png"))
end

function JTableView:onCellSizeForTable(t, t1)
	dump(t)
	dump(t1)
    return 120, 60
end

function JTableView:onTableCellAtIndex(t, t1)
	dump(t)
	dump(t1)
	local cell = self:dequeueCell()
    if cell == nil then
        -- C++的index是从0开始的，所以加1
        cell = JTableViewCell.new()
        -- self._tableCellList[#self._tableCellList + 1] = cell
    -- else
        -- cell:setText(self._indexList[idx + 1])
        -- cell:setSelected(idx + 1 == self._selectedIndex)
    end
    return cell
end

function JTableView:onNumberOfCellsInTableView(t)
	dump(t)
	return 100
end

function JTableView:onTableCellTouched(t, t1)
	dump(t)
	dump(t1)
end

--[[
function ServerIndexContainer:cellSizeForTable(table, idx)
    return 60, 60
end

function ServerIndexContainer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
        -- C++的index是从0开始的，所以加1
        cell = IndexCell.new(self._indexList[idx + 1])
        self._tableCellList[#self._tableCellList + 1] = cell
    else
        cell:setText(self._indexList[idx + 1])
        cell:setSelected(idx + 1 == self._selectedIndex)
    end
    return cell
end

function ServerIndexContainer:numberOfCellsInTableView()
   return #self._indexList
end

function ServerIndexContainer:tableCellTouched(table, cell)
    self:setSelectedIndex(cell:getIdx() + 1)
end
]]

return JTableView