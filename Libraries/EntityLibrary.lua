local api = {
	loaded = false,
    head = nil,
    root = nil,
	humanoid = nil,
    character = nil,
    health = 0,
	tool = nil,
    players = {},
    connections = {}
}

local raw = {
	alive = false,
	character = nil,
	displayName = nil,
	head = nil,
	health = 0,
	hipHeight = 0,
	humanoid = nil,
	maxHealth = 0,
	name = nil,
	root = nil,
	targetable = false,
	team = nil,
	teamColor = nil,
	teammate = false
}

local userInputService = cloneref(game:GetService('UserInputService'))
local players = cloneref(game:GetService('Players'))
local lplr = players.LocalPlayer
local camera = workspace.CurrentCamera

-- // current shit to do: add wait for child function to fix humanoid hp setting to 0 when character added is fired

local function getChild(child: any, parent: Instance, timeout: number, class: boolean, property: boolean) --here doing like so so its easier to use
	if not child or not parent then return end
	timeout = timeout or 15
	local time = tick()
	local instance
	repeat
		instance = (property and parent[child]) or (class and parent:FindFirstChildOfClass(child)) or parent:FindFirstChild(child)
		task.wait()
	until tick() - time > timeout or instance
	return instance, tick() - time > timeout
end

local function disconnect(connection)
	if not connection then return end
	if typeof(connection) == 'RBXScriptConnection' then
		connection:Disconnect()
	elseif connection.Disconnect then
		connection:Disconnect()
	elseif typeof(connection) == 'table' then
		for _, v in next, connection do
			if typeof(v) == 'RBXScriptConnection' then
				v:Disconnect()
			elseif v.Disconnect then
				v.Disconnect()
			end
		end
	end
end

function api.isAlive(plr, headCheck)
	plr = plr or lplr
	local character = api.getCharacter(plr)
	if character and ((character:FindFirstChildOfClass('Humanoid')) and character:FindFirstChild('HumanoidRootPart') and (headCheck and character:FindFirstChild('Head') or not headCheck)) then
		return true
	else
		return false
	end
end

function api.getCharacter(plr, timeout)
	plr = plr or lplr
	if typeof(plr) == 'Instance' and plr.ClassName == 'Model' then return plr end
	if timeout then
		local time = tick()
		repeat
			task.wait()
		until plr.Character or tick() - time > timeout
	end
	return plr.Character or plr.CharacterAdded:Wait() or nil
end

function api.getPlrByCharacter(character)
	if not character then return nil end
	for _, plr in next, players:GetPlayers() do
		if plr.Character == character then
			return plr
		end
	end
end

function api.getPlrByPartOfUsername(part)
	if not part then return nil end
	for _, plr in next, players:GetPlayers() do
		if string.find(string.lower(plr.Name), string.lower(part)) then
			return plr
		end
	end
end

function api.getHumanoid(plr)
	plr = plr or lplr
	if api.isAlive(plr) then
		--print(plr, getChild('Humanoid', api.getCharacter(plr), 15, true))
		return getChild('Humanoid', api.getCharacter(plr), 15, true)
	end
end

function api.getRoot(plr)
	plr = plr or lplr
	if api.isAlive(plr) then
		return getChild('HumanoidRootPart', api.getCharacter(plr))
	end
end

function api.getRootPart(plr)
	return api.getRoot(plr)
end

function api.getTorso(plr)
	plr = plr or lplr
	if api.isAlive(plr) then
		return getChild(api.getHumanoid(plr).RigType == Enum.HumanoidRigType.R6 and 'Torso' or 'UpperTorso', api.getCharacter(plr))
	end
end

function api.getHead(plr)
	plr = plr or lplr
	--print('getting head for ',plr, api.isAlive(plr), api.isAlive(plr, true))
	if api.isAlive(plr, true) then
		--print('passed after check in getting head for ',plr)
		return getChild('Head', api.getCharacter(plr))
	end
end

function api.getCurrentTool(plr)
	plr = plr or lplr
	return api.getCharacter(plr):FindFirstChildOfClass('Tool')
end


