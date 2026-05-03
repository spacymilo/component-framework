local Loader = require(script.Loader)
local Registry = require(script.Registry)

local Components = {}

-- public re-exports
Components.BaseComponent = require(script.BaseComponent)
Components.Component = require(script.Component)
Components.Registry = Registry
Components.Maid = require(script.Maid)
Components.Signal = require(script.Signal)

-- internal state
local pendingPaths = {}
local started = false

-- register a folder containing component modules
function Components.addPath(path: Instance)
	assert(typeof(path) == "Instance", "Components.addPath expects an Instance")

	table.insert(pendingPaths, path)

	-- if already started, load immediately
	if started then
		Loader.loadPath(path)
	end
end

-- boot the system
function Components.start()
	if started then
		return
	end

	started = true

	-- load all registered paths
	for _, path in ipairs(pendingPaths) do
		Loader.loadPath(path)
	end

	-- start attaching components
	Registry.start()
end

return Components
