module ("rect", package.seeall)

function IsIntersectingRect( aLeftTopX,  aLeftTopY,  aWidth,  aHeight,  bLeftTopX,  bLeftTopY,  bWidth,  bHeight)
	if (bLeftTopX >= aLeftTopX + aWidth or bLeftTopY >= aLeftTopY + aHeight or bLeftTopX + bWidth <= aLeftTopX or bLeftTopY + bHeight <= aLeftTopY) then
		return false
	end
	return true
end

function ExpandRect(x, y, width, height, val)
	return x-val, y-val, width+val*2, height+val*2
end

function IsInRect(x, y, width, height, point_x, point_y)
	return point_x>=x and point_x<x+width and point_y>=y and point_y<y+height
end

function IsNearRect(a_x, a_y, a_width, a_height, b_x, b_y, b_width, b_height)
	return IsIntersectingRect(a_x-1, a_y, a_width+2, a_height, b_x, b_y, b_width, b_height) or IsIntersectingRect(a_x, a_y-1, a_width, a_height+2, b_x, b_y, b_width, b_height)
end