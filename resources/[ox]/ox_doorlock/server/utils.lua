local resourcePath = GetResourcePath(cache.resource):gsub('//', '/') .. '/'

local utils = {}

function utils.getFilesInDirectory(path, pattern)
	local files = {}
	local fileCount = 0
	local system = os.getenv('OS')
	local command = system and system:match('Windows') and 'dir "' or 'ls "'
	local suffix = command == 'dir "' and '/" /b' or '/"'
	local dir = io.popen(command .. resourcePath .. path .. suffix)

	if dir then
		for line in dir:lines() do
			if line:match(pattern) then
				fileCount += 1
				files[fileCount] = line:gsub(pattern, '')
			end
		end

		dir:close()
	end

	return files, fileCount
end

local frameworks = { 'es_extended', 'ND_Core', 'ox_core', 'qbx_core', 'pulsar-core', 'sandbox-base' }
local sucess = false
local activeFramework = nil

for i = 1, #frameworks do
	local framework = frameworks[i]

	-- guard GetResourceState in case it's unavailable in a given runtime
	local ok, state = pcall(GetResourceState, framework)
	if ok and state and state:find('start') then
		require(('server.framework.%s'):format(framework:lower()))
		sucess = true
		activeFramework = framework
		break
	end
end

-- expose which framework (if any) was loaded
utils.activeFramework = activeFramework

--- Check if a specific framework/resource is active
-- @param name string Framework/resource name
-- @return boolean
function utils.isFrameworkActive(name)
	if not name then return false end

	if utils.activeFramework == name then return true end

	local ok, state = pcall(GetResourceState, name)
	if ok and state and state:find('start') then return true end

	if Framework == name then return true end

	return false
end

if not sucess then
	warn('no compatible framework was loaded, most features will not work')
end

return utils