function api.getTeamColor(plr)
	plr = plr or lplr
	if api.isAlive(plr) then
		return plr.TeamColor.Color
	end
end

function api.teamCheck(plr)
	return lplr.Team ~= plr.Team
end

function api.isVisible(pos, wallCheck, ...)
	if not wallCheck then
		return true
	end
	return #camera:GetPartsObscuringTarget({pos}, {camera, lplr.Character, ...}) == 0
end

function api.isTargetable(plr, plrData)
    if not plr.team then return true end
    if lplr and not lplr.Team then return true end
    if plr.Team ~= lplr.Team then return end
    if plrData and plrData.health and plrData.health > 0 then return end
    return false
end

function api.entitiesAroundMouse(args)
	local distance = args.maxDistance or 100
	local teamCheck = args.teamCheck or false
	local targetCheck = args.targetCheck or false
	local wallCheck = args.wallCheck or false
	local targetPart = args.targetPart or 'root'
	targetPart = (targetPart == 'RootPart' and 'root' or targetPart):lower()
	local players = args.players or false
	local npcs = args.npcs or false
	local maxEntities = args.maxEntities or 1
	local entities = {}

	if players then
		for _, plr in next, api.players do
			--print('in entitiesaroundmouse plr', plr, plr.plr, plr.alive, plr.npc)
			if plr.plr ~= lplr and plr.alive then
				--print('after check passed only ', plr, plr.plr, plr.alive, plr.npc)
				local part = plr[targetPart]
				if not part then return end
				--print(targetPart, part, plr.plr)
				if (not teamCheck or api.teamCheck(plr.plr)) and (not targetCheck or api.isTargetable(plr.plr)) and api.isVisible(part.Position, wallCheck) then
					local screenPos, vis = camera:WorldToViewportPoint(part.Position)
					if screenPos and vis then
						local pos = Vector2.new(screenPos.X, screenPos.Y)
						local magnitude = (pos - userInputService:GetMouseLocation()).Magnitude
						if distance > magnitude then
							if maxEntities == 1 then return plr end
							table.insert(entities, plr)
						end
					end
				end
			end
		end
	end

	return entities
end

function api.entitiesAroundPosition(args)
	local position = args.position
	local distance = args.maxDistance or 100
	local teamCheck = args.teamCheck or false
	local targetCheck = args.targetCheck or false
	local wallCheck = args.wallCheck or false
	local visibleCheck = args.visibleCheck or false
	local targetPart = args.targetPart or 'root'
	targetPart = (targetPart == 'RootPart' and 'root' or targetPart):lower()
	local players = args.players or false
	local npcs = args.npcs or false
	local maxEntities = args.maxEntities or 1
	local entities = {}

	if players then
		for _, plr in next, api.players do
			--print('in entitiesaroundmouse plr', plr, plr.plr, plr.alive, plr.npc)
			if plr.plr ~= lplr and plr.alive then
				local part = plr[targetPart]
				if (not teamCheck or api.teamCheck(plr.plr)) and (not targetCheck or api.isTargetable(plr.plr)) and (not visibleCheck or api.isVisible(part.Position, wallCheck, part)) then
					local magnitude = (part.Position - position).Magnitude
					if distance > magnitude then
						if maxEntities == 1 then return plr end
						table.insert(entities, plr)
					end
				end
			end
		end
	end

	return entities
end

function api.getPlayers(aliveOnly)
	local players = {}
	for name, plrTable in next, api.players do
		if not aliveOnly or plrTable.alive then
			players[name] = plrTable
		end
	end
	return players
end

function api.addConnections(name, data)
	local new = {connections = {}}
	function new.Connect(self, func)
		if typeof(self) == 'function' and not func then
			func = self
			self = new
		end
		table.insert(self.connections, func)
		return {
			Disconnect = function()
				local ind = table.find(self.connections, func)
				if ind then table.remove(self.connections, ind) end
			end
		}
	end
	function new.Fire(self, ...)
		if typeof(self) ~= 'table' or not self.connections then
			self = new
		end
		for _, v in next, data[name].connections do
			v(...)
		end
	end
	function new.Disconnect(self)
		if typeof(self) ~= 'table' or not self.connections then
			self = new
		end
		for _, v in next, self.connections do
			v:Disconnect()
		end
		table.clear(self.connections)
		table.clear(self)
		table.remove(data, table.find(data, self))
	end
	data[name] = new
