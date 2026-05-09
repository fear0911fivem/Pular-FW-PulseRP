local utils = require 'client.utils'

local computedCache = {
    permissions = {},
    globalPermissions = {},
    rep = {},
    jobs = {},
    duty = {},
}

local currentCharacter = nil
local currentOnDuty = nil

local function invalidateComputedCache()
    computedCache.permissions = {}
    computedCache.globalPermissions = {}
    computedCache.rep = {}
    computedCache.jobs = {}
    computedCache.duty = {}
end

local function getJobInfo(jobName)
    local char = LocalPlayer.state.Character
    if not char then
        return false
    end

    if computedCache.jobs[jobName] ~= nil then
        return computedCache.jobs[jobName]
    end

    local jobs = char:GetData("Jobs") or {}
    for _, job in ipairs(jobs) do
        if job.Id == jobName then
            computedCache.jobs[jobName] = job
            return job
        end
    end

    computedCache.jobs[jobName] = false
    return false
end

local function getDutyStatus(jobName)
    local onDuty = LocalPlayer.state.onDuty

    if currentOnDuty == onDuty and computedCache.duty[jobName] ~= nil then
        return computedCache.duty[jobName]
    end

    if not onDuty then
        computedCache.duty[jobName] = false
        return false
    end

    local result = jobName and (onDuty == jobName and onDuty or false) or onDuty
    computedCache.duty[jobName] = result
    currentOnDuty = onDuty
    return result
end

local function getCachedJobPermission(jobName, permissionKey)
    local cacheKey = jobName .. ':' .. permissionKey
    if computedCache.permissions[cacheKey] == nil then
        computedCache.permissions[cacheKey] = exports['sandbox-jobs']:HasPermissionInJob(jobName, permissionKey)
    end
    return computedCache.permissions[cacheKey]
end

local function getCachedPermission(permissionKey)
    if computedCache.globalPermissions[permissionKey] == nil then
        computedCache.globalPermissions[permissionKey] = exports['sandbox-jobs']:HasPermission(permissionKey)
    end
    return computedCache.globalPermissions[permissionKey]
end

local function getCachedRepLevel(repId)
    if computedCache.rep[repId] == nil then
        computedCache.rep[repId] = exports['sandbox-characters']:RepGetLevel(repId)
    end
    return computedCache.rep[repId]
end

CreateThread(function()
    while not LocalPlayer.state.Character do
        Wait(100)
    end

    local stateId = ('player:%s'):format(GetPlayerServerId(PlayerId()))

    AddStateBagChangeHandler('onDuty', stateId, function(bagName, key, value, reserved, replicated)
        computedCache.duty = {}
        currentOnDuty = nil
        computedCache.permissions = {}
        computedCache.globalPermissions = {}
    end)

    AddStateBagChangeHandler('Character', stateId, function(bagName, key, value, reserved, replicated)
        currentCharacter = value
        invalidateComputedCache()
    end)
end)

RegisterNetEvent('Job:Client:DutyChanged', function()
    invalidateComputedCache()
end)

AddEventHandler('Characters:Client:Updated', function(key)
    if key == 'Jobs' then
        computedCache.jobs = {}
        computedCache.permissions = {}
        computedCache.globalPermissions = {}
    end
end)

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter, reqDuty, reqOffDuty, workplace, permissionKey, tempjob, rep)
    local char = LocalPlayer.state.Character
    if not char then
        return false
    end

    if filter == nil and tempjob ~= nil then
        return char:GetData("TempJob") == tempjob
    end

    if filter == nil and permissionKey ~= nil then
        return getCachedPermission(permissionKey)
    end

    if filter == nil and rep ~= nil then
        return getCachedRepLevel(rep.id) >= rep.level
    end

    local function checkJob(jobName)
        if type(jobName) ~= "string" then
            return false
        end

        if reqDuty ~= nil or reqOffDuty ~= nil then
            local isOnDuty = getDutyStatus(jobName)

            if reqDuty ~= nil then
                if reqDuty and not isOnDuty then
                    return false
                elseif not reqDuty and isOnDuty then
                    return false
                end
            end

            if reqOffDuty ~= nil then
                if reqOffDuty and isOnDuty then
                    return false
                elseif not reqOffDuty and not isOnDuty then
                    return false
                end
            end
        end

        local jobInfo = getJobInfo(jobName)
        if not jobInfo then
            return false
        end

        if workplace ~= nil then
            if not (jobInfo.Workplace and jobInfo.Workplace.Id == workplace) then
                return false
            end
        end

        if permissionKey ~= nil then
            if not getCachedJobPermission(jobName, permissionKey) then
                return false
            end
        end

        if tempjob ~= nil then
            if char:GetData("TempJob") ~= tempjob then
                return false
            end
        end

        if rep ~= nil then
            if getCachedRepLevel(rep.id) < rep.level then
                return false
            end
        end

        return true
    end

    local filterType = type(filter)

    if filterType == "string" then
        return checkJob(filter)
    elseif filterType == "table" then
        local tableType = table.type(filter)

        if tableType == "array" or #filter > 0 then
            for i, jobEntry in ipairs(filter) do
                local jobName = jobEntry

                if type(jobEntry) == "table" then
                    jobName = jobEntry.job or jobEntry.name
                    if not jobName then
                        for k, v in pairs(jobEntry) do
                            jobName = v
                            break
                        end
                    end
                end

                if jobName and checkJob(jobName) then
                    return true
                end
            end
            return false
        elseif tableType == "hash" then
            for jobName, grade in pairs(filter) do
                if type(jobName) == "string" then
                    if reqDuty ~= nil or reqOffDuty ~= nil then
                        local isOnDuty = getDutyStatus(jobName)
                        if reqDuty ~= nil and ((reqDuty and not isOnDuty) or (not reqDuty and isOnDuty)) then
                            goto continue
                        end
                        if reqOffDuty ~= nil and ((reqOffDuty and isOnDuty) or (not reqOffDuty and not isOnDuty)) then
                            goto continue
                        end
                    end

                    local jobInfo = getJobInfo(jobName)
                    if not jobInfo then
                        goto continue
                    end

                    local playerGrade = jobInfo.Grade and jobInfo.Grade.Level or 0
                    if playerGrade < grade then
                        goto continue
                    end

                    if workplace ~= nil and not (jobInfo.Workplace and jobInfo.Workplace.Id == workplace) then
                        goto continue
                    end

                    if permissionKey ~= nil and not getCachedJobPermission(jobName, permissionKey) then
                        goto continue
                    end

                    if tempjob ~= nil and char:GetData("TempJob") ~= tempjob then
                        goto continue
                    end

                    if rep ~= nil and getCachedRepLevel(rep.id) < rep.level then
                        goto continue
                    end

                    return true
                end
                ::continue::
            end
            return false
        else
            local jobName = filter.job or filter.name
            if type(jobName) == "string" then
                return checkJob(jobName)
            end
            return false
        end
    end

    return false
end

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotItems(data)
    if type(data) == "string" then
        return exports.ox_inventory:ItemsHas(data, 1)
    elseif type(data) == "table" then
        if data.item then
            return exports.ox_inventory:ItemsHas(data.item, data.itemCount or 1)
        end

        for k, v in pairs(data) do
            if type(v) == "number" then
                if not exports.ox_inventory:ItemsHas(k, v) then
                    return false
                end
            else
                if not exports.ox_inventory:ItemsHas(v, 1) then
                    return false
                end
            end
        end

        return true
    end

    return false
end
