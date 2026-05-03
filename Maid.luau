local Maid = {}
Maid.__index = Maid

local function cleanup(taskItem)
	local taskType = typeof(taskItem)

	if taskType == "RBXScriptConnection" then
		taskItem:Disconnect()
	elseif taskType == "Instance" then
		taskItem:Destroy()
	elseif taskType == "thread" then
		task.cancel(taskItem)
	elseif type(taskItem) == "function" then
		taskItem()
	elseif type(taskItem) == "table" then
		if typeof(taskItem.Disconnect) == "function" then
			taskItem:Disconnect()
		elseif typeof(taskItem.Destroy) == "function" then
			taskItem:Destroy()
		end
	end
end

function Maid.new()
	return setmetatable({
		_tasks = {},
	}, Maid)
end

function Maid:Give(taskItem)
	table.insert(self._tasks, taskItem)
	return taskItem
end

function Maid:DoCleaning()
	for _, taskItem in ipairs(self._tasks) do
		cleanup(taskItem)
	end

	table.clear(self._tasks)
end

function Maid:Destroy()
	self:DoCleaning()
end

return Maid
