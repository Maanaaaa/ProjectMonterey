local library = {
    Bind = Enum.KeyCode.RightShift,
    Loaded = false,
    Profile = 'default',
    SaveDelay = 5,
    apisWithClean = {}
}

local pallet = {
    font = Font.new('rbxassetid://12187365364'),
}
library.pallet = pallet

function pallet.fontFace(weight)
    local fontFace = pallet.font
    fontFace.Weight = Enum.FontWeight[weight or 'Regular']
    return fontFace
end

local oldgetcustomasset = getcustomasset
local getcustomasset = function(asset)
    if not asset or asset == '' then return '' end

    if not shared.montereyDeveloper and not isfile(asset) then
        local suc, res = pcall(function()
            asset = string.split(asset, 'ProjectMonterey/')[2]
            local suc, res = pcall(function()
                return game:HttpGet('https://raw.githubusercontent.com/Maanaaaa/ProjectMonterey/refs/heads/main/'..asset)
            end)
            if suc then
                writefile(asset, res)
                return oldgetcustomasset(asset)
            end
        end)
        if suc then return res end
    elseif shared.montereyDeveloper or isfile(asset) then
        local suc, res = pcall(function()
            return oldgetcustomasset(asset)
        end)
        if suc then return res end
    end

    return ''
end

local function getFile(path)
    path = tostring(path)
    if not shared.montereyDeveloper and not isfile(path) then
        path = string.split(path, 'ProjectMonterey/')[2]
        local suc, res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/Maanaaaa/ProjectMonterey/refs/heads/main/'..tostring(path))
        end)
        if suc then
            writefile(path, res)
            return res
        end
    elseif shared.montereyDeveloper or isfile(path) then
        return readfile(path)
    end
end

local userInputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local textService = cloneref(game:GetService('TextService'))
local httpService = cloneref(game:GetService('HttpService'))
local guiService = cloneref(game:GetService('GuiService'))
local players = cloneref(game:GetService('Players'))
local debris = cloneref(game:GetService('Debris'))
local lplr = players.LocalPlayer
local textBoundsParams = Instance.new('GetTextBoundsParams')
local coreGui

local components = loadstring(getFile('ProjectMonterey/Libraries/Components.lua'))()
local notifications = shared.montereyNotifications or loadstring(getFile('ProjectMonterey/Libraries/Notifications.lua'))()
shared.montereyNotifications = notifications
local signalLibrary = loadstring(getFile('ProjectMonterey/Libraries/SignalLibrary.lua'))()
library.components = components
library.signalLibrary = signalLibrary

library.unload = signalLibrary.createSignal('Unload')

local suc, res = pcall(function()
    return game:GetService('CoreGui')
end)
coreGui = suc and res or lplr.PlayerGui

local screenGui = Instance.new('ScreenGui', coreGui)
library.screenGui = screenGui
local colorPickersFolder = Instance.new('Folder', screenGui)
colorPickersFolder.Name = 'ColorPickers'
local dropdownsFolder = Instance.new('Folder', screenGui)
dropdownsFolder.Name = 'Dropdowns'
local notificationsFolder = Instance.new('Folder', screenGui)
notificationsFolder.Name = 'Notifications'

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

local function addGradient(obj, color, rotation, enabled)
	if not obj then return end
	local gradient = Instance.new('UIGradient', obj)
	gradient.Rotation = rotation or 90
	gradient.Enabled = enabled ~= nil and enabled or true
	gradient.Color = color or ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })

	return gradient
end

local function addList(obj, directions, padding, order, horizontalAllignment, vericalAllignment)
	if not obj then return end
	local list = Instance.new('UIListLayout', obj)
	list.FillDirection = directions or Enum.FillDirection.Vertical
	list.SortOrder = order or Enum.SortOrder.LayoutOrder
	list.Padding = padding or UDim.new(0, 0)
	list.HorizontalAlignment = horizontalAllignment or Enum.HorizontalAlignment.Center
	list.VerticalAlignment = vericalAllignment or Enum.VerticalAlignment.Top

	return list
end

local function addPadding(obj, top, bottom, left, right)
	if not obj then return end
	local padding = Instance.new('UIPadding', obj)
	padding.PaddingTop = top or UDim.new(0, 0)
	padding.PaddingBottom = bottom or UDim.new(0, 0)
	padding.PaddingLeft = left or UDim.new(0, 0)
	padding.PaddingRight = right or UDim.new(0, 0)

    return padding
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

function library:getLastProfile()
    return isfile('ProjectMonterey/Profiles/CurrentProfile.txt') and readfile('ProjectMonterey/Profiles/CurrentProfile.txt')
end

function library:SaveProfile(profile)
    profile = profile or self.Profile
    local profileData = {
        Toggles = {}
    }

    if self.window then
        self.window:Save(profileData)

        for _, tab in next, self.window.Tabs do
            if not tab.Custom then
                for _, toggle in next, tab.Toggles do
                    if not toggle.Unsaveable then
                        toggle:Save(profileData.Toggles)
                    end

                    for _, option in next, toggle.Options do
                        if option.Save then
                            option:Save(profileData.Toggles[toggle.Name].Options)
                        end
                    end
                end
            end
        end
    end

    if not isfolder('ProjectMonterey/Profiles/'..profile) then
        makefolder('ProjectMonterey/Profiles/'..profile)
    end
    if not isfolder('ProjectMonterey/Profiles/'..profile..'/Sessions') then
        makefolder('ProjectMonterey/Profiles/'..profile..'/Sessions')
    end
    writefile('ProjectMonterey/Profiles/CurrentProfile.txt', profile)
    writefile('ProjectMonterey/Profiles/'..profile..'/'..game.PlaceId..'.json', httpService:JSONEncode(profileData))
end

function library:LoadProfile(profile)
    local post = 'success'
    profile = profile or library:getLastProfile()
    local isProfile = isfile('ProjectMonterey/Profiles/'..profile..'/'..game.PlaceId..'.json')
    if isProfile then
        local suc, res = pcall(function()
            local profileData = httpService:JSONDecode(readfile('ProjectMonterey/Profiles/'..profile..'/'..game.PlaceId..'.json'))
            if self.window then
                self.window:Load(profileData[self.window.Name])

                for _, tab in next, self.window.Tabs do
                    if not tab.Custom then
                        for _, toggle in next, tab.Toggles do
                            local toggleData = profileData.Toggles[toggle.Name]
                            if toggleData and not toggle.Unsaveable then
                                toggle:Load(toggleData)

                                for _, option in next, toggle.Options do
                                    local optionData = toggleData.Options[option.Name]
                                    if toggleData.Options[option.Name] then
                                        option:Load(optionData)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)

        if not suc then
            post = 'unsuccess, ', res
        end
    else
        warn('ProjectMonterey: profile ', profile, " file doesn't exist.")
        post = "unsuccess, profile folder/file doesn't exist"
    end

    return post
end

function library:StartSaveLoop()
    task.spawn(function()
        repeat
            if library.Loaded then
                library:SaveProfile()
                task.wait(library.SaveDelay)
            end
        until not library.Loaded
    end)
end

function library:addClean(api)
    table.insert(library.apisWithClean, api)
    api.connections = api.connections or {}
    function api:Clean(args)
        if typeof(args) == 'Instance' then
            local arg = {}
            function arg:Disconnect()
                arg:ClearAllChildren()
                arg:Destroy()
            end
            table.insert(api.connections, arg)
        else
            table.insert(api.connections, args)
        end
    end
end
library:addClean(library)

function library:dragGui(frame, button)
    if not button then button = frame end
    task.spawn(function()
        local startPos, dragStart, dragging = UDim2.new(0, 0, 0, 0), Vector3.zero, false
        local input

        library:Clean(button.InputBegan:Connect(function(newInput)
            if newInput.UserInputType == Enum.UserInputType.MouseButton1 or newInput.UserInputType == Enum.UserInputType.Touch then
                startPos, dragStart, dragging = frame.Position, input.Position, true

                library:Clean(newInput.Changed:Connect(function()
                    if newInput.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end))
            end
        end))
        library:Clean(button.InputChanged:Connect(function(newInput)
            input = (newInput.UserInputType == Enum.UserInputType.MouseMovement or newInput.UserInputType == Enum.UserInputType.Touch) and newInput or input
        end))
        library:Clean(userInputService.InputChanged:Connect(function(newInput)
            if newInput == input and dragging then
                local delta = input.Position - dragStart
			    local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                tweenService:Create(frame, TweenInfo.new(0.2), {Position = pos}):Play()
            end
        end))
    end)
end

function library:RemoveToggle(name)
    if not name then return end

    for _, tab in next, self.window.Tabs do
        if not tab.Custom then
            for _, toggle in next, tab.Toggles do
                if toggle.Name == name then
                    if toggle.Enabled then toggle:Toggle() end

                    toggle.container:Destroy()
                    toggle.optionsContainer:Destroy()
                    table.remove(tab.Toggles, table.find(tab.Toggles, name))

                    return
                end
            end
        end
    end
end

function library:Hide(bool)
    self.windowapi.container.Visible = bool ~= nil and bool or not self.windowapi.container.Visible
end

function library:Destruct(self)
    self = self or library
    self.unload:Fire()
    self.Loaded = false
    self:SaveProfile()

    for _, connection in next, self.connections do connection:Disconnect() end
    for _, api in next, self.apisWithClean do
        for _, connection in next, api.connections do
            connection:Disconnect()
        end
    end
    for _, tab in next, self.windowapi.Tabs do
        if not tab.Custom then
            for _, toggle in next, tab.Toggles do
                if toggle.Enabled then toggle:Toggle(false, true) end
            end
        end
    end

    notifications:ClearNotifications()
    screenGui:Destroy()
end

function library:setZIndex(obj, zindex)
    if not obj or not obj.ZIndex then return end
    zindex = zindex or 5
    obj.ZIndex = zindex
    for _, v in next, obj:GetDescendants() do
        local suc, res = pcall(function()
            return v.ZIndex
        end)
        if suc then v.ZIndex = zindex end
    end
end

function library:getIndex(table, value)
    for i, obj in next, table do
        if obj == value then
            return i
        end
    end

    return 0
end

function library:getLongestValue(array)
    local longest, longestValue = 0, nil
    for _, v in next, array do
        if typeof(v) == 'string' then
            if #v > longest then
                longest = #v
                longestValue = v
            end
        end
    end

    return longestValue
end

