local Loader = {}

local function collectModules(root: Instance, out: { ModuleScript })
	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("ModuleScript") then
			table.insert(out, child)
		elseif child:IsA("Folder") then
			collectModules(child, out)
		end
	end
end

function Loader.loadPath(root: Instance)
	assert(typeof(root) == "Instance", "loadPath expects an Instance")

	local modules = {}
	collectModules(root, modules)

	table.sort(modules, function(a, b)
		return a:GetFullName() < b:GetFullName()
	end)

	for _, moduleScript in ipairs(modules) do
		require(moduleScript)
	end
end

return Loader
