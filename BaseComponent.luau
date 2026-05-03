local Maid = require(script.Parent.Maid)

local BaseComponent = {}
BaseComponent.__index = BaseComponent

export type BaseComponent = {
	Instance: Instance,
	maid: any,
	_started: boolean,
	_destroyed: boolean,

	onStart: ((self: BaseComponent) -> ())?,
	onStop: ((self: BaseComponent) -> ())?,

	_start: (self: BaseComponent) -> (),
	_stop: (self: BaseComponent) -> (),
	Destroy: (self: BaseComponent) -> (),
	GetAttribute: (self: BaseComponent, name: string, default: any?) -> any?,
}

function BaseComponent:extend(name)
	local child = {}
	child.__index = child
	child.__name = name or "Component"

	return setmetatable(child, self)
end

function BaseComponent:_create(instance)
	return setmetatable({
		Instance = instance,
		maid = Maid.new(),
		_started = false,
		_destroyed = false,
	}, self)
end

function BaseComponent:GetAttribute(name, default)
	local value = self.Instance:GetAttribute(name)
	if value == nil then
		return default
	end
	return value
end

function BaseComponent:_start()
	if self._started or self._destroyed then
		return
	end

	self._started = true

	if self.onStart then
		self:onStart()
	end
end

function BaseComponent:_stop()
	if self._destroyed then
		return
	end

	self._destroyed = true

	if self.onStop then
		self:onStop()
	end

	self.maid:Destroy()
end

function BaseComponent:Destroy()
	self:_stop()
end

return BaseComponent
