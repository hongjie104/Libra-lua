--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-09-16 21:09:46
--

require("app.scenes.battle.MAP")

TILE_WIDTH       = TILE_WIDTH or 64
TILE_HEIGHT      = TILE_HEIGHT or 64
-- TILE_HALF_WIDTH  = TILE_WIDTH / 2
-- TILE_HALF_HEIGHT = TILE_HEIGHT / 2
TILE_OFFSET      = TILE_OFFSET or {x = display.cx, y = display.cy}

function getPositionByRowAndCol(row, col)
	return TILE_OFFSET.x + (col - 1) * TILE_WIDTH, TILE_OFFSET.y - (row - 1) * TILE_HEIGHT
end

function getRowAndColByPosition(x, y)
	x, y = x - TILE_OFFSET.x, TILE_OFFSET.y - y
	return checkint(y / TILE_HEIGHT) + 1, checkint(x / TILE_HEIGHT) + 1
end

function isTileCanMove(tileVal)
	return tileVal == MAP_VAL.NULL
end

function isCanMove(startX, startY, dir)
	local maxRow, maxCol = #MAP, #MAP[1]
	local row, col = getRowAndColByPosition(startX, startY)
	local targetX, targetY = getPositionByRowAndCol(row, col)
	local tmpDir = -1
	if dir == Direction.RIGHT_TO_LEFT then
		if startX > targetX then
			return true, targetX, targetY, tmpDir
		end
		if col <= 1 then return false, startX, startY, tmpDir end
		col = col - 1
		if isTileCanMove(MAP[row][col]) then
			if startY > targetY and not isTileCanMove(MAP[row - 1][col]) then
				-- 先往下走到格子中间，然后再往左走
				return true, targetX, targetY, Direction.TOP_TO_BOTTOM
			elseif startY < targetY and not isTileCanMove(MAP[row + 1][col]) then
				-- 先往上走到格子中间，然后再往左走
				return true, targetX, targetY, Direction.BOTTOM_TO_TOP
			end
		else
			if targetY > startY then
				-- 先向下走，然后再往左走
				if isTileCanMove(MAP[row + 1][col + 1]) and isTileCanMove(MAP[row + 1][col]) then
					row, col = row + 1, col + 1
					tmpDir = Direction.TOP_TO_BOTTOM
				else
					return false, startX, startY, tmpDir
				end
			elseif targetY < startY then
				-- 先向上走，然后再往左走
				if isTileCanMove(MAP[row - 1][col + 1]) and isTileCanMove(MAP[row - 1][col]) then
					row, col = row - 1, col + 1
					tmpDir = Direction.BOTTOM_TO_TOP
				else
					return false, startX, startY, tmpDir
				end
			else
				return false, startX, startY, tmpDir
			end
		end
	elseif dir ==  Direction.LEFT_TO_RIGHT then
		if startX < targetX then
			return true, targetX, targetY, tmpDir
		end
		if col >= maxCol then return false, startX, startY, tmpDir end
		col = col + 1
		if isTileCanMove(MAP[row][col]) then
			if startY > targetY and not isTileCanMove(MAP[row - 1][col]) then
				-- 先往下走到格子中间，然后再往右走
				return true, targetX, targetY, Direction.TOP_TO_BOTTOM
			elseif startY < targetY and not isTileCanMove(MAP[row + 1][col]) then
				-- 先往上走到格子中间，然后再往右走
				return true, targetX, targetY, Direction.BOTTOM_TO_TOP
			end
		else
			if targetY > startY then
				-- 先向下走，然后再往右走
				if isTileCanMove(MAP[row + 1][col - 1]) and isTileCanMove(MAP[row + 1][col]) then
					row, col = row + 1, col - 1
					tmpDir = Direction.TOP_TO_BOTTOM
				else
					return false, startX, startY, tmpDir
				end
			elseif targetY < startY then
				-- 先向上走，然后再往右走
				if isTileCanMove(MAP[row - 1][col - 1]) and isTileCanMove(MAP[row - 1][col]) then
					row, col = row - 1, col - 1
					tmpDir = Direction.BOTTOM_TO_TOP
				else
					return false, startX, startY, tmpDir
				end
			else
				return false, startX, startY, tmpDir
			end
		end
	elseif dir ==  Direction.BOTTOM_TO_TOP then
		if startY < targetY then
			return true, targetX, targetY, tmpDir
		end
		if row <= 1 then return false, startX, startY, tmpDir end
		row = row - 1
		if isTileCanMove(MAP[row][col]) then
			if startX > targetX and not isTileCanMove(MAP[row][col + 1]) then
				-- 先往左走到格子中间，然后再往上走
				return true, targetX, targetY, Direction.RIGHT_TO_LEFT
			elseif startX < targetX and not isTileCanMove(MAP[row][col - 1]) then
				-- 先往右走到格子中间，然后再往上走
				return true, targetX, targetY, Direction.LEFT_TO_RIGHT
			end
		else
			if targetX > startX then
				-- 先向左走，然后再往上走
				if isTileCanMove(MAP[row + 1][col - 1]) and isTileCanMove(MAP[row][col - 1]) then
					row, col = row + 1, col - 1
					tmpDir = Direction.RIGHT_TO_LEFT
				else
					return false, startX, startY, tmpDir
				end
			elseif targetX < startX then
				-- 先向右走，然后再往上走
				if isTileCanMove(MAP[row + 1][col + 1]) and isTileCanMove(MAP[row][col + 1]) then
					row, col = row + 1, col + 1
					tmpDir = Direction.LEFT_TO_RIGHT
				else
					return false, startX, startY, tmpDir
				end
			else
				return false, startX, startY, tmpDir
			end
		end
	elseif dir ==  Direction.TOP_TO_BOTTOM then
		if startY >  targetY then
			return true, targetX, targetY, tmpDir
		end
		if row >= maxRow then return false, startX, startY, tmpDir end
		row = row + 1
		if isTileCanMove(MAP[row][col]) then
			if startX > targetX and not isTileCanMove(MAP[row][col + 1]) then
				-- 先往左走到格子中间，然后再往下走
				return true, targetX, targetY, Direction.RIGHT_TO_LEFT
			elseif startX < targetX and not isTileCanMove(MAP[row][col - 1]) then
				-- 先往右走到格子中间，然后再往下走
				return true, targetX, targetY, Direction.LEFT_TO_RIGHT
			end
		else
			if targetX > startX then
				-- 先向左走，然后再往下走
				if isTileCanMove(MAP[row - 1][col - 1]) and isTileCanMove(MAP[row][col - 1]) then
					row, col = row - 1, col - 1
					tmpDir = Direction.RIGHT_TO_LEFT
				else
					return false, startX, startY, tmpDir
				end
			elseif targetX < startX then
				-- 先向右走，然后再往下走
				if isTileCanMove(MAP[row - 1][col + 1]) and isTileCanMove(MAP[row][col + 1]) then
					row, col = row - 1, col + 1
					tmpDir = Direction.LEFT_TO_RIGHT
				else
					return false, startX, startY, tmpDir
				end
			else
				return false, startX, startY, tmpDir
			end
		end
	end
	targetX, targetY = getPositionByRowAndCol(row, col)
	return isTileCanMove(MAP[row][col]), targetX, targetY, tmpDir
end