function library:getTextSize(text, fontFace, textSize)
    textBoundsParams.Text = text
    textBoundsParams.Font = fontFace
    textBoundsParams.Size = textSize
    textBoundsParams.Width = 1000
    return textService:GetTextBoundsAsync(textBoundsParams)
end

--[[
local notifications = {
    storage = {},
    tweenInfo = TweenInfo.new(0.4)
}

function library:ReSortNotifications()
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
            y += 66
        end
    end
end

function library:CreateNotification(args)
    task.spawn(function()
        local notification = {
            index = #notifications.storage + 1,
            removing = false
        }
        local holder = Instance.new('Frame', notificationsFolder)
        holder.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
        holder.BackgroundTransparency = 0.39
        holder.BorderSizePixel = 0
        holder.Position = UDim2.new(1, 1, 0, notification.index > 1 and (notification.index - 1) * 66) --.. * 66 + 42 or 42
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

        debris:AddItem(holder, args.Time + 0.8)
        tweenService:Create(holder, notifications.tweenInfo, {Position = UDim2.new(1, -359, 0, notification.index > 1 and (notification.index - 1) * 66)}):Play()  --.. * 66 + 42 or 42
        task.wait(args.Time)
        table.remove(notifications.storage, table.find(notifications.storage, notification))
        library.ReSortNotifications()
        tweenService:Create(holder, notifications.tweenInfo, {Position = UDim2.new(1, 1, 0, holder.Position.Y.Offset)}):Play()  --.. 42 + notification.index > 1 and (notification.index - 1) * 66 + 42 or 42
    end)
end

library:Clean(notificationsFolder.ChildRemoved:Connect(library.ReSortNotifications))
]]

