local tweenService = cloneref(game:GetService('TweenService'))
local textService = cloneref(game:GetService('TextService'))
local coreGui = cloneref(game:GetService('CoreGui'))
local debris = cloneref(game:GetService('Debris'))

local screenGui = Instance.new('ScreenGui', coreGui)
local notificationsFolder = Instance.new('Folder', screenGui)
notificationsFolder.Name = 'Notifications'
local textBoundsParams = Instance.new('GetTextBoundsParams')

local function addCorner(obj, radius, topLeft, topRight, bottomLeft, bottomRight)
    if not obj then return end
    local uiCorner = Instance.new('UICorner', obj)
    uiCorner.CornerRadius = radius or UDim.new(0, 0)
    uiCorner.TopLeftRadius = topLeft or radius
    uiCorner.TopRightRadius = topRight or radius
    uiCorner.BottomLeftRadius = bottomLeft or radius
    uiCorner.BottomRightRadius = bottomRight or radius

    return uiCorner
end

local function addStroke(obj, color, thickness, zindex, transparency, enabled)
	if not obj then return end
	local stroke = Instance.new('UIStroke', obj)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.ZIndex = zindex  or 1
	stroke.Transparency = transparency or 0
	stroke.Enabled = enabled or true

	return stroke
end

local function getTextSize(text, fontFace, textSize)
    textBoundsParams.Text = text
    textBoundsParams.Font = fontFace
    textBoundsParams.Size = textSize
    textBoundsParams.Width = 1000
    return textService:GetTextBoundsAsync(textBoundsParams)
end

local pallet = {
    font = Font.new('rbxassetid://12187365364')
}

function pallet.fontFace(weight)
    local fontFace = pallet.font
    fontFace.Weight = Enum.FontWeight[weight or 'Regular']
    return fontFace
end

local notifications = {
    storage = {},
    tweenInfo = TweenInfo.new(0.4)
}

local currentY = 0
local function ReSortNotifications()
    local y = 0

    table.sort(notifications.storage, function(a, b)
        return a.holder.Position.Y.Offset < b.holder.Position.Y.Offset
    end)

    for i, notification in next, notifications.storage do
        notification.index = i
        if not notification.removing then
            task.spawn(function()
                tweenService:Create(notification.holder, notifications.tweenInfo, {Position = UDim2.new(1, -359, 0, y)}):Play()
            end)
            y += notification.height + 10
        end
    end

    currentY = y
end

function notifications:CreateNotification(args)
    task.spawn(function()
        local notification = {
            index = #notifications.storage + 1,
            height = 56,
            removing = false
        }
        local holder = Instance.new('Frame', notificationsFolder)
        holder.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
        holder.BackgroundTransparency = 0.39
        holder.BorderSizePixel = 0
        holder.Position = UDim2.new(1, 1, 0, currentY) --.. * 66 + 42 or 42
        holder.Size = UDim2.fromOffset(342, 56)
        holder.ZIndex = 10
        notification.holder = holder
        addCorner(holder, UDim.new(0, 12))
        addStroke(holder, Color3.fromRGB(70, 70, 70), 1, 1, 0.39)
        local title = Instance.new('TextLabel', holder)
        title.BackgroundTransparency = 1
        title.BorderSizePixel = 0
        title.Position = UDim2.fromOffset(args.Icon and 55 or 11, 12)
        title.Size = UDim2.new(1, -55, 0, 10)
        title.FontFace = pallet.fontFace()
        title.Text = tostring(args.Title)
        title.TextColor3 = Color3.fromRGB(236, 234, 241)
        title.TextSize = 15
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 10
        local description = Instance.new('TextLabel', holder)
        description.BackgroundTransparency = 1
        description.BorderSizePixel = 0
        description.Position = UDim2.fromOffset(args.Icon and 55 or 11, 26)
        description.Size = UDim2.new(1, -55, 0, 12)
        description.FontFace = pallet.fontFace()
        description.Text = tostring(args.Description)
        description.TextColor3 = Color3.fromRGB(236, 234, 241)
        description.TextSize = 15
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextYAlignment = Enum.TextYAlignment.Top
        description.ZIndex = 10
        table.insert(notifications.storage, notification)

        local textSize = getTextSize(description.Text, pallet.fontFace(), 15)
        if textSize.Y > 12 then
            holder.Size = UDim2.fromOffset(342, 44 + textSize.Y)
            description.Size = UDim2.new(1, -55, 0, textSize.Y)
            notification.height = 44 + textSize.Y
        end

        debris:AddItem(holder, args.Time + 0.8)
        tweenService:Create(holder, notifications.tweenInfo, {Position = UDim2.new(1, -359, 0, currentY)}):Play()  --.. * 66 + 42 or 42
        currentY += notification.height + 10
        task.wait(args.Time)
        table.remove(notifications.storage, table.find(notifications.storage, notification))
        ReSortNotifications()
        tweenService:Create(holder, notifications.tweenInfo, {Position = UDim2.new(1, 1, 0, holder.Position.Y.Offset)}):Play()  --.. 42 + notification.index > 1 and (notification.index - 1) * 66 + 42 or 42
    end)
end

notificationsFolder.ChildRemoved:Connect(ReSortNotifications)

function notifications:ClearNotifications()
    for _, notification in next, self.storage do
        notification.holder:Destroy()
    end

    table.clear(self.storage)
end

return notifications