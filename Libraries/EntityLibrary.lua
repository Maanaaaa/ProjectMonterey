local api = {
	loaded = false,
    head = nil,
    root = nil,
	humanoid = nil,
    character = nil,
    health = 0,
	tool = nil,
	entities = {},
    players = {},
	npcs = {},
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
	if api.isAlive(plr, true) then
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
	return typeof(plr) == 'Instance' and plr.ClassName == 'Player' and lplr.Team ~= plr.Team
end

function api.wallCheck(pos, ...)
	return #camera:GetPartsObscuringTarget({pos}, {camera, lplr.Character, ...}) == 0
end

function api.isTargetable(plr, plrData)
	if not plr then return false end
    if plr.ClassName == 'Player' and not plr.team then return true end
    if lplr and not lplr.Team then return true end
    if plr.Team ~= lplr.Team then return end
    if plrData and plrData.health and plrData.health > 0 then return end
    return false
end

function api.entitiesAroundCharacter(args)
	local distance = args.maxDistance or 100
	local targetCheck = args.targetCheck == nil and false or args.targetCheck
	local teamCheck = args.teamCheck == nil and false or args.teamCheck
	local wallCheck = args.wallCheck == nil and false or args.wallCheck
	local targetPart = args.targetPart or 'root'
	targetPart = (targetPart == 'RootPart' and 'root' or targetPart):lower()
	local players = args.players == nil and true or args.players
	local npcs = args.npcs == nil and false or args.npcs
	local closest = args.closest == nil and false or args.closest
	local maxEntities = args.maxEntities or 1
	local entities = {}

	for _, plr in next, ((players and npcs and api.entities) or (players and api.players) or (npcs and api.npcs) or {}) do
		if plr.plr ~= lplr and plr.alive then
			local part = plr[targetPart]
			if not part then return end
			if (not teamCheck or api.teamCheck(plr.plr)) and (not targetCheck or api.isTargetable(plr.plr)) and (not wallCheck or api.wallCheck(part.Position, plr.character)) then
				local magnitude = (api.root.Position - part.Position).Magnitude
				if distance > magnitude then
					if maxEntities == 1 and not closest then return {plr} end

					table.insert(entities, plr)
				end
			end
		end
	end

	if closest then
		table.sort(entities, function(a, b)
			return (api.root.Position - a[targetPart].Position.Position).Magnitude < (api.root.Position - b[targetPart].Position.Position).Magnitude
		end)
	end

	local newEntities = {}
	for i = 1, maxEntities do
		newEntities[i] = entities[i]
	end

	return newEntities
end

function api.entitiesAroundMouse(args)
	local distance = args.maxDistance or 100
	local targetCheck = args.targetCheck == nil and false or args.targetCheck
	local teamCheck = args.teamCheck == nil and false or args.teamCheck
	local wallCheck = args.wallCheck == nil and false or args.wallCheck
	local targetPart = args.targetPart or 'root'
	targetPart = (targetPart == 'RootPart' and 'root' or targetPart):lower()
	local players = args.players == nil and true or args.players
	local npcs = args.npcs == nil and false or args.npcs
	local closest = args.closest == nil and false or args.closest
	local maxEntities = args.maxEntities or 1
	local entities = {}

	for _, plr in next, ((players and npcs and api.entities) or (players and api.players) or (npcs and api.npcs) or {}) do
		if plr.plr ~= lplr and plr.alive then
			local part = plr[targetPart]
			if not part then return end
			if (not teamCheck or api.teamCheck(plr.plr)) and (not targetCheck or api.isTargetable(plr.plr)) and (not wallCheck or api.wallCheck(part.Position, plr.character)) then
				local screenPos, vis = camera:WorldToViewportPoint(part.Position)
				if screenPos and vis then
					local pos = Vector2.new(screenPos.X, screenPos.Y)
					local magnitude = (pos - userInputService:GetMouseLocation()).Magnitude
					if distance > magnitude then
						if maxEntities == 1 and not closest then return {plr} end

						table.insert(entities, plr)
					end
				end
			end
		end
	end

	if closest then
		table.sort(entities, function(a, b)
			local aScreenPos, bScreenPos = camera:WorldToViewportPoint(a[targetPart].Position), camera:WorldToViewportPoint(b[targetPart].Position)
			local aPos, bPos = Vector2.new(aScreenPos.X, aScreenPos.Y), Vector2.new(bScreenPos.X, bScreenPos.Y)
			local aMagnitude, bMagnitude = (aPos - userInputService:GetMouseLocation()).Magnitude, (bPos - userInputService:GetMouseLocation()).Magnitude

			return aMagnitude < bMagnitude
		end)
	end

	local newEntities = {}
	for i = 1, maxEntities do
		newEntities[i] = entities[i]
	end

	return newEntities
end

function api.entitiesAroundPosition(args)
	local position = args.position
	local distance = args.maxDistance or 100
	local teamCheck = args.teamCheck or false
	local targetCheck = args.targetCheck or false
	local wallCheck = args.wallCheck or false
	local targetPart = args.targetPart or 'root'
	targetPart = (targetPart == 'RootPart' and 'root' or targetPart):lower()
	local players = args.players == nil and true or args.players
	local npcs = args.npcs or false
	local maxEntities = args.maxEntities or 1
	local entities = {}

	for _, plr in next, players and npcs and api.entities or players and api.players or npcs and api.npcs or {} do
		if plr.plr ~= lplr and plr.alive then
			local part = plr[targetPart]
			if (not teamCheck or api.teamCheck(plr.plr)) and (not targetCheck or api.isTargetable(plr.plr)) and (not wallCheck or api.wallCheck(part.Position, part)) then
				local magnitude = (part.Position - position).Magnitude
				if distance > magnitude then
					if maxEntities == 1 then return plr end
					table.insert(entities, plr)
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

function api.getEntityByPart(part, targetCheck, teamCheck, wallCheck)
	for _, plr in next, api.players do
		if (not targetCheck or api.isTargetable(plr.plr, plr)) and (not teamCheck or api.teamCheck(plr)) and (not wallCheck or api.wallCheck(plr)) then
			for _, v in next, plr.character:GetChildren() do
				if v == part then
					return plr
				end
			end
		end
	end
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
	local entity = {
		plrConnections = plrConnections,
		origin = 'universal'
	}

	api.addConnections('characterAdded', entity)
	api.addConnections('characterRemoving', entity)
	api.addConnections('healthChanged', entity)

	local data = getPlayerData(character, plr)

	if not data.character or not data.humanoid then
		entity.characterRemoving:Fire()
		disconnect(plrConnections.humanoidConnection)

		api.removePlayer(plr)

		return
	end

	for name, value in next, data do
		if plr == lplr then
			api[name] = value
			entity[name] = value
		else
			entity[name] = value
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
					entity[name] = value
				end
			end

			if plr == lplr then
				api.characterAdded:Fire(entity)

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

				if entity.humanoid then
					table.insert(clearingConnections, entity.humanoid:GetPropertyChangedSignal('Health'):Connect(function()
						api.players[lplr.Name].health = entity.humanoid.CurrentHealth
						entity.healthChanged:Fire(entity.humanoid.CurrentHealth)
					end))
				end
			end

			entity.characterAdded:Fire()
		end))

		table.insert(plrConnections, plr.CharacterRemoving:Connect(function()
			for name, value in next, raw do
				if plr == lplr then
					api[name] = value
				else
					entity[name] = value
				end
			end

			if plr == lplr then
				api.characterRemoving:Fire(entity)
				for _, connection in next, clearingConnections do connection:Disconnect() end
			end

			entity.characterRemoving:Fire()
			disconnect(plrConnections.humanoidConnection)
		end))
	end

	table.insert(plrConnections, entity.character.DescendantRemoving:Connect(function(descendant)
		if descendant.ClassName == 'Humanoid' then
			entity.characterRemoving:Fire()
			disconnect(plrConnections.humanoidConnection)

			api.playerRemoving:Fire(entity) -- // calling it first so it fires with playertable
			api.removePlayer(plr)
		end
	end))

	if entity.humanoid then
		table.insert(plrConnections, entity.humanoid:GetPropertyChangedSignal('Health'):Connect(function()
			if entity.humanoid.Health <= 0 then
				entity.characterRemoving:Fire()
				disconnect(plrConnections.humanoidConnection)

				api.playerRemoving:Fire(entity) -- // calling it first so it fires with playertable
				api.removePlayer(plr)
			end
		end))
	end

	plr = plr or character
	api.entities[plr.Name] = entity
	api[entity.npc and 'npcs' or 'players'][plr.Name] = entity
	api.connections[plr.Name] = plrConnections

	api.playerAdded:Fire(entity)

	return entity
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