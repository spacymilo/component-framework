local Signal = {}
Signal.__index = Signal

export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

export type Signal = {
	Connect: (self: Signal, callback: (...any) -> ()) -> Connection,
	Fire: (self: Signal, ...any) -> (),
	Destroy: (self: Signal) -> (),
}

function Signal.new()
	return setmetatable({
		_bindings = {} :: {[number]: (...any) -> ()},
		_nextId = 0,
		_destroyed = false,
	}, Signal)
end

function Signal:Connect(callback)
	assert(not self._destroyed, "Signal is destroyed")
	assert(type(callback) == "function", "Signal:Connect expects a function")

	self._nextId += 1
	local id = self._nextId
	self._bindings[id] = callback

	local connection = {
		Connected = true,
		_signal = self,
		_id = id,
	}

	function connection:Disconnect()
		if not self.Connected then
			return
		end

		self.Connected = false
		self._signal._bindings[self._id] = nil
	end

	return connection
end

function Signal:Fire(...)
	if self._destroyed then
		return
	end

	for _, callback in pairs(self._bindings) do
		task.spawn(callback, ...)
	end
end

function Signal:Destroy()
	self._destroyed = true
	table.clear(self._bindings)
end

return Signal
