--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-07-11 22:21:26
--

local Cell = class("Cell")

function Cell:ctor(rect)
	-- 图形范围
	self._rect = rect
	-- 数据
	self._dataList = { }
end

--- 判断坐标是否在界限内
function Cell:isIn(x, y)
	return cc.rectContainsPoint(self._rect, {x = x, y = y})
end

function Cell:addData(data)
	self._dataList[#self._dataList + 1] = data
end

function Cell:clearData()
	self._dataList = { }
end

function Cell:hasData(data)
	for i, v in ipairs(self._dataList) do
		if v == data then
			return true
		end
	end
end

function Cell:getData()
	return self._dataList
end

--================================================================

local Grid = class("Grid")

function Grid:ctor(container, deep, showGrid)
	self._cellList = { }
	
	self._nums = deep
	local cellWidth, cellHeight = checkint(container:actualWidth() / self._nums), checkint(container:actualHeight() / self._nums)
	local x, y = 0, container:actualHeight() - cellHeight
	for row = 1, self._nums do
		self._cellList[row] = { }
		for col = 1, self._nums do
			self._cellList[row][col] = Cell.new({x = x, y = y, width = cellWidth, height = cellHeight})
			x = x + cellWidth
		end
		x, y = 0, y - cellHeight
	end

	if showGrid then
		self:showGrid(container, deep)
	end
end

function Grid:addData(data, x, y)
	for row, colList in ipairs(self._cellList) do
		for col, cell in ipairs(colList) do
			if cell:isIn(x, y) then
				cell:addData(data)
				return self
			end
		end
	end
end

function Grid:clearData()
	for row, colList in ipairs(self._cellList) do
		for col, cell in ipairs(colList) do
			cell:clearData()
		end
	end
end

function Grid:getCellIndexByData(data)
	for row, colList in ipairs(self._cellList) do
		for col, cell in ipairs(colList) do
			if cell:hasData(data) then
				return row, col
			end
		end
	end
end

function Grid:getDataFrom(sourceData, direction)
	local startRow, startCol = self:getCellIndexByData(sourceData)
	if startRow and startCol then
		local dataList = nil
		if Direction.LEFT_TO_RIGHT == direction or Direction.RIGHT_TO_LEFT == direction then
			-- 根据左右方向处理一下for循环的一些值
			local endCol, colGap = 1, 1
			if Direction.RIGHT_TO_LEFT == direction then
				startCol = startCol - 1
				endCol = 1
				colGap = -1
			else
				startCol = startCol + 1
				endCol = self._nums
				colGap = 1
			end

			local row = startRow
			local gap, count = -1, 0
			for col = startCol, endCol, colGap do
				-- 获取同一行左边或者右边的格子数据
				row = startRow
				dataList = self._cellList[row][col]:getData()
				gap, count = -1, 0
				-- 如果没有数据，那么以当前行为中心向上下两个方向进行获取数据
				while #dataList == 0 and count < self._nums do
					count = count + 1
					row = startRow + gap
					if gap < 0 then
						gap = -gap
					else
						gap = -gap - 1
					end
					if row > 0 and row <= self._nums then
						dataList = self._cellList[row][col]:getData()
					end
				end
				if #dataList > 0 then
					return dataList
				end
			end
		elseif Direction.TOP_TO_BOTTOM == direction or Direction.BOTTOM_TO_TOP == direction then
			-- 根据上下方向处理一下for循环的一些值
			local endRow, rowGap = 1, 1
			if Direction.BOTTOM_TO_TOP == direction then
				startRow = startRow - 1
				endRow = 1
				rowGap = -1
			else
				startRow = startRow + 1
				endRow = self._nums
				rowGap = 1
			end

			local col = startCol
			local gap, count = -1, 0
			for row = startRow, endRow, rowGap do
				-- 获取同一列上边或者下边的格子数据
				col = startCol
				dataList = self._cellList[row][col]:getData()
				gap, count = -1, 0
				-- 如果没有数据，那么以当前列为中心向左右两个方向进行获取数据
				while #dataList == 0 and count < self._nums do
					count = count + 1
					col = startCol + gap
					if gap < 0 then
						gap = -gap
					else
						gap = -gap - 1
					end
					if col > 0 and col <= self._nums then
						dataList = self._cellList[row][col]:getData()
					end
				end
				if #dataList > 0 then
					return dataList
				end
			end
		end
	end
end

function Grid:showGrid(container, deep)
	local containerWidth, containerHeight = container:actualWidth(), container:actualHeight()
	local lineBorder = {borderColor = cc.c4f(1.0, 1.0, 0.0, 1.0), borderWidth = 2}
	-- 水平或者垂直方向上的线条数量
	local nums = deep - 1
	-- 先画水平的线
	local gap = checkint(containerHeight / (nums + 1))
	local x, y = 0, gap
	for i = 1, nums do
		display.newLine({{x, y}, {containerWidth, y}}, lineBorder):addTo(container, 999)
		y = y + gap
	end
	-- 再画垂直的线
	gap = checkint(containerWidth / (nums + 1))
	x, y = gap, 0
	for i = 1, nums do
		display.newLine({{x, y}, {x, containerHeight}}, lineBorder):addTo(container, 999)
		x = x + gap
	end
end


return Grid