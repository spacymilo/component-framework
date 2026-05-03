local CollectionService = game:GetService("CollectionService")

local Registry = {}

local classesByTag = {} :: {[string]: {any}}
local activeByInstance = {} :: {[Instance]: {[any]: any}}
local connectionsByTag = {} :: {[string]: {RBXScriptConnection}}
local started = false

local function passesWhitelist(class, instance)
	local whitelist = class.AncestorWhitelist
	if not whitelist then
		return true
	end

	for _, ancestor in ipairs(whitelist) do
		if instance:IsDescendantOf(ancestor) then
			return true
		end
	end

	return false
end

function Registry.get(instance, class)
	local perInstance = activeByInstance[instance]
	if not perInstance then
		return nil
	end

	return perInstance[class]
end

function Registry.getAll(instance)
	return activeByInstance[instance] or {}
end

function Registry._detach(class, instance)
	local perInstance = activeByInstance[instance]
	if not perInstance then
		return
	end

	local component = perInstance[class]
	if not component then
		return
	end

	perInstance[class] = nil
	component:_stop()

	if next(perInstance) == nil then
		activeByInstance[instance] = nil
	end
end

function Registry._attach(class, instance)
	if not passesWhitelist(class, instance) then
		return
	end

	local perInstance = activeByInstance[instance]
	if not perInstance then
		perInstance = {}
		activeByInstance[instance] = perInstance
	end

	if perInstance[class] then
		return
	end

	local component = class:_create(instance)
	perInstance[class] = component
	component:_start()

	component.maid:Give(instance.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			Registry._detach(class, instance)
			return
		end

		if not passesWhitelist(class, instance) then
			Registry._detach(class, instance)
		end
	end))
end

function Registry._bindTag(tag)
	if connectionsByTag[tag] then
		return
	end

	local added = CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		for _, class in ipairs(classesByTag[tag] or {}) do
			Registry._attach(class, instance)
		end
	end)

	local removed = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
		for _, class in ipairs(classesByTag[tag] or {}) do
			Registry._detach(class, instance)
		end
	end)

	connectionsByTag[tag] = { added, removed }
end

function Registry.register(class)
	assert(type(class) == "table", "Registry.register expects a component class")
	assert(type(class.Tag) == "string" and class.Tag ~= "", "Component class must define a non-empty Tag")

	classesByTag[class.Tag] = classesByTag[class.Tag] or {}
	table.insert(classesByTag[class.Tag], class)

	if started then
		Registry._bindTag(class.Tag)
	end

	for _, instance in ipairs(CollectionService:GetTagged(class.Tag)) do
		Registry._attach(class, instance)
	end

	return class
end

function Registry.start()
	if started then
		return
	end

	started = true

	for tag in pairs(classesByTag) do
		Registry._bindTag(tag)
	end

	for tag, classes in pairs(classesByTag) do
		for _, instance in ipairs(CollectionService:GetTagged(tag)) do
			for _, class in ipairs(classes) do
				Registry._attach(class, instance)
			end
		end
	end
end

function Registry.stop()
	if not started then
		return
	end

	started = false

	for _, pair in pairs(connectionsByTag) do
		for _, connection in ipairs(pair) do
			connection:Disconnect()
		end
	end

	table.clear(connectionsByTag)

	for instance, perInstance in pairs(activeByInstance) do
		for class, _ in pairs(perInstance) do
			Registry._detach(class, instance)
		end
	end
end

return Registry