end

local function getPlayerData(character, originPlr)
	local plr = originPlr or character
	local data = {}

	data.plr = plr
	data.alive = originPlr and api.isAlive(plr) or true
	if data.alive then
		local humanoid, timeout = api.getHumanoid(plr)
		data.character = originPlr and api.getCharacter(plr, 15) or character
		data.displayName = originPlr and originPlr.DisplayName or character.Name
		data.head = api.getHead(plr)
		data.humanoid = humanoid--api.getHumanoid(plr)
		data.humanoidTimeout = timeout
		data.health = getChild('Health', data.humanoid, 15, false, true)
		data.hipHeight = getChild('HipHeight', data.humanoid, 15, false, true) --data.humanoid and data.humanoid.HipHeight or 0
		data.maxHealth = getChild('MaxHealth', data.humanoid, 15, false, true)
		data.name = originPlr and originPlr.Name or character.Name
		data.root = api.getRootPart(plr)
		data.targetable = originPlr and api.isTargetable(plr, data) or true
		data.team = originPlr and originPlr.Team or nil
		data.teamColor = data.team and originPlr.TeamColor or nil
		data.teammate = lplr and lplr.Team and data.team and lplr.Team == data.team or false
	end
	data.npc = originPlr == nil
	return data
end

function api.addPlayer(character, plr)
	if not character then return end

	plr = plr or api.getPlrByCharacter(character) or nil

	if api.players[plr and plr.Name or character.Name] then api.removePlayer(plr or character) end

    local plrConnections = {}
	local clearingConnections = {}
	local plrTable = {
		plrConnections = plrConnections,
		origin = 'universal'
	}

	api.addConnections('characterAdded', plrTable)
	api.addConnections('characterRemoving', plrTable)
	api.addConnections('healthChanged', plrTable)

	local data = getPlayerData(character, plr)

	if not data.character or not data.humanoid then
		--print(plrTable, plr, ' player doesnt have either character or humanoid ', data.character, data.humanoid, data.humanoidTimeout)
		plrTable.characterRemoving:Fire()
		disconnect(plrConnections.humanoidConnection)

		api.removePlayer(plr)

		return
	end

	for name, value in next, data do
		if plr == lplr then
			api[name] = value
			plrTable[name] = value
		else
			plrTable[name] = value
		end
	end

	if plr then
		table.insert(plrConnections, plr.CharacterAdded:Connect(function()
			repeat task.wait() until api.isAlive(plr, not data.npc)

			local data = getPlayerData(plr)
			for name, value in next, data do
				if plr == lplr then
					api[name] = value
				else
					plrTable[name] = value
				end
			end

			if plr == lplr then
				api.characterAdded:Fire(plrTable)

				table.insert(clearingConnections, plr.character.ChildAdded:Connect(function(child)
					if child.ClassName == 'Tool' then
						api.tool = child
					end
				end))
				table.insert(clearingConnections, plr.character.ChildRemoved:Connect(function(child)
					if child.ClassName == 'Tool' then
						api.tool = nil
					end
				end))

				if plrTable.humanoid then
					table.insert(clearingConnections, plrTable.humanoid:GetPropertyChangedSignal('Health'):Connect(function()
						api.players[lplr.Name].health = plrTable.humanoid.CurrentHealth
						plrTable.healthChanged:Fire(plrTable.humanoid.CurrentHealth)
					end))
				end
			end

			plrTable.characterAdded:Fire()
		end))

		table.insert(plrConnections, plr.CharacterRemoving:Connect(function()
			for name, value in next, raw do
				if plr == lplr then
					api[name] = value
				else
					plrTable[name] = value
				end
			end

			if plr == lplr then
				api.characterRemoving:Fire(plrTable)
				for _, connection in next, clearingConnections do connection:Disconnect() end
			end

			plrTable.characterRemoving:Fire()
			disconnect(plrConnections.humanoidConnection)
		end))
	end

	table.insert(plrConnections, plrTable.character.DescendantRemoving:Connect(function(descendant)
		if descendant.ClassName == 'Humanoid' then
			plrTable.characterRemoving:Fire()
			disconnect(plrConnections.humanoidConnection)

			api.playerRemoving:Fire(plrTable) -- // calling it first so it fires with playertable
			api.removePlayer(plr)
		end
	end))

	if plrTable.humanoid then
		table.insert(plrConnections, plrTable.humanoid:GetPropertyChangedSignal('Health'):Connect(function()
			if plrTable.humanoid.Health <= 0 then
				plrTable.characterRemoving:Fire()
				disconnect(plrConnections.humanoidConnection)

				api.playerRemoving:Fire(plrTable) -- // calling it first so it fires with playertable
				api.removePlayer(plr)
			end
		end))
	end

	plr = plr or character
	api.players[plr.Name] = plrTable
	api.connections[plr.Name] = plrConnections

	api.playerAdded:Fire(plrTable)

	return plrTable
