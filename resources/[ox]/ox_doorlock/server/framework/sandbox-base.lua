function GetPlayer(playerId)
    return { source = playerId }
end

function GetCharacterId(player)
    if not player or not player.source then
        return -1
    end

    local char = exports['sandbox-characters']:FetchCharacterSource(player.source)
    if not char then
        return -1
    end

    local sid = char:GetData("SID")
    return sid
end

function IsPlayerInGroup(player, filter)
    if not player then
        return false
    end

    if not filter then
        return true
    end

    local char = exports['sandbox-characters']:FetchCharacterSource(player.source)
    if not char then
        return false
    end

    if type(filter) == "string" then
        return exports['sandbox-jobs']:HasJob(player.source, filter) ~= false
    end

    if type(filter) ~= "table" then
        return false
    end

    for job, requiredGrade in pairs(filter) do
        if job ~= "workplace" and job ~= "permissions" and job ~= "onduty" then
            local jobData = exports['sandbox-jobs']:HasJob(
                player.source,
                job,
                filter.workplace or nil,
                nil,
                requiredGrade or nil,
                filter.onduty or nil,
                filter.permissions or nil
            )

            if not jobData then
                goto continue
            end

            local playerGrade = 0
            if jobData.Grade and jobData.Grade.Level then
                playerGrade = tonumber(jobData.Grade.Level) or 0
            end

            local gradePass = playerGrade >= (requiredGrade or 0)

            local playerWorkplace = jobData.Workplace
            local playerWorkplaceId = type(playerWorkplace) == "table" and playerWorkplace.Id or playerWorkplace
            local workplacePass = (not filter.workplace) or (playerWorkplaceId == filter.workplace)

            local dutyData = exports['sandbox-jobs']:DutyGet(player.source, job)
            local isDutyValid = (not filter.onduty) or (dutyData ~= false)

            local hasPermission = true
            if filter.permissions then
                hasPermission = exports['sandbox-jobs']:HasPermissionInJob(
                    player.source,
                    job,
                    filter.permissions
                )
            end

            if gradePass and workplacePass and isDutyValid and hasPermission then
                return true
            end
        end
        ::continue::
    end

    return false
end
