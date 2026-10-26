local api = {
    signals = {}
}

function api.createSignal(name)
	local signal = {connections = {}}

	function signal.Connect(self, func)
		if typeof(self) == 'function' and not func then
			func = self
			self = signal
		end

		table.insert(self.connections, func)

		return {
			Disconnect = function()
				local ind = table.find(self.connections, func)
				if ind then table.remove(self.connections, ind) end
			end
		}
	end

	function signal.Fire(self, ...)
		if typeof(self) ~= 'table' or not self.connections then
			self = signal
		end

		for _, v in next, api.signals[name].connections do
			v(...)
		end
	end

	function signal.Disconnect(self)
		if typeof(self) ~= 'table' or not self.connections then
			self = signal
		end

		for _, v in next, self.connections do
			v:Disconnect()
		end

		table.clear(self.connections)
		table.clear(self)
		table.remove(api.signals, table.find(api.signals, self))
	end

	api.signals[name] = signal

    return signal
end

return api