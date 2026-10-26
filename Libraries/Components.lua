local components = {}

function components.uiCorner(obj, offset, scale)
	if not obj then return end
	offset = offset or 11
	local uiCorner = Instance.new('UICorner', obj)
	uiCorner.CornerRadius = UDim.new(scale or 0, offset)
	return uiCorner
end

function components.uiStroke(obj, color, thickness, zindex, transparency, enabled)
	if not obj then return end
	local uiStroke = Instance.new('UIStroke', obj)
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Color = color
	uiStroke.Thickness = thickness or 1
	uiStroke.ZIndex = zindex  or 1
	uiStroke.Transparency = transparency or 0
	uiStroke.Enabled = enabled or true
	return uiStroke
end

function components.uiListLayout(obj, directions, padding, order, horizontalAllignment, vericalAllignment)
	if not obj then return end
	local uiListLayout = Instance.new('UIListLayout', obj)
	uiListLayout.FillDirection = directions or Enum.FillDirection.Vertical
	uiListLayout.SortOrder = order or Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = padding or UDim.new(0, 0)
	uiListLayout.HorizontalAlignment = horizontalAllignment or Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = vericalAllignment or Enum.VerticalAlignment.Top
	return uiListLayout
end

function components.uiPadding(obj, top, bottom, left, right)
	if not obj then return end
	top, bottom, left, right = top or 1, bottom or 0, left or 0, right or 0
	local uiPadding = Instance.new('UIPadding', obj)
	uiPadding.PaddingTop = UDim.new(0, top)
	uiPadding.PaddingBottom = UDim.new(0, bottom)
	uiPadding.PaddingLeft = UDim.new(0, left)
	uiPadding.PaddingRight = UDim.new(0, right)
    return uiPadding
end

function components.uiGradient(obj, color, rotation, enabled)
	if not obj then return end
	local uiGradient = Instance.new('UIGradient', obj)
	uiGradient.Rotation = rotation or 90
	uiGradient.Enabled = enabled ~= nil and enabled or true
	uiGradient.Color = color or ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
	return uiGradient
end

function components.font(args)
	return Font.new()
end

return components