## Components Framework

This is an easy-to-use component framework which is inspired by **@flamework/components**.

---

### Functions
- Tag-based components using CollectionService
- Automatic lifecycle (onStart, onStop)
- No global init required
- Recursive module loading (addPath)
- Works on both client & server

---

**Example-Script:**
```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Components = require(ReplicatedStorage:WaitForChild("Components"))
local BaseComponent = Components.BaseComponent
local Component = Components.Component

-- Define component class
local Rotate = BaseComponent:extend("Rotate")

-- Tag name used by CollectionService
Rotate.Tag = "Rotate"

function Rotate:onStart()
	-- Read attribute
	local speed = self:GetAttribute("Speed", 90)
	local part = self.Instance

	-- Run every frame
	self.maid:Give(RunService.Heartbeat:Connect(function(dt)
		if self._destroyed then
			return
		end

		local rotation = math.rad(speed) * dt
		part.CFrame = part.CFrame * CFrame.Angles(0, rotation, 0)
	end))
end

function Rotate:onStop()
	-- Nothing needed, Maid handles cleanup
end

-- Register component
return Component.register(Rotate)
```
