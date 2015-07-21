--
-- 四叉树
-- Author: zhouhongjie@apowo.com
-- Date: 2015-07-11 12:15:33
--

local LEFT_TOP = 1
local RIGHT_TOP = 2
local LEFT_BOTTOM = 3
local RIGHT_BOTTOM = 4

local QuadTree = class("QuadTree")

function QuadTree:ctor(rect, deep, root, position)
	self._quadList = {0, 0, 0, 0}
	-- 父节点
	self._parent = nil
	-- 起始节点
	self._root = root or self
	-- 图形范围
	self._rect = rect
	-- 数据
	self._dataList = { }
	-- 方位
	self._position = position or 0

	self:createChildren(deep)

	if not root then
		self:debug(deep)
	end
end

function QuadTree:position(val)
	if val then
		self._position = val
		return self
	end
	return self._position
end

function QuadTree:parent(val)
	if val then
		self._parent = val
		return self
	end
	return self._parent
end

--- 创建树结构
function QuadTree:createChildren(deep)
	if deep > 0 then
		deep = deep - 1
		local w = self._rect.width / 2
		local h = self._rect.height / 2
		
		self._quadList[1] = QuadTree.new({x = self._rect.x + w, y = self._rect.y, width = w, height = h}, deep, self._root, RIGHT_BOTTOM):parent(self)
		self._quadList[2] = QuadTree.new({x = self._rect.x + w, y = self._rect.y + h, width = w, height = h}, deep, self._root, RIGHT_TOP):parent(self)
		self._quadList[3] = QuadTree.new({x = self._rect.x, y = self._rect.y + h, width = w, height = h}, deep, self._root, LEFT_TOP):parent(self)
		self._quadList[4] = QuadTree.new({x = self._rect.x, y = self._rect.y, width = w, height = h}, deep, self._root, LEFT_BOTTOM):parent(self)
	end
end

--- 是否有子树
function QuadTree:hasChildren()
	for i, v in ipairs(self._quadList) do
		if v == 0 then
			return false
		end
	end
	return true
end

function QuadTree:getChild(position)
	for i, v in ipairs(self._quadList) do
		if v ~= 0 then
			if v:position() == position then
				return v
			end
		end
	end
end

--- 判断坐标是否在界限内
function QuadTree:isIn(x, y)
	return cc.rectContainsPoint(self._rect, {x = x, y = y})
end

function QuadTree:getDataList()
	return self._dataList
end

--- 添加一个数据
function QuadTree:addData(data, x, y)
	if self:isIn(x, y) then
		if self:hasChildren() then
			local quadTree = nil
			for i, v in ipairs(self._quadList) do
				quadTree = v:addData(data, x, y)
				if quadTree then
					return quadTree
				end
			end
		else
			self._dataList[#self._dataList + 1] = data
			return self
		end
	end
end

--- 删除一个数据
function QuadTree:removeData(data, x, y)
	if self:isIn(x, y) then
		if self:hasChildren() then
			local quadTree = nil
			for i, v in ipairs(self._quadList) do
				quadTree = v:removeData(data, x, y)
				if quadTree then
					return quadTree
				end
			end
		else
			if table.removeByValue(self._dataList, data) ~= 0 then
				return self
			end
		end
	end
end

--- 检测是否还在当前区间内，并返回新的区间
function QuadTree:reinsert(data, x, y)
	if self:isIn(x, y) then
		return self
	else
		local quadTree = self._root:addData(data, x, y)
		if quadTree then
			self:removeData(data, x, y)
			return quadTree
		end
	end
end

function QuadTree:getDataInRect(rect)
	if not cc.rectIntersectsRect(rect, self._rect) then
		return {}
	end
	local result = {}
	table.insertto(result, self._dataList)

	if self:hasChildren() then
		for i, v in ipairs(self._quadList) do
			table.insertto(result, v:getDataInRect(rect))	
		end
	end
	return result
end

function QuadTree:getQuadTreeWithData(data)
	for i, v in ipairs(self._dataList) do
		if v == data then
			return self
		end
	end
	local tree = nil
	for i, v in ipairs(self._quadList) do
		if v ~= 0 then
			tree = v:getQuadTreeWithData(data)
			if tree then
				return tree
			end
		end
	end
end

-- function QuadTree:getDataFrom(sourceData, direction)
-- 	local sourceQuadTree = self:getQuadTreeWithData(sourceData)
-- 	if sourceQuadTree then
-- 		local targetData, parent, targetQuadTree = nil, nil, nil
-- 		if Direction.LEFT_TO_RIGHT == direction then
-- 			if sourceQuadTree:position() == LEFT_TOP then
-- 				parent = sourceQuadTree:parent()
-- 				while parent do
-- 					targetQuadTree = parent:getChild(RIGHT_TOP)
-- 					if targetQuadTree then
-- 						local dataList = targetQuadTree:getDataList()
-- 						if #dataList > 0 then
-- 							targetData = dataList[1]
-- 							return targetData
-- 						end
-- 					end
-- 				end
-- 			end
-- 		elseif Direction.RIGHT_TO_LEFT == direction then
-- 		elseif Direction.TOP_TO_BOTTOM == direction then
-- 		elseif Direction.BOTTOM_TO_TOP == direction then
-- 		end
-- 	end
-- end

function QuadTree:debug(deep)
	local lineBorder = {borderColor = cc.c4f(1.0, 0.0, 0.0, 1.0)}

	local uiContainer = uiManager:getUIContainer()
	-- 水平或者垂直方向上的线条数量
	-- 2的deep次方减1
	local nums = math.ldexp(1, deep) - 1
	-- 先画水平的线
	local gap = checkint(display.height / (nums + 1))
	local x, y = 0, gap
	for i = 1, nums do
		display.newLine({{x, y}, {display.width, y}}, lineBorder):addTo(uiContainer, 999)
		y = y + gap
	end
	-- 再画垂直的线
	gap = checkint(display.width / (nums + 1))
	x, y = gap, 0
	for i = 1, nums do
		display.newLine({{x, y}, {x, display.height}}, lineBorder):addTo(uiContainer, 999)
		x = x + gap
	end
end

return QuadTree