end

function api.removePlayer(plrModel)
	if not plrModel then return end
	local connections = api.connections[plrModel.Name]
	if connections and #connections > 1 then
		for _, connection in next, connections do
			disconnect(connection)
		end
	end

	api.playerRemoving:Fire(api.players[plrModel.Name])

	api.connections[plrModel.Name] = nil
	api.players[plrModel.Name] = nil
end

function api:refreshPlayer(plr)
	api.removePlayer(plr)
	api.addPlayer(api.getCharacter(plr), plr)
end

function api.init(self)
	self = self or api

	self.addConnections('characterAdded', self)
	self.addConnections('characterRemoving', self)
	self.addConnections('playerAdded', self)
	self.addConnections('playerRemoving', self)

	for _, plr in next, players:GetPlayers() do
		api.addPlayer(plr.character, plr)
	end

	table.insert(api.connections, players.PlayerAdded:Connect(function(plr)
		api.addPlayer(plr.character, plr)
	end))

	table.insert(api.connections, players.PlayerRemoving:Connect(function(plr)
		--api.playerRemoving:Fire(api.players[plr.Name]) -- // calling it first so it fires with playertable
		api.removePlayer(plr)
	end))

	table.insert(api.connections, workspace.DescendantAdded:Connect(function(v)
		if typeof(v) == 'Instance' and v.ClassName == 'Model' then
			task.spawn(function()
				local humanoid = getChild('Humanoid', v, 15, true)
				local rootPart = getChild('HumanoidRootPart', v, 15)
				if humanoid or rootPart then
					api.addPlayer(v)
				end
			end)
		end
	end))

	table.insert(api.connections, workspace.DescendantRemoving:Connect(function(v)
		if typeof(v) == 'Instance' and v.ClassName == 'Model' then
			for _, plr in next, api.players do
				if plr.character == v then
					api.removePlayer(v)
				end
			end
		end
	end))

	-- // here it's searching for npcs, but its here so it wont yield other stuff
	task.spawn(function()
		for _, v in next, workspace:GetDescendants() do
			if typeof(v) == 'Instance' and v.ClassName == 'Model' then
				task.spawn(function()
					local humanoid = getChild('Humanoid', v, 15, true)
					if humanoid then
						api.addPlayer(v)
					end
				end)
			end
			task.wait()
		end
	end)

	task.spawn(function()
		local thread = task.spawn(function()
			while task.wait(10) do
				for _, plr in next, api.players do
					for part, value in next, plr do
						if value == nil then
							api.refreshPlayer(plr.plr)
						end
					end
				end
			end
		end)
		table.insert(api.connections, {
			Disconnect = function()
				task.cancel(thread)
			end
		})
	end)

	api.loaded = true
end

function api.stop()
	for _, connection in next, api.connections do
		disconnect(connection)
	end
	api.connections = {}
	api.players = {}
	for name, value in next, raw do
		api[name] = value
	end

	api.loaded = false
end

function api.reStart()
	api.stop()
	task.wait()
	api.init()
end

return api