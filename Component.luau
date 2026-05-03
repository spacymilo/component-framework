local Registry = require(script.Parent.Registry)

local Component = {}

function Component.register(class)
	return Registry.register(class)
end

return Component