function library:CreateWindow(title)
    local windowapi = {
        Name = title,
        CurrentTab = nil,
        Sections = {},
        Tabs = {}
    }
    library:addClean(windowapi)
    local window = Instance.new('Frame', screenGui)
    window.Name = 'window'
    window.BackgroundTransparency = 1
    window.BorderSizePixel = 0
    window.Size = UDim2.fromOffset(900, 454)--UDim2.fromScale(0.532999992, 0.481999993)
    window.Position = UDim2.fromOffset(10, 100)--200UDim2.new(-window.Size.X.Scale / 2, screenGui.AbsoluteSize.X / 2, -window.Size.Y.Scale / 2, screenGui.AbsoluteSize.Y / 2)
    window.Visible = false
    addCorner(window, UDim.new(0, 11))
    components.uiStroke(window, Color3.fromRGB(), 2)
    windowapi.container = window
    library.windowapi = windowapi
    local background = Instance.new('Frame', window)
    background.Name = 'background'
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BorderSizePixel = 0
    background.Size = UDim2.fromScale(1, 1)
    background.ZIndex = 1
    addCorner(background, UDim.new(0, 11))
    components.uiStroke(background, Color3.fromRGB(96, 94, 100))
    local trafficLight = Instance.new('Frame', background)
    trafficLight.BackgroundTransparency = 1
    trafficLight.BorderSizePixel = 0
    trafficLight.Size = UDim2.new(0.203999996, 0, 0, 50)
    trafficLight.ZIndex = 3
    local redButton = Instance.new('TextButton', trafficLight)
    redButton.AutoButtonColor = false
    redButton.BackgroundColor3 = Color3.fromRGB(238, 92, 84)
    redButton.BorderSizePixel = 0
    redButton.Position = UDim2.fromOffset(18, 18)
    redButton.Size = UDim2.fromOffset(12, 12)
    redButton.Text = ''
    redButton.ZIndex = 3
    addCorner(redButton, UDim.new(1, 0))
    local redButtonIcon = Instance.new('ImageButton', redButton)
    redButtonIcon.Name = 'icon'
    redButtonIcon.BackgroundTransparency = 1
    redButtonIcon.BorderSizePixel = 0
    redButtonIcon.Size = UDim2.fromOffset(6, 6)
    redButtonIcon.Position = UDim2.fromOffset(3, 3)
    redButtonIcon.Image = getcustomasset('ProjectMonterey/Assets/Gui/TrafficLight/BigClose.png')
    redButtonIcon.ImageTransparency = 1
    local redButtonHitbox = Instance.new('TextButton', redButton)
    redButtonHitbox.AutoButtonColor = false
    redButtonHitbox.Name = 'hitbox'
    redButtonHitbox.BackgroundTransparency = 1
    redButtonHitbox.BorderSizePixel = 0
    redButtonHitbox.Size = UDim2.fromScale(1, 1)
    redButtonHitbox.Text = ''
    local yellowButton = redButton:Clone()
    yellowButton.Parent = trafficLight
    yellowButton.BackgroundColor3 = Color3.fromRGB(247, 188, 69)
    yellowButton.Position = UDim2.fromOffset(39, 18)
    yellowButton.icon.Position = UDim2.fromOffset(2, 5)
    yellowButton.icon.Size = UDim2.fromOffset(8, 2)
    yellowButton.icon.Image = getcustomasset('ProjectMonterey/Assets/Gui/TrafficLight/Hide.png')
    --[[
    local grayButton = redButton:Clone() --greenButton, TextButton
    grayButton.Parent = trafficLight
    grayButton.BackgroundColor3 = Color3.fromRGB(91, 87, 95)--Color3.fromRGB(93, 201, 66)
    grayButton.Position = UDim2.fromOffset(60, 18)
    grayButton.icon:Destroy()
    ]]
    local grayButton = Instance.new('TextLabel', trafficLight)
    grayButton.BackgroundColor3 = Color3.fromRGB(91, 87, 95)--Color3.fromRGB(93, 201, 66)
    grayButton.BorderSizePixel = 0
    grayButton.Position = UDim2.fromOffset(60, 18)
    grayButton.Size = UDim2.fromOffset(12, 12)
    grayButton.Text = ''
    grayButton.ZIndex = 3
    addCorner(grayButton, UDim.new(1, 0))
    local leftBar = Instance.new('Frame', background)
    leftBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    leftBar.BorderSizePixel = 0
    leftBar.Size = UDim2.new(0, 147, 1, 0)
    leftBar.ZIndex = 2
    addCorner(leftBar, UDim.new(0, 11), UDim.new(0, 11), UDim.new(0, 0), UDim.new(0, 11), UDim.new(0, 0))
    local uiGradient = components.uiGradient(
        leftBar,
        ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 42, 84)), ColorSequenceKeypoint.new(1, Color3.fromRGB(46, 38, 70))},
        90
    )
    local container = Instance.new('ScrollingFrame', leftBar)
    container.Name = 'container'
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Position = UDim2.fromOffset(9, 44)
    container.Size = UDim2.new(0, 136, 1, -51)
    container.ScrollBarThickness = 7
    container.ScrollBarImageTransparency = 1
    container.ScrollingDirection = Enum.ScrollingDirection.Y
    local uiListLayout = components.uiListLayout(container, Enum.FillDirection.Vertical, UDim.new(0, 18))
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    components.uiPadding(container, 7)
    local topBar = Instance.new('Frame', background)
    topBar.BackgroundColor3 = Color3.fromRGB(34, 30, 38)
    topBar.BorderSizePixel = 0
    topBar.Position = UDim2.fromOffset(148, 0)
    topBar.Size = UDim2.new(1, -148, 0, 50)
    addCorner(topBar, UDim.new(0, 11), UDim.new(0, 0), UDim.new(0, 11), UDim.new(0, 0), UDim.new(0, 0))
    local leftArrow = Instance.new('ImageButton', topBar)
    leftArrow.BackgroundTransparency = 1
    leftArrow.BorderSizePixel = 0
    leftArrow.Position = UDim2.fromOffset(23, 18)
    leftArrow.Size = UDim2.fromOffset(8, 14)
    leftArrow.Image = getcustomasset('ProjectMonterey/Assets/Gui/TopBarLeftArrow.png')
    leftArrow.ImageColor3 = Color3.fromRGB(71, 69, 76)
    local rightArrow = Instance.new('ImageButton', topBar)
    rightArrow.BackgroundTransparency = 1
    rightArrow.BorderSizePixel = 0
    rightArrow.Position = UDim2.fromOffset(52, 18)
    rightArrow.Size = UDim2.fromOffset(8, 14)
    rightArrow.Image = getcustomasset('ProjectMonterey/Assets/Gui/TopBarRightArrow.png')
    rightArrow.ImageColor3 = Color3.fromRGB(71, 69, 76)
    local titleLabel = Instance.new('TextLabel', topBar)
    titleLabel.BackgroundTransparency = 1
    titleLabel.BorderSizePixel = 0
    titleLabel.Position = UDim2.fromOffset(73, 0)
    titleLabel.Size = UDim2.fromOffset(200, 50)
    titleLabel.FontFace = pallet.fontFace('Medium')
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local searchButton = Instance.new('ImageButton', topBar)
    searchButton.BackgroundTransparency = 1
    searchButton.BorderSizePixel = 0
    searchButton.Position = UDim2.new(1, -34, 0, 17)
    searchButton.Size = UDim2.fromOffset(15, 15)
    searchButton.Image = getcustomasset('ProjectMonterey/Assets/Gui/Search.png')
    local searchBar = Instance.new('Frame', topBar)
    searchBar.BackgroundColor3 = Color3.fromRGB(55, 51, 61)
    searchBar.BorderSizePixel = 0
    searchBar.Position = UDim2.new(1, -172, 0, 12)
    searchBar.Size = UDim2.fromOffset(160, 26)
    searchBar.Visible = false
    addCorner(searchBar, UDim.new(0, 6))
    local searchStroke = components.uiStroke(searchBar,
        Color3.fromRGB(54, 116, 160),
        1,
        5
    )
    local searchStroke2 = components.uiStroke(searchBar,
        Color3.fromRGB(47, 109, 154),
        4
    )
    local barSearchButton = Instance.new('ImageButton', searchBar)
    barSearchButton.BackgroundTransparency = 1
    barSearchButton.BorderSizePixel = 0
    barSearchButton.Position = UDim2.fromOffset(10, 6)
    barSearchButton.Size = UDim2.fromOffset(13, 13)
    barSearchButton.Image = getcustomasset('ProjectMonterey/Assets/Gui/Search.png')
    local clearButton = Instance.new('ImageButton', searchBar)
    clearButton.BackgroundTransparency = 1
    clearButton.BorderSizePixel = 0
    clearButton.Position = UDim2.new(1, -21, 0, 6)
    clearButton.Size = UDim2.fromOffset(13, 13)
    clearButton.Image = getcustomasset('ProjectMonterey/Assets/Gui/Clear.png')
    local textBox = Instance.new('TextBox', searchBar)
    textBox.BackgroundTransparency = 1
    textBox.BorderSizePixel = 0
    textBox.Position = UDim2.fromOffset(30, 6)
    textBox.Size = UDim2.fromOffset(109, 15)
    textBox.FontFace = pallet.fontFace()
    textBox.Text = ''
    textBox.TextColor3 = Color3.fromRGB(220, 223, 229)
    textBox.TextSize = 13
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    local unfocusButton = Instance.new('TextButton', window)
    unfocusButton.BackgroundTransparency = 1
    unfocusButton.BorderSizePixel = 0
    unfocusButton.Size = UDim2.fromScale(1, 1)
    unfocusButton.Text = ''
    unfocusButton.Visible = false
    local searchContainer = Instance.new('ScrollingFrame', searchBar)
    searchContainer.BackgroundColor3 = Color3.fromRGB(34, 28, 40)
    searchContainer.BackgroundTransparency = 0.2
    searchContainer.Position = UDim2.fromOffset(-1, 30)
    addCorner(searchContainer, UDim.new(0, 6))
    components.uiStroke(searchContainer,
        Color3.fromRGB(37, 39, 54),
        1,
        5,
        0.5
    )
    components.uiStroke(searchContainer,
        Color3.fromRGB(),
        2,
        1,
        0.5
    )
    local uiListLayout = components.uiListLayout(searchContainer)
    components.uiPadding(searchContainer, 9)

    library:setZIndex(trafficLight, 10)
    library:setZIndex(leftBar)
    library:setZIndex(searchBar)
    library:dragGui(window, topBar)

    library:Clean(redButtonHitbox.MouseEnter:Connect(function()
        redButtonIcon.ImageTransparency = 0
    end))
    library:Clean(redButtonHitbox.MouseLeave:Connect(function()
        redButtonIcon.ImageTransparency = 1
    end))
    library:Clean(redButtonHitbox.MouseButton1Click:Connect(library.Destruct))
    library:Clean(yellowButton.hitbox.MouseEnter:Connect(function()
        yellowButton.icon.ImageTransparency = 0
    end))
    library:Clean(yellowButton.hitbox.MouseLeave:Connect(function()
        yellowButton.icon.ImageTransparency = 1
    end))
    library:Clean(yellowButton.hitbox.MouseButton1Click:Connect(library.Hide))

    function windowapi:Save(data)
        data[windowapi.Name] = {
            Position = {window.Position.X.Scale, window.Position.X.Offset, window.Position.Y.Scale, window.Position.Y.Offset}
        }
    end

    function windowapi:Load(data)
        if not data then return end
        window.Position = UDim2.new(table.unpack(data.Position))
    end

    -- // pages system
    local pages = {}
    local pagesController = {
        currentIndex = 0
    }
    function pagesController:updateArrows()
        leftArrow.ImageColor3 = pagesController.currentIndex <= 1 and Color3.fromRGB(71, 69, 76) or Color3.fromRGB(255, 255, 255)
        rightArrow.ImageColor3 = pagesController.currentIndex < #pages and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(71, 69, 76)
    end

    function pagesController:updatePages()
        for _, v in next, pages do
            if _ > pagesController.currentIndex then
                table.remove(pages, _)
            end
        end
    end

    function pagesController:addPage(data)
        if pagesController.currentIndex ~= #pages then pagesController:updatePages() end
        table.insert(pages, data)
        pagesController.currentIndex = #pages
        pagesController:updateArrows()
    end

    function pagesController:previousPage()
        if pagesController.currentIndex >= 0 then
            pagesController.currentIndex -= 1
            local data = pages[pagesController.currentIndex]
            if data then
                data:Select(data.TabButton ~= nil)
            end
        end
        pagesController:updateArrows()
    end

    function pagesController:nextPage()
        if #pages >= pagesController.currentIndex then
            pagesController.currentIndex += 1
            local data = pages[pagesController.currentIndex]
            if data then
                data:Select(data.TabButton ~= nil)
            end
        end
        pagesController:updateArrows()
    end

    library:Clean(leftArrow.MouseButton1Click:Connect(pagesController.previousPage))
    library:Clean(rightArrow.MouseButton1Click:Connect(pagesController.nextPage))

    -- // search system
    local searching = false
    local searchResults = {}
    local searchController = {
        x = 0,
        connections = {}
    }
    function searchController:reSize()
        local y = uiListLayout.AbsoluteContentSize.Y
        searchContainer.Size = UDim2.fromOffset(searchController.x, (y + 18) > 486 and 486 or y + 18)
        searchContainer.CanvasSize = UDim2.fromOffset(0, y + 9)
    end

    function searchController:search(part)
        local results = {}
        if not part then return results end

        for _, tab in next, windowapi.Tabs do
            if string.find(string.lower(tab.Name), string.lower(part)) then
                table.insert(results, tab)
            end
            for _, toggle in next, tab.Toggles do
                if string.find(string.lower(toggle.Name), string.lower(part)) then
                    table.insert(results, toggle)
                end
                for _, option in next, toggle.Options do
                    if string.find(string.lower(option.Name), string.lower(part)) then
                        table.insert(results, option)
                    end
                end
            end
        end

        return results
    end

    function searchController:clearResults()
        for _, v in next, searchResults do
            if v.container then v.container:Destroy() end
        end
        for _, v in next, searchController.connections do
            v:Disconnect()
        end
        table.clear(searchResults)
        table.clear(searchController.connections)
        searchController.x = 0
        searchContainer.Visible = false
    end

    function searchController:createResult(name, api)
        if not name then return end

        local x = library:getTextSize(name, pallet.fontFace(), 11).X + 49
        searchController.x = searchController.x >= x and searchController.x or x
        local holder = Instance.new('Frame', searchContainer)
        holder.BackgroundTransparency = 1
        holder.BorderSizePixel = 0
        holder.Size = UDim2.new(1, 0, 0, 20)
        local text = Instance.new('TextLabel', holder)
        text.BackgroundTransparency = 1
        text.BorderSizePixel = 0
        text.Size = UDim2.new(1, -49, 0, 9)
        text.Position = UDim2.fromOffset(6, 5)
        text.FontFace = pallet.fontFace()
        text.Text = name
        text.TextColor3 = Color3.fromRGB(203, 201, 205)
        text.TextSize = 13
        text.TextXAlignment = Enum.TextXAlignment.Left
        local button = Instance.new('TextButton', holder)
        button.BackgroundTransparency = 1
        button.BorderSizePixel = 0
        button.Size = UDim2.fromScale(1, 1)
        button.Text = ''
        table.insert(searchResults, {
            Name = name,
            container = holder,
            api = api
        })

        library:setZIndex(searchContainer, 5)

        table.insert(searchController.connections, button.MouseButton1Click:Connect(function()
            api:Select(true, true)
        end))
    end

    library:Clean(uiListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(searchController.reSize))
    library:Clean(searchButton.MouseButton1Click:Connect(function()
        searchButton.Visible = false
        unfocusButton.Visible = true
        searchBar.Visible = true
    end))
    library:Clean(barSearchButton.MouseButton1Click:Connect(function()
        textBox:CaptureFocus()
    end))
    library:Clean(unfocusButton.MouseButton1Click:Connect(function(a)
        searchController:clearResults()
        textBox.Text = ''
        searchBar.Visible = false
        unfocusButton.Visible = false
        searchButton.Visible = true
    end))
    library:Clean(textBox:GetPropertyChangedSignal('Text'):Connect(function(text)
        searchController:clearResults()
        local text = textBox.Text
        if not text or text == '' then return end

        local results = searchController:search(text)
        searchContainer.Visible = #results ~= 0
        if #results == 0 then return end

        for _, result in next, results do
            searchController:createResult(result.Name, result)
        end
    end))
    library:Clean(clearButton.MouseButton1Click:Connect(searchController.clearResults))


    function windowapi:CreateSection(args)
        local name = args.Name
        local sectionapi = {
            Name = name,
            Buttons = {},
            Tabs = {}
        }
        table.insert(windowapi.Sections, sectionapi)
        local section = Instance.new('Frame', container)
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.BackgroundTransparency = 1
        section.BorderSizePixel = 0
        section.Size = UDim2.new(1, -7, 0, 0)
        local title = Instance.new('TextLabel', section)
        title.BackgroundTransparency = 1
        title.BorderSizePixel = 0
        title.Position = UDim2.fromOffset(6, 0)
        title.Size = UDim2.new(1, -6, 0, 9)
        title.FontFace = pallet.fontFace()
        title.Text = name
        title.TextColor3 = Color3.fromRGB(116, 101, 144)
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        local expandButton = Instance.new('ImageButton', section)
        expandButton.BackgroundTransparency = 1
        expandButton.BorderSizePixel = 0
        expandButton.Position = UDim2.new(1, -14, 0, 0)
        expandButton.Size = UDim2.fromOffset(10, 6)
        expandButton.Image = getcustomasset('ProjectMonterey/Assets/Gui/SectionArrow.png')
        expandButton.ImageColor3 = Color3.fromRGB(124, 101, 144)
        local container = Instance.new('Frame', section)
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.Position = UDim2.fromOffset(0, 15)
        container.Size = UDim2.fromScale(1, 0)
        components.uiListLayout(container)
        sectionapi.container = container

        library:setZIndex(section)

        return sectionapi
    end

    function windowapi:CreateTab(args)
        local name = args.Name
        local custom = args.Custom or false
        local scrollable = args.Scrollable or false
        local selected = args.Default or false
        local section = args.Section
        local icon = args.Icon
        local iconSize = args.IconSize
        local tabapi = {
            Name = name,
            Selected = false,
            SelectedToggle = nil,
            Toggles = {}
        }
        library:addClean(tabapi)
        table.insert(windowapi.Tabs, tabapi)
        table.insert(section.Tabs, tabapi)

        local background = Instance.new(scrollable and 'ScrollingFrame' or 'Frame', background)
        background.Name = name
        background.BackgroundColor3 = Color3.fromRGB(34, 28, 40)
        background.BorderSizePixel = 0
        background.Position = UDim2.fromOffset(148, 51)
        background.Size = UDim2.new(1, -149, 1, -51)
        background.Visible = false
        tabapi.container = background
        addCorner(background, UDim.new(0, 11), UDim.new(0, 0), UDim.new(0, 0), UDim.new(0, 0))
        if scrollable then
            background.AutomaticCanvasSize = Enum.AutomaticSize.Y
            background.ScrollBarImageColor3 = Color3.fromRGB(180, 166, 206)
            background.ScrollBarThickness = 7
        end
        local container = Instance.new('Frame', background)
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.Size = UDim2.fromScale(1, 1)
        tabapi.contains = container
        local tabButton = Instance.new('Frame', section.container)
        tabButton.BackgroundTransparency = 1--0.88
        tabButton.BorderSizePixel = 0
        tabButton.Size = UDim2.new(1, -7, 0, 28)
        addCorner(tabButton, UDim.new(0, 6))
        tabapi.TabButton = tabButton
        local text = Instance.new('TextLabel', tabButton)
        text.BackgroundTransparency = 1
        text.BorderSizePixel = 0
        text.Position = UDim2.fromOffset(31, 0)
        text.Size = UDim2.new(1, -31, 1, 0)
        text.FontFace = pallet.fontFace()
        text.Text = name
        text.TextColor3 = Color3.fromRGB(234, 232, 238)
        text.TextSize = 13
        text.TextXAlignment = Enum.TextXAlignment.Left
        local iconImage = Instance.new('ImageLabel', tabButton)
        iconImage.BackgroundTransparency = 1
        iconImage.BorderSizePixel = 0
        iconImage.Position = UDim2.fromOffset(9, ( 28 - iconSize.Y.Offset or 14) / 2)
        iconImage.Size = iconSize or UDim2.fromOffset(14, 14)
        iconImage.Image = getcustomasset(icon)--'rbxassetid://14368359107'
        local button = Instance.new('TextButton', tabButton)
        button.BackgroundTransparency = 1
        button.BorderSizePixel = 0
        button.Size = UDim2.fromScale(1, 1)
        button.Text = ''

        library:setZIndex(section.container)

        function tabapi:Select(bool, addToPages)
            if bool == nil then bool = not tabapi.Selected end
            if bool == tabapi.Selected then return end
            for _, tabapi in next, windowapi.Tabs do
                tabapi.Selected = false

                tabapi.container.Visible = false
                tabapi.TabButton.BackgroundTransparency = 1
                if tabapi.Name == name then
                    tabapi.Selected = bool

                    titleLabel.Text = bool and name or 'Project Monterey'

                    background.Visible = bool
                    tabButton.BackgroundTransparency = bool and 0.88 or 1
                    if addToPages then
                        pagesController:addPage({
                            Select = function(_, selectLastToggle)
                                tabapi:Select(true)
                                if not selectLastToggle then
                                    for _, v in next, tabapi.Toggles do
                                        v.optionsHolder.Visible = false
                                        v.Selected = false
                                    end
                                end
                            end
                        })
                    end
                end
            end
        end

        if selected then tabapi:Select(true, true) end

        library:Clean(button.MouseButton1Click:Connect(function()
            tabapi:Select(not tabapi.Selected, true)
        end))

        if not custom then
            local togglesContainer = Instance.new('ScrollingFrame', container)
            togglesContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            togglesContainer.BackgroundTransparency = 1
            togglesContainer.BorderSizePixel = 0
            togglesContainer.Position = UDim2.fromOffset(0, -2)
            togglesContainer.Size = UDim2.new(0, 171, 1, 2)
            togglesContainer.ScrollBarThickness = 7
            togglesContainer.ScrollBarImageTransparency = 1
            togglesContainer.ScrollingDirection = Enum.ScrollingDirection.Y
            components.uiListLayout(togglesContainer)
            components.uiPadding(togglesContainer, 10)
            local optionsContainer = Instance.new('ScrollingFrame', container)
            optionsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            optionsContainer.BackgroundTransparency = 1
            optionsContainer.BorderSizePixel = 0
            optionsContainer.Position = UDim2.fromOffset(171, -2)
            optionsContainer.Size = UDim2.new(1, -171, 1, 0)
            optionsContainer.ScrollBarThickness = 7
            optionsContainer.ScrollBarImageTransparency = 1
            optionsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
            components.uiListLayout(optionsContainer)
            components.uiPadding(optionsContainer, 10)

            function tabapi:SelectToggle(name, addtoPages)
                if not name then return end
                tabapi:Select(true, true)
                tabapi.SelectedToggle = name
                for _, v in next, tabapi.Toggles do
                    if v.Name == name then
                        v.optionsHolder.Visible = true
                        v.Selected = true
                    else
                        v.optionsHolder.Visible = false
                        v.Selected = false
                    end
                end
                if addtoPages then
                    pagesController:addPage({
                        Name = name,
                        Select = function()
                            tabapi:Select(true)
                            tabapi:SelectToggle(name)
                        end
                    })
                end
            end

            function tabapi:CreateToggle(args)
                local name = args.Name
                local enabled = args.Enabled or false
                local shortDescription = args.ShortDescription
                local longDescription = args.LongDescription or shortDescription
                local icon = args.Icon
                local iconSize = args.IconSize
                local callback = args.Callback or function() end
                local toggleapi = {
                    Name = name,
                    Enabled = false,
                    Selected = false,
                    Callback = callback,
                    Options = {}
                }
                library:addClean(toggleapi)
                table.insert(tabapi.Toggles, toggleapi)

                local holder = Instance.new('Frame', togglesContainer)
                holder.BackgroundTransparency = 1--0.880
                holder.BorderSizePixel = 0
                holder.LayoutOrder = #tabapi.Toggles --// todo: make toggles sort in alphabetical order if its in monterey
                holder.Size = UDim2.new(0, 154, 0, 50)
                addCorner(holder, UDim.new(0, 8))
                toggleapi.container = holder
                local iconImage = Instance.new('ImageLabel', holder)
                iconImage.BackgroundTransparency = 1
                iconImage.BorderSizePixel = 0
                iconImage.Position = iconSize and UDim2.fromOffset(18 - iconSize.X.Offset / 2, 25 - iconSize.Y.Offset / 2) or UDim2.fromOffset(0, 0)
                iconImage.Size = iconSize or UDim2.fromOffset(1, 1)
                iconImage.Image = getcustomasset(icon) or ''
                local titleLabel = Instance.new('TextLabel', holder)
                titleLabel.BackgroundTransparency = 1
                titleLabel.BorderSizePixel = 0
                titleLabel.Position = UDim2.fromOffset(icon and 37 or 18, 15)
                titleLabel.Size = UDim2.new(1, -37, 0, 12)
                titleLabel.FontFace = pallet.fontFace('Medium')
                titleLabel.Text = name
                titleLabel.TextColor3 = Color3.fromRGB(193, 193, 193)
                titleLabel.TextSize = 13
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                local descriptionLabel = Instance.new('TextLabel', holder)
                descriptionLabel.Name = 'descriptionLabel'
                descriptionLabel.BackgroundTransparency = 1
                descriptionLabel.BorderSizePixel = 0
                descriptionLabel.Position = UDim2.fromOffset(icon and 37 or 18, 29)
                descriptionLabel.Size = UDim2.new(1, -37, 0, 12)
                descriptionLabel.FontFace = pallet.fontFace()
                descriptionLabel.Text = shortDescription
                descriptionLabel.TextColor3 = Color3.fromRGB(193, 193, 193)
                descriptionLabel.TextSize = 12
                descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
                local openButton = Instance.new('TextButton', holder)
                openButton.BackgroundTransparency = 1
                openButton.BorderSizePixel = 0
                openButton.Size = UDim2.fromScale(1, 1)
                openButton.Text = ''
                local textSize = library:getTextSize(shortDescription, pallet.fontFace(), 12)
                if textSize.Y > 12 then
                    holder.Size = UDim2.new(0, 154, 0, 38 + textSize.Y)
                    descriptionLabel.Size = UDim2.new(1, -37, textSize.Y)
                end

                local holder2 = holder:Clone()
                holder2.Parent = optionsContainer
                holder2.LayoutOrder = 1
                holder2.Size = UDim2.new(1, 0, 0, 50)
                holder2.Visible = false
                addCorner(holder2, UDim.new(0, 8))
                toggleapi.optionsHolder = holder2
                holder2.descriptionLabel.Text = longDescription
                local toggleHolder = Instance.new('Frame', holder2)
                toggleHolder.BackgroundTransparency = 1
                toggleHolder.BorderSizePixel = 0
                toggleHolder.Position = UDim2.new(1, -43, 0, 15)
                toggleHolder.Size = UDim2.fromOffset(20, 20)
                local toggle = Instance.new('ImageButton', toggleHolder)
                toggle.AutoButtonColor = false
                toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggle.BorderSizePixel = 0
                toggle.Size = UDim2.fromScale(1, 1)
                toggle.Image = getcustomasset('ProjectMonterey/Assets/Gui/CheckMark.png')
                toggle.ImageTransparency = 1
                addCorner(toggle, UDim.new(0, 4))
                local uiGradient = components.uiGradient(toggle,
                    ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(68, 63, 73)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(79, 74, 83)), ColorSequenceKeypoint.new(1, Color3.fromRGB(97, 92, 100))},
                    90
                )
                local container = Instance.new('Frame', holder2)
                container.AutomaticSize = Enum.AutomaticSize.Y
                container.BackgroundTransparency = 1
                container.BorderSizePixel = 0
                container.Size = UDim2.fromScale(1, 0)
                container.Position = UDim2.fromOffset(0, 50)
                components.uiListLayout(container)
                toggleapi.optionsContainer = container
                local textSize = library:getTextSize(longDescription, pallet.fontFace(), 12)
                if textSize.Y > 12 then
                    holder2.Size = UDim2.new(1, 0, 0, 38 + textSize.Y)
                    holder2.descriptionLabel.Size = UDim2.new(1, -37, textSize.Y)
                    container.Position = UDim2.fromOffset(0, 38 + textSize.Y)
                end

                function toggleapi:Save(data)
                    data[toggleapi.Name] = {
                        Enabled = toggleapi.Enabled,
                        Options = {}
                    }
                end

                function toggleapi:Load(data)
                    toggleapi:Toggle(data.Enabled)
                end

                function toggleapi:Select(bool)
                    if bool == nil then bool = not toggleapi.Selected end
                    if bool == toggleapi.Selected then return end

                    if bool then
                        togglesContainer.CanvasPosition = Vector2.new(0, 10 + (-1 + library:getIndex(tabapi.Toggles, toggleapi)) * 50)
                    end

                    return tabapi:SelectToggle(name, bool)
                end

                function toggleapi:Toggle(bool, unload)
                    if bool == nil then bool = not toggleapi.Enabled end
                    if bool == toggleapi.Enabled then return end
                    toggleapi.Enabled = bool
                    holder.BackgroundTransparency = bool and 0.88 or 1
                    toggle.BackgroundTransparency = bool and 1 or 0
                    toggle.ImageTransparency = bool and 0 or 1
                    uiGradient.Enabled = not bool

                    notifications:CreateNotification({
                        Title = name,
                        Description = name..' has been '..(bool and 'enabled' or 'disabled')..'.',
                        Time = 5
                    })
                    task.spawn(callback, bool, unload)
                    task.spawn(function()
                        if not bool then
                            for _, v in next, toggleapi.connections do
                                v:Disconnect()
                            end
                        end
                    end)
                end

                toggleapi:Toggle(enabled)

                library:Clean(openButton.MouseButton1Click:Connect(function()
                    if toggleapi.Opened then
                        holder2.Visible = false
                        toggleapi.Opened = false
                    else
                        tabapi:SelectToggle(name, true)
                    end
                end))
                library:Clean(toggle.MouseButton1Click:Connect(toggleapi.Toggle))

                function toggleapi:CreateOptionToggle(args)
                    local name = args.Name
                    local subText = args.SubText
                    local enabled = args.Enabled or false
                    local visible = args.Visible == nil and true or args.Visible
                    local callback = args.Callback or function() end
                    local optionapi = {
                        Name = name,
                        Enabled = enabled
                    }
                    library:addClean(optionapi)
                    table.insert(toggleapi.Options, optionapi)

                    local holder = Instance.new('Frame', container)
                    holder.BackgroundTransparency = 1
                    holder.LayoutOrder = #toggleapi.Options
                    holder.Size = UDim2.new(1, 0, 0, subText and 44 or 26)
                    holder.Visible = visible
                    optionapi.container = holder
                    local text = Instance.new('TextLabel', holder)
                    text.BackgroundTransparency = 1
                    text.BorderSizePixel = 0
                    text.Position = UDim2.fromOffset(34, 6)
                    text.Size = UDim2.new(1, -34, 0, 14)
                    text.FontFace = pallet.fontFace()
                    text.Text = name
                    text.TextColor3 = Color3.fromRGB(222, 220, 222)
                    text.TextSize = 12
                    text.TextXAlignment = Enum.TextXAlignment.Left
                    local toggleHolder = Instance.new('Frame', holder)
                    toggleHolder.BackgroundTransparency = 1
                    toggleHolder.BorderSizePixel = 0
                    toggleHolder.Position = UDim2.fromOffset(16, 6)
                    toggleHolder.Size = UDim2.fromOffset(14, 14)
                    local toggle = Instance.new('ImageButton',  toggleHolder)
                    toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    toggle.BorderSizePixel = 0
                    toggle.Size = UDim2.fromScale(1, 1)
                    toggle.Image = getcustomasset('ProjectMonterey/Assets/Gui/CheckMark.png')
                    toggle.ImageTransparency = 1
                    addCorner(toggle, UDim.new(0, 4))
                    local uiGradient = components.uiGradient(toggle,
                        ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(68, 63, 73)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(79, 74, 83)), ColorSequenceKeypoint.new(1, Color3.fromRGB(97, 92, 100))},
                        90
                    )

                    if subText then
                        local text = Instance.new('TextLabel', holder) -- 6, 10
                        text.BorderSizePixel = 0
                        text.BackgroundTransparency = 1
                        text.Position = UDim2.fromOffset(34, 50)
                        text.Size = UDim2.fromOffset(1, -34, 0, 14)
                        text.FontFace = pallet.fontFace()
                        text.Text = subText
                        text.TextColor3 = Color3.fromRGB(222, 220, 222)
                        text.TextSize = 11
                        text.TextXAlignment = Enum.TextXAlignment.Left
                    end

                    function optionapi:Save(data)
                        data[optionapi.Name] = {
                            Enabled = optionapi.Enabled
                        }
                    end

                    function optionapi:Load(data)
                        optionapi:Toggle(data.Enabled)
                    end

                    function optionapi:Select(bool)
                        if bool == nil then bool = not optionapi.Selected end
                        if bool == optionapi.Selected then return end

                        toggleapi:Select(bool)
                    end

                    function optionapi:Toggle(bool)
                        if bool == nil then bool = not optionapi.Enabled end
                        if bool == optionapi.Enabled then return end
                        optionapi.Enabled = bool
                        toggle.BackgroundTransparency = bool and 1 or 0
                        toggle.ImageTransparency = bool and 0 or 1
                        uiGradient.Enabled = not bool

                        task.spawn(function()
                            local suc, res = pcall(function()
                                return callback(bool)
                            end)
                            if not suc then warn('ProjectMonterey: an error occured while enabling option toggle: ', res) end
                        end)
                        task.spawn(function()
                            if not bool then
                                for _, v in next, optionapi.connections do
                                    v:Disconnect()
                                end
                            end
                        end)
                    end

                    optionapi:Toggle(enabled)

                    library:Clean(toggle.MouseButton1Click:Connect(optionapi.Toggle))

                    return optionapi
                end
                function toggleapi:CreateDropdown(args)
                    local name = args.Name
                    local list = args.List
                    local current = args.Default or list[1]
                    local currentOption
                    local callback = args.Callback or function() end
                    local visible = args.Visible == nil and true or args.Visible
                    local dropdownapi = {
                        Name =  name,
                        List = list,
                        Value = current,
                        Expanded = false,
                        Callback = callback
                    }
                    dropdownapi.Options = setmetatable({}, {
                        __index = dropdownapi.ReSize
                    })
                    library:addClean(dropdownapi)
                    table.insert(toggleapi.Options, dropdownapi)

                    local dropdown = Instance.new('Frame', container)
                    dropdown.BackgroundTransparency = 1
                    dropdown.BorderSizePixel = 0
                    dropdown.LayoutOrder = #toggleapi.Options
                    dropdown.Size = UDim2.new(1, 0, 0, 28)
                    dropdown.Visible = visible
                    dropdownapi.container = dropdown
                    local text = Instance.new('TextLabel', dropdown)
                    text.BackgroundTransparency = 1
                    text.BorderSizePixel = 0
                    text.Position = UDim2.fromOffset(16, 0)
                    text.Size = UDim2.new(1, -34, 1, 0)
                    text.FontFace = pallet.fontFace()
                    text.Text = string.find(name, ':') and name or name..':'
                    text.TextColor3 = Color3.fromRGB(222, 220, 222)
                    text.TextSize = 12
                    text.TextXAlignment = Enum.TextXAlignment.Left
                    local holder = Instance.new('Frame', dropdown)
                    holder.Name = 'holder'
                    holder.BackgroundColor3 = Color3.fromRGB(90, 85, 94)
                    holder.BorderSizePixel = 0
                    holder.Position = UDim2.fromOffset(library:getTextSize(text.Text, text.FontFace, 12).X + 20, 4)
                    holder.Size = UDim2.fromOffset(168, 20)
                    addCorner(holder, UDim.new(0, 4))
                    local expandButton = Instance.new('TextButton', holder)
                    expandButton.BackgroundTransparency = 1
                    expandButton.BorderSizePixel = 0
                    expandButton.Size = UDim2.fromScale(1, 1)
                    expandButton.Text = ''
                    local arrowsHolder = Instance.new('Frame', holder)
                    arrowsHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    arrowsHolder.BorderSizePixel = 0
                    arrowsHolder.Position = UDim2.new(1, -18, 0, 2)
                    arrowsHolder.Size = UDim2.fromOffset(16, 16)
                    addCorner(arrowsHolder, UDim.new(0, 4))
                    local uiGradient = components.uiGradient(arrowsHolder,
                        ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(23, 104, 229)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 93, 205))},
                        90
                    )
                    local arrowUp = Instance.new('ImageButton', arrowsHolder)
                    arrowUp.BackgroundTransparency = 1
                    arrowUp.BorderSizePixel = 0
                    arrowUp.Position = UDim2.fromOffset(4, 2)
                    arrowUp.Size = UDim2.fromOffset(8, 5)
                    arrowUp.Image = getcustomasset('ProjectMonterey/Assets/Gui/DropdownArrowUp.png')
                    local arrowDown = arrowUp:Clone()
                    arrowDown.Parent = arrowsHolder
                    arrowDown.Position = UDim2.fromOffset(4, 9)
                    arrowDown.Image = getcustomasset('ProjectMonterey/Assets/Gui/DropdownArrowDown.png')
                    local currentText = Instance.new('TextLabel', holder)
                    currentText.Name = 'currentText'
                    currentText.BackgroundTransparency = 1
                    currentText.BorderSizePixel = 0
                    currentText.Position = UDim2.fromOffset(8, 0)
                    currentText.Size = UDim2.new(1, -8, 1, 0)
                    currentText.FontFace = pallet.fontFace()
                    currentText.Text = current
                    currentText.TextColor3 = Color3.fromRGB(231, 230, 231)
                    currentText.TextSize = 12
                    currentText.TextXAlignment = Enum.TextXAlignment.Left
                    local optionsHolder = Instance.new('Frame', dropdownsFolder) --holder
                    optionsHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    optionsHolder.BorderSizePixel = 0
                    optionsHolder.Position = UDim2.fromOffset(-5, -3)
                    optionsHolder.Size = UDim2.new(1, 0, 0, 0)
                    optionsHolder.Visible = false
                    addCorner(optionsHolder, UDim.new(0, 6))
                    components.uiStroke(optionsHolder, Color3.fromRGB(), 2)
                    local uiGradient = components.uiGradient(optionsHolder,
                        ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(56, 50, 64)), ColorSequenceKeypoint.new(1, Color3.fromRGB(47, 41, 55))},
                        90
                    )
                    local container = Instance.new('Frame', optionsHolder)
                    container.BackgroundTransparency = 1
                    container.BorderSizePixel = 0
                    container.Size = UDim2.fromScale(1, 1)
                    addCorner(container, UDim.new(0, 6))
                    components.uiStroke(container, Color3.fromRGB(96, 94, 100))
                    local uiListLayout = components.uiListLayout(container)
                    components.uiPadding(container, 4)

                    function dropdownapi:Save(data)
                        data[dropdownapi.Name] = {
                            Value = dropdownapi.Value
                        }
                    end

                    function dropdownapi:Load(data)
                        dropdownapi:Set(data.Value, true)
                    end

                    function dropdownapi:Select(bool)
                        if bool == nil then bool = not dropdownapi.Selected end
                        if bool == dropdownapi.Selected then return end

                        toggleapi:Select(bool)
                    end

                    function dropdownapi:Set(name, load)
                        if not table.find(list, name) then return end
                        local data = dropdownapi.Options[name]
                        dropdownapi.Value = name
                        currentText.Text = name
                        for _, optionData in next, dropdownapi.Options do
                            optionData.checkMark.ImageTransparency = optionData.name == name and 0 or 1
                        end
                        task.spawn(function()
                            dropdownapi:Expand(false)
                            dropdownapi:RePosition()
                        end)
                        task.spawn(function()
                            local suc, res = pcall(function()
                                return dropdownapi.Callback(name, load)
                            end)
                            if not suc then warn('ProjectMonterey: an error occured while setting dropdown: ', res) end
                        end)
                        task.spawn(function()
                            for _, connection in next, dropdownapi.connections do
                                connection:Disconnect()
                            end
                        end)
                    end

                    function dropdownapi:Expand(bool)
                        if bool == nil then bool = not dropdownapi.Expanded end
                        dropdownapi.Expanded = bool
                        optionsHolder.Visible = bool
                    end

                    function dropdownapi:CreateOption(name)
                        if not table.find(list, name) or dropdownapi.Options[name] then return end
                        local holder = Instance.new('Frame', container)
                        holder.BackgroundTransparency = 1
                        holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        holder.BorderSizePixel = 0
                        holder.Size = UDim2.new(1, -8, 0, 22)
                        holder.LayoutOrder = #dropdownapi.Options
                        addCorner(holder, UDim.new(0, 4))
                        local uiGradient = components.uiGradient(holder,
                            ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(29, 96, 203)), ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 94, 200))},
                            90,
                            false
                        )
                        local checkMark = Instance.new('ImageLabel', holder)
                        checkMark.BackgroundTransparency = 1
                        checkMark.BorderSizePixel = 0
                        checkMark.Size = UDim2.fromOffset(9, 9)
                        checkMark.Position = UDim2.fromOffset(4, 7)
                        checkMark.Image = getcustomasset('ProjectMonterey/Assets/Gui/PlainCheckMark.png')
                        checkMark.ImageTransparency = 1
                        local text = Instance.new('TextLabel', holder)
                        text.BackgroundTransparency = 1
                        text.Size = UDim2.new(1, -19, 1, 0)
                        text.Position = UDim2.fromOffset(18, 0)
                        text.FontFace = pallet.fontFace()
                        text.Text = name
                        text.TextColor3 = Color3.fromRGB(255, 255, 255)
                        text.TextSize = 12
                        text.TextXAlignment = Enum.TextXAlignment.Left
                        local button = Instance.new('TextButton', holder)
                        button.BackgroundTransparency = 1
                        button.BorderSizePixel = 0
                        button.Size = UDim2.new(1, 8, 1, 0)
                        button.Position = UDim2.fromOffset(-4, 0)
                        button.Text = ''
                        table.insert(dropdownapi.Options, {
                            name = name,
                            holder = holder,
                            uiGradient = uiGradient,
                            checkMark = checkMark,
                            text = text,
                            button = button
                        })

                        library:setZIndex(optionsHolder, 15)
                        library:Clean(holder.MouseEnter:Connect(function()
                            holder.BackgroundTransparency = 0
                            uiGradient.Enabled = true
                        end))
                        library:Clean(holder.MouseLeave:Connect(function()
                            holder.BackgroundTransparency = 1
                            uiGradient.Enabled = false
                        end))
                        library:Clean(button.MouseButton1Click:Connect(function()
                            dropdownapi:Set(name)
                        end))
                    end

                    function dropdownapi:ReSize()
                        local textSize = library:getTextSize(library:getLongestValue(list), currentText.FontFace, currentText.TextSize)
                        holder.Size = UDim2.fromOffset((textSize.X > 100 and textSize.X or 100) + 30, 20) --30 is supposed to be 24 but due to some stuff its 30
                        optionsHolder.Size = UDim2.fromOffset((textSize.X > 100 and textSize.X or 100) + 30, uiListLayout.AbsoluteContentSize.Y + 8)
                    end

                    function dropdownapi:RePosition()
                        for _, option in next, dropdownapi.Options do
                            if option.name == dropdownapi.Value then
                                optionsHolder.Position = UDim2.fromOffset(holder.AbsolutePosition.X -5, holder.AbsolutePosition.Y -(22 * option.holder.LayoutOrder + 3))
                            end
                        end
                    end

                    library:setZIndex(arrowsHolder, 5)
                    library:setZIndex(optionsHolder, 20)

                    library:Clean(holder:GetPropertyChangedSignal('AbsolutePosition'):Connect(dropdownapi.RePosition))
                    library:Clean(uiListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(dropdownapi.ReSize))
                    library:Clean(expandButton.MouseButton1Click:Connect(dropdownapi.Expand))

                    for _, v in next, list do
                        dropdownapi:CreateOption(v)
                    end
                    dropdownapi:Set(current)

                    return dropdownapi
                end
                function toggleapi:CreateSlider(args)
                    local name = args.Name
                    local min = args.Min
                    local max = args.Max
                    local decimal = args.Decimal or 0
                    local default = args.Default or min
                    local suffix = args.Suffix
                    local suffixEnding = args.SuffixEnding
                    local dividersAmount = args.DividersAmount
                    local dividers = {}
                    local callback = args.Callback or function() end
                    local visible = args.Visible == nil and true or args.Visible
                    local sliderapi = {
                        Name = name,
                        Value = default,
                        Callback = callback
                    }
                    library:addClean(sliderapi)
                    table.insert(toggleapi.Options, sliderapi)

                    local slider = Instance.new('Frame', container)
                    slider.BackgroundTransparency = 1
                    slider.BorderSizePixel = 0
                    slider.LayoutOrder = #toggleapi.Options
                    slider.Size = UDim2.new(1, 0, 0, 54)
                    slider.Visible = visible
                    sliderapi.container = slider
                    local text = Instance.new('TextLabel', slider)
                    text.BackgroundTransparency = 1
                    text.BorderSizePixel = 0
                    text.Position = UDim2.fromOffset(24, 2)
                    text.Size = UDim2.new(1, -92, 0, 9)
                    text.FontFace = pallet.fontFace()
                    text.Text = name
                    text.TextColor3 = Color3.fromRGB(222, 221, 223)
                    text.TextSize = 12
                    text.TextXAlignment = Enum.TextXAlignment.Left
                    local currentText = text:Clone()
                    currentText.Parent = slider
                    currentText.TextXAlignment = Enum.TextXAlignment.Right
                    currentText.Text = '0 '..(suffix and (typeof(suffix) == 'string' and tostring(suffix) or suffix(default)) or '')
                    local line = Instance.new('Frame', slider)
                    line.BackgroundColor3 = Color3.fromRGB(63, 58, 69)
                    line.BorderSizePixel = 0
                    line.Position = UDim2.fromOffset(23, 26)
                    line.Size = UDim2.new(1, -92, 0, 4)
                    local dragBar = Instance.new('TextButton', line)
                    dragBar.BackgroundColor3 = Color3.fromRGB(148, 146, 152)
                    dragBar.BorderSizePixel = 0
                    dragBar.Position = UDim2.fromOffset(-4, -8)
                    dragBar.Size = UDim2.fromOffset(8, 20)
                    dragBar.Text = ''
                    dragBar.ZIndex = 5
                    addCorner(dragBar, UDim.new(0, 4))

                    local function getSuffix(value)
                        value = value or sliderapi.Value
                        return suffix and (typeof(suffix) == 'string' and (suffixEnding and (value == 1 and suffix or suffix..'s') or suffix or '') or suffix(value)) or ''
                    end

                    local function createDivider(value, position)
                        local dividerBar = Instance.new('Frame', line)
                        dividerBar.BackgroundColor3 = Color3.fromRGB(84, 79, 89)
                        dividerBar.BorderSizePixel = 0
                        dividerBar.Position = position
                        dividerBar.Size = UDim2.fromOffset(2, 8)
                        table.insert(dividers, dividerBar)
                        local dividerBarText = Instance.new('TextLabel', dividerBar)
                        dividerBarText.BackgroundTransparency = 1
                        dividerBarText.BorderSizePixel = 0
                        dividerBarText.Position = UDim2.new(0, 0, 1, 7)
                        dividerBarText.Size = UDim2.fromOffset(10, 10)
                        dividerBarText.FontFace = pallet.fontFace()
                        dividerBarText.Text = value..' '..getSuffix(value)
                        dividerBarText.TextColor3 = Color3.fromRGB(222, 221, 223)
                        dividerBarText.TextSize = 11
                        dividerBarText.TextXAlignment = Enum.TextXAlignment.Left
                    end

                    if dividersAmount then
                        --if typeof(dividersAmount) == 'number' then
                            createDivider(0, UDim2.new(0, 0, 0, -2))
                            for i = 1, dividersAmount do
                                local xScale = i / dividersAmount
                                createDivider(math.floor((max / dividersAmount  * i) * 10) / 10, UDim2.new(xScale, 0, 0, -2))
                            end
                        --[[else
                            for _, v in next, dividersAmount do
                                --if typeof
                            end
                        end]]
                    end

                    function sliderapi:Save(data)
                        data[sliderapi.Name] = {
                            Value = sliderapi.Value
                        }
                    end

                    function sliderapi:Load(data)
                        sliderapi:Set(data.Value)
                    end

                    function sliderapi:Select(bool)
                        if bool == nil then bool = not sliderapi.Selected end
                        if bool == sliderapi.Selected then return end

                        toggleapi:Select(bool)
                    end

                    function sliderapi:Set(value)
                        if not value then return end
                        local x = (math.floor((math.clamp(value, min, max) * (10 ^ decimal)) + 0.5) / (10 ^ decimal) -  min) / (max - min)

                        sliderapi.Value = value
                        currentText.Text = value..' '..getSuffix()
                        dragBar.Position = UDim2.new(x, 0, 0, -8)

                        task.spawn(function()
                            local suc, res = pcall(function()
                                return callback(value)
                            end)
                            if not suc then warn('ProjectMonterey: an error occured while setting slider: ', res) end
                        end)
                    end

                    local sliding = false
                    local function slide(input)
                        local x = math.clamp((input.Position.X - line.AbsolutePosition.X) / line.AbsoluteSize.X, 0, 1)
                        local value = math.floor(((((max - min) * x) + min) * (10 ^ decimal)) + 0.5) / (10 ^ decimal) --x == 1 and max or math.floor(((max - min) * x * (10 ^ decimal) + 0.5) / (10 ^ decimal))

                        sliderapi.Value = value
                        currentText.Text = value..' '..getSuffix()
                        dragBar.Position = UDim2.new(x, -4, 0, -8)

                        task.spawn(function()
                            local suc, res = pcall(function()
                                return callback(value)
                            end)
                            if not suc then warn('ProjectMonterey: an error occured while setting slider: ', res) end
                        end)
                    end

                    local function hookDrag(obj)
                        library:Clean(obj.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                sliding = true
                                slide(input)
                            end
                        end))
                        library:Clean(userInputService.InputChanged:Connect(function(input)
                            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                                sliding = true
                                slide(input)
                            end
                        end))
                        library:Clean(obj.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                sliding = false
                            end
                        end))
                    end
                    hookDrag(line)
                    hookDrag(dragBar)
                    sliderapi:Set(default)

                    return sliderapi
                end
                function toggleapi:CreateColorPicker(args) -- // made with models/scripts for 2-3 dev forums
                    local name = args.Name
                    local default = args.Default or Color3.fromHSV(0, 0, 1)
                    local visible = args.Visible == nil and true or args.Visible
                    local callback = args.Callback or function() end
                    local colorsList = args.ColorsList or {
                        Black = Color3.fromHSV(0, 0, 0),
                        Blue = Color3.fromHSV(0.6, 1, 1),
                        Brown = Color3.fromHSV(0.075, 0.75, 0.35),
                        Green = Color3.fromHSV(0.24, 1, 1),
                        Grey = Color3.fromHSV(0, 0, 0.5),
                        Orange = Color3.fromHSV(0.1, 0.9, 1),
                        Pink = Color3.fromHSV(0.9, 1, 1),
                        Purple = Color3.fromHSV(0.8, 1.0, 0.8),
                        Red = Color3.fromHSV(0, 1, 1),
                        White = Color3.fromHSV(0, 0, 1),
                        Yellow = Color3.fromHSV(0.2, 1, 1)
                    }
                    local rawColors = args.RawColors or {'Black', 'Blue', 'Brown', 'Green', 'Grey', 'Orange', 'Pink', 'Purple', 'Red', 'White', 'Yellow'}
                    table.insert(rawColors, 'Custom')

                    local dropdown = toggleapi:CreateDropdown({
                        Name = name,
                        List = rawColors,
                        Visible = visible
                    })
                    local colorpickerapi = {
                        Name = name,
                        Value = default,
                        ValueMode = 'unknown',
                        WheelValue = default,
                        Callback = callback,
                        ColorsList = colorsList,
                        RawColors = rawColors,
                        Dropdown = dropdown
                    }

                    local customColorBox, customuiStroke
                    for _, option in next, dropdown.Options do
                        local color = option.name == 'Custom' and colorpickerapi.Value or colorsList[option.name]
                        local h, s, v = color:ToHSV()
                        local colorBox = Instance.new('Frame', option.holder)
                        colorBox.BackgroundColor3 = color
                        colorBox.BorderSizePixel = 0
                        colorBox.Size = UDim2.fromOffset(22, 10) --17 + 22
                        colorBox.Position = UDim2.fromOffset(19, 6)
                        local uiStroke = components.uiStroke(colorBox, Color3.fromHSV(h, s - 0.2, v))
                        option.uiStroke = uiStroke
                        option.text.Position = UDim2.fromOffset(48, 0)
                        option.color = color
                        library:setZIndex(option.holder, 15)

                        if option.name == 'Custom' then
                            customColorBox = colorBox
                            customuiStroke = uiStroke
                        end
                    end

                    local colorBox = Instance.new('Frame', dropdown.container.holder)
                    colorBox.BackgroundColor3 = colorpickerapi.Value
                    colorBox.BorderSizePixel = 0
                    colorBox.Size = UDim2.fromOffset(22, 10) --17 + 22
                    colorBox.Position = UDim2.fromOffset(8, 5)
                    local h, s, v = colorpickerapi.Value:ToHSV()
                    local uiStroke = components.uiStroke(colorBox, Color3.fromHSV(h, s - 0.2, v))
                    dropdown.container.holder.currentText.Position = UDim2.fromOffset(34, 0)
                    dropdown.container.holder.currentText.Size = UDim2.new(1, -34, 1, 0)

                    local background = Instance.new('Frame', colorPickersFolder)
                    background.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    background.BorderSizePixel = 0
                    background.Position = UDim2.fromOffset(200, 600)
                    background.Size = UDim2.new(0, 224, 0, 330)
                    background.Visible = false
                    addCorner(background, UDim.new(0, 11))
                    local topBar = Instance.new('Frame', background)
                    topBar.BackgroundColor3 = Color3.fromRGB(56, 55, 58)
                    topBar.BorderSizePixel = 0
                    topBar.Size = UDim2.new(1, 0, 0, 18)
                    addCorner(topBar, UDim.new(0, 11))
                    library:dragGui(background, topBar)
                    local trafficLight = Instance.new('Frame', topBar)
                    trafficLight.BackgroundTransparency = 1
                    trafficLight.BorderSizePixel = 0
                    trafficLight.Position = UDim2.fromOffset(4, 4)
                    trafficLight.Size = UDim2.fromOffset(39, 9)
                    local redButton = Instance.new('ImageButton', trafficLight)
                    redButton.AutoButtonColor = false
                    redButton.BackgroundColor3 = Color3.fromRGB(238, 92, 84)
                    redButton.BorderSizePixel = 0
                    redButton.Size = UDim2.fromOffset(9, 9)
                    redButton.Image = ''
                    addCorner(redButton, UDim.new(1, 0))
                    local redButtonIcon = Instance.new('ImageButton', redButton)
                    redButtonIcon.BackgroundTransparency = 1
                    redButtonIcon.BorderSizePixel = 0
                    redButtonIcon.Size = UDim2.fromOffset(5, 5)
                    redButtonIcon.Position = UDim2.fromOffset(2, 2)
                    redButtonIcon.Image = getcustomasset('ProjectMonterey/Assets/Gui/TrafficLight/SmallClose.png')
                    redButtonIcon.ImageTransparency = 1
                    local redButtonHitbox = Instance.new('TextButton', redButton)
                    redButtonHitbox.AutoButtonColor = false
                    redButtonHitbox.BackgroundTransparency = 1
                    redButtonHitbox.BorderSizePixel = 0
                    redButtonHitbox.Size = UDim2.fromScale(1, 1)
                    redButtonHitbox.Text = ''
                    local grayButton = Instance.new('TextLabel', trafficLight)
                    grayButton.BackgroundColor3 = Color3.fromRGB(92, 91, 94)
                    grayButton.BorderSizePixel = 0
                    grayButton.Position = UDim2.fromOffset(15, 0)
                    grayButton.Size = UDim2.fromOffset(9, 9)
                    grayButton.Text = ''
                    addCorner(grayButton, UDim.new(1, 0))
                    local grayButton2 = grayButton:Clone()
                    grayButton2.Parent = trafficLight
                    grayButton2.Position = UDim2.fromOffset(30, 0)
                    local title = Instance.new('TextLabel', topBar)
                    title.BackgroundTransparency = 1
                    title.BorderSizePixel = 0
                    title.Position = UDim2.fromOffset(47, 4)
                    title.Size = UDim2.new(1, -47, 0, 8)
                    title.Font = Enum.Font.SourceSans
                    title.Text = name..' ('..toggleapi.Name..' ('..tabapi.Name..'))' --"Цвета (Основные (Системные..."
                    title.TextColor3 = Color3.fromRGB(170, 169, 172)
                    title.TextSize = 14
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    local divider = Instance.new('Frame', background)
                    divider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    divider.BorderSizePixel = 0
                    divider.Position = UDim2.fromOffset(0, 19)
                    divider.Size = UDim2.new(1, 0, 0, 1)
                    local colorWheel = Instance.new('ImageButton', background)
                    colorWheel.AutoButtonColor = false
                    colorWheel.BackgroundTransparency = 1
                    colorWheel.BorderSizePixel = 0
                    colorWheel.Position = UDim2.fromOffset(10, 31)
                    colorWheel.Size = UDim2.fromOffset(204, 204)
                    colorWheel.Image = getcustomasset('ProjectMonterey/Assets/Gui/ColorWheel.png')--'rbxassetid://6020299385'
                    addCorner(colorWheel, UDim.new(1, 0))
                    local picker = Instance.new('ImageLabel', colorWheel)
                    picker.BackgroundTransparency = 1
                    picker.BorderSizePixel = 0
                    picker.Size = UDim2.fromOffset(15, 15)
                    picker.Image = getcustomasset('ProjectMonterey/Assets/Gui/ColorPicker.png')
                    local darknessLine = Instance.new('TextButton', background)
                    darknessLine.BorderSizePixel = 0
                    darknessLine.Position = UDim2.fromOffset(11, 252)
                    darknessLine.Size = UDim2.fromOffset(202, 11)
                    darknessLine.AutoButtonColor = false
                    darknessLine.Text = ''
                    addCorner(darknessLine, UDim.new(0, 3))
                    local uiGradient = components.uiGradient(darknessLine)
                    uiGradient.Rotation = 0
                    local knob = Instance.new('TextButton', darknessLine)
                    knob.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
                    knob.BorderSizePixel = 0
                    knob.Position = UDim2.fromOffset(0, -3)
                    knob.Size = UDim2.fromOffset(8, 16)
                    knob.Text = ''
                    addCorner(knob, UDim.new(0, 8))
                    local divider2 = divider:Clone()
                    divider2.Parent = background
                    divider2.Position = UDim2.fromOffset(0, 273)
                    local currentColor = Instance.new('Frame', background)
                    currentColor.BorderSizePixel = 0
                    currentColor.Position = UDim2.fromOffset(10, 282)
                    currentColor.Size = UDim2.fromOffset(25, 25)
                    addCorner(currentColor, UDim.new(0, 6))

                    dropdown.Callback = function(callback, load)
                        if load then return end
                        background.Visible = callback == 'Custom'
                        local value = callback == 'Custom' and colorpickerapi.WheelValue or colorsList[callback]
                        colorpickerapi.Value = value
                        colorBox.BackgroundColor3 = value
                        local h, s, v = value:ToHSV()
                        uiStroke.Color = Color3.fromHSV(h, s - 0.2, v)
                    end

                    function colorpickerapi:Save(data)
                        data[colorpickerapi.Name] = {
                            Value = colorpickerapi.Value
                        }
                    end

                    function colorpickerapi:Load(data)
                        local value = data.Value
                        if value then
                            local h, s, v = value:ToHSV()
                            colorpickerapi:Set(h, s, v, true)
                        end
                    end

                    function colorpickerapi:Set(value, s, v, load)
                        local fromList, h
                        if typeof(value) == 'Color3' then
                            h, s, v = value:ToHSV()
                        else
                            h = value
                        end

                        value = Color3.fromHSV(h, s, v)
                        for name, color in next, colorsList do
                            if value:ToHSV() == color:ToHSV() then
                                fromList = true
                                break
                            end
                        end

                        colorpickerapi.ValueMode = fromList and 'List' or 'Custom'
                        h = h * math.pi * 2
                        h = Vector2.new(-math.cos(h) / 2 * s, math.sin(h) / 2 * s)
                        picker.Position = UDim2.fromScale(0.5 + h.X, 0.5 + h.Y)
                        picker.Position = UDim2.fromScale(0, 1 - v)
                        customColorBox.BackgroundColor3 = value
                        customuiStroke.Color = Color3.fromHSV(h, s - 0.2, v)
                        colorBox.BackgroundColor3 = value
                        uiStroke.Color = Color3.fromHSV(h, s - 0.2, v)
                        currentColor.BackgroundColor3 = value
                        uiGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, value),
                            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                        }

                        for _, option in next, dropdown.Options do
                            if option.color == value then
                                dropdown:Set(option.name, load)
                            end
                        end
                    end

                    local function move(wheelCenter)
                        local center = Vector2.new(picker.AbsolutePosition.X + picker.AbsoluteSize.X / 2, picker.AbsolutePosition.Y + picker.AbsoluteSize.Y / 2)
                        local h = (math.pi - math.atan2(wheelCenter.Y - center.Y, wheelCenter.X - center.X)) / (math.pi * 2)
                        local s = (center - wheelCenter).Magnitude / (colorWheel.AbsoluteSize.X / 2)
                        local v = 1 - knob.Position.X.Scale
                        local value = Color3.fromHSV(h, s, v)

                        colorpickerapi.Value = value
                        customColorBox.BackgroundColor3 = value
                        customuiStroke.Color = Color3.fromHSV(h, s - 0.2, v)
                        colorBox.BackgroundColor3 = value
                        uiStroke.Color = Color3.fromHSV(h, s - 0.2, v)
                        currentColor.BackgroundColor3 = value
                        uiGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, value),
                            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                        }

                        task.spawn(function()
                            colorpickerapi.Callback(value)
                        end)
                    end

                    local function slide(input)
                        local v = math.clamp((input.Position.X - darknessLine.AbsolutePosition.X) / darknessLine.AbsoluteSize.X, 0, 1)
                        local h, s, _ = colorpickerapi.Value:ToHSV()
                        local value = Color3.fromHSV(h, s, 1 - v)

                        colorpickerapi.Value = value
                        knob.Position = UDim2.new(v, -4, 0, -3)
                        customColorBox.BackgroundColor3 = value
                        customuiStroke.Color = Color3.fromHSV(h, s - 0.2, v)
                        colorBox.BackgroundColor3 = value
                        uiStroke.Color = Color3.fromHSV(h, s - 0.2, 1 - v)
                        currentColor.BackgroundColor3 = value
                        uiGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, value),
                            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                        }

                        task.spawn(function()
                            local suc, res = pcall(function()
                                return colorpickerapi.Callback(value)
                            end)
                            if not suc then warn('ProjectMonterey: an error occured while setting color picker: ', res) end
                        end)
                    end


                    local sliding = false
                    local function hookDrag(obj)
                        library:Clean(obj.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                sliding = true
                                slide(input)
                            end
                        end))
                        library:Clean(userInputService.InputChanged:Connect(function(input)
                            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                                sliding = true
                                slide(input)
                            end
                        end))
                        library:Clean(obj.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                sliding = false
                            end
                        end))
                    end
                    hookDrag(darknessLine)
                    hookDrag(knob)

                    local holding = false
                    library:Clean(colorWheel.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            holding = true
                        end
                    end))
                    library:Clean(userInputService.InputChanged:Connect(function(input)
                        if holding and input.UserInputType == Enum.UserInputType.MouseMovement then
                            if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                            local mousePos = userInputService:GetMouseLocation() - Vector2.new(0, guiService:GetGuiInset().Y)
                            local absolutePos, absoluteSize = colorWheel.AbsolutePosition, colorWheel.AbsoluteSize
                            local center = Vector2.new(absolutePos.X + absoluteSize.X / 2, absolutePos.Y + absoluteSize.Y / 2)
                            local magnitude = (mousePos - center).Magnitude
                            if magnitude <= absoluteSize.X / 2 then
                                picker.Position = UDim2.new(0, mousePos.X - absolutePos.X, 0, mousePos.Y - absolutePos.Y)
                            end
                            move(center)
                        end
                    end))
                    library:Clean(colorWheel.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            holding = false
                        end
                    end))
                    library:Clean(redButtonHitbox.MouseEnter:Connect(function()
                        redButtonIcon.ImageTransparency = 0
                    end))
                    library:Clean(redButtonHitbox.MouseLeave:Connect(function()
                        redButtonIcon.ImageTransparency = 1
                    end))
                    library:Clean(redButtonHitbox.MouseButton1Click:Connect(function()
                        background.Visible = false
                    end))

                    local h, s, v = default:ToHSV()
                    colorpickerapi:Set(h, s, v, true)

                    return colorpickerapi
                end
                return toggleapi
            end
            function tabapi:CreateCustomPage(args)
                local name = args.Name
                local title = args.Title or name
                local topHolder = args.TopHolder or false
                local shortDescription = args.ShortDescription or ''
                local longDescription = args.LongDescription or ''
                local icon = args.Icon
                local iconSize = args.IconSize
                local pageapi = {
                    Name = name,
                    Unsaveable = true,
                    Selected = false,
                    Options = {}
                }
                library:addClean(pageapi)
                table.insert(tabapi.Toggles, pageapi)

                local holder = Instance.new('Frame', togglesContainer)
                holder.BackgroundTransparency = 1--0.880
                holder.BorderSizePixel = 0
                holder.LayoutOrder = #tabapi.Toggles --// todo: make toggles sort in alphabetical order if its in monterey
                holder.Size = UDim2.new(0, 154, 0, 50)
                addCorner(holder, UDim.new(0, 8))
                pageapi.container = holder
                local iconImage = Instance.new('ImageLabel', holder)
                iconImage.BackgroundTransparency = 1
                iconImage.BorderSizePixel = 0
                iconImage.Position = iconSize and UDim2.fromOffset(18 - iconSize.X.Offset / 2, 25 - iconSize.Y.Offset / 2) or UDim2.fromOffset(0, 0)
                iconImage.Size = iconSize or UDim2.fromOffset(1, 1)
                iconImage.Image = icon and (isfile(icon) and getcustomasset(icon) or icon) or ''
                local titleLabel = Instance.new('TextLabel', holder)
                titleLabel.BackgroundTransparency = 1
                titleLabel.BorderSizePixel = 0
                titleLabel.Position = UDim2.fromOffset(37, 15)
                titleLabel.Size = UDim2.new(1, -37, 0, 12)
                titleLabel.FontFace = pallet.fontFace('Medium')
                titleLabel.Text = title
                titleLabel.TextColor3 = Color3.fromRGB(193, 193, 193)
                titleLabel.TextSize = 13
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                local descriptionLabel = Instance.new('TextLabel', holder)
                descriptionLabel.Name = 'descriptionLabel'
                descriptionLabel.BackgroundTransparency = 1
                descriptionLabel.BorderSizePixel = 0
                descriptionLabel.Position = UDim2.fromOffset(37, 29)
                descriptionLabel.Size = UDim2.new(1, -37, 0, 12)
                descriptionLabel.FontFace = pallet.fontFace()
                descriptionLabel.Text = shortDescription
                descriptionLabel.TextColor3 = Color3.fromRGB(193, 193, 193)
                descriptionLabel.TextSize = 12
                descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
                local openButton = Instance.new('TextButton', holder)
                openButton.BackgroundTransparency = 1
                openButton.BorderSizePixel = 0
                openButton.Size = UDim2.fromScale(1, 1)
                openButton.Text = ''

                local textSize = library:getTextSize(shortDescription, descriptionLabel.FontFace, 12)
                holder.Size = UDim2.new(0, 154, 0, 38 + textSize.Y)

                local holder2
                if topHolder then
                    holder2 = holder:Clone()
                    holder2.Parent = optionsContainer
                    holder2.LayoutOrder = 1
                    holder2.Size = UDim2.new(1, 0, 0, 50)
                    holder2.Visible = false
                    addCorner(holder2, UDim.new(0, 8))
                    pageapi.optionsHolder = holder2
                    holder2.descriptionLabel.Text = longDescription
                end

                local container = Instance.new('Frame', holder2 or optionsContainer)
                container.AutomaticSize = Enum.AutomaticSize.Y
                container.BackgroundTransparency = 1
                container.BorderSizePixel = 0
                container.Size = UDim2.fromScale(1, 0)
                container.Position = UDim2.fromOffset(0, holder2 and 50 or 0)
                container.Visible = false
                --components.uiListLayout(container)
                pageapi.optionsContainer = container

                if not holder2 then pageapi.optionsHolder = container end

                function pageapi:Select(bool)
                    if bool == nil then bool = not pageapi.Selected end
                    if bool == pageapi.Selected then return end

                    if bool then
                        togglesContainer.CanvasPosition = Vector2.new(0, 10 + (-1 + library:getIndex(tabapi.Toggles, pageapi)) * 50)
                    end

                    return tabapi:SelectToggle(name, bool)
                end

                local mainObj = holder2 and holder2 or container

                library:Clean(mainObj:GetPropertyChangedSignal('Visible'):Connect(function()
                    holder.BackgroundTransparency = mainObj.Visible and 0.88 or 1
                end))

                library:Clean(openButton.MouseButton1Click:Connect(function()
                    if pageapi.Selected then
                        mainObj.Visible = false
                        pageapi.Selected = false
                    else
                        tabapi:SelectToggle(name, true)
                    end
                end))

                return pageapi
            end
        end

        return tabapi
    end

    return windowapi
end

library:Clean(userInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == library.Bind then
            library:Hide()
        end
    end
end))

return library