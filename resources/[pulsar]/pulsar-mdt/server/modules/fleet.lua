AddEventHandler("MDT:Server:RegisterCallbacks", function()
  exports["pulsar-core"]:RegisterServerCallback("MDT:ViewVehicleFleet", function(source, data, cb)
    local hasPerms, loggedInJob = CheckMDTPermissions(source, {
      'FLEET_MANAGEMENT',
    })

    if hasPerms and loggedInJob then
      local results = MySQL.query.await(
        "SELECT VIN, Make, Model, Type, OwnerType, OwnerId, OwnerWorkplace, StorageType, StorageId, Properties, RegistrationDate, RegisteredPlate FROM vehicles WHERE OwnerType = ? AND OwnerId = ?",
        { 1, loggedInJob }
      )

      if results then
        for k, v in ipairs(results) do
          if v.Properties then
            local properties = json.decode(v.Properties)
            if properties and properties.GovAssigned then
              if type(properties.GovAssigned) == "string" then
                local success, decoded = pcall(json.decode, properties.GovAssigned)
                if success and decoded and type(decoded) == "table" then
                  v.GovAssigned = decoded
                else
                  v.GovAssigned = nil
                end
              else
                v.GovAssigned = properties.GovAssigned
              end
            else
              v.GovAssigned = nil
            end
          end

          v.Owner = {
            Type = v.OwnerType,
            Id = v.OwnerId,
            Workplace = v.OwnerWorkplace or "None"
          }

          if v.StorageType ~= nil then
            local storageName = nil
            if v.StorageType == 0 then
              local impound = exports['pulsar-vehicles']:GaragesImpound()
              storageName = impound and impound.name or nil
            elseif v.StorageType == 1 then
              local garage = exports['pulsar-vehicles']:GaragesGet(v.StorageId)
              storageName = garage and garage.name or nil
            elseif v.StorageType == 2 then
              local prop = exports['pulsar-properties']:Get(v.StorageId)
              storageName = prop and prop.label or nil
            end

            if storageName then
              v.Storage = {
                Type = v.StorageType,
                Id = v.StorageId,
                Name = storageName
              }
            end
          end

          v.OwnerType = nil
          v.OwnerId = nil
          v.OwnerWorkplace = nil
          v.StorageType = nil
          v.StorageId = nil
          v.Properties = nil
        end

        cb(results)
      else
        cb(false)
      end
    else
      cb(false)
    end
  end)

  exports["pulsar-core"]:RegisterServerCallback("MDT:SetAssignedDrivers", function(source, data, cb)
    local hasPerms, loggedInJob = CheckMDTPermissions(source, {
      'FLEET_MANAGEMENT',
    })

    if hasPerms and loggedInJob and data.vehicle and data.assigned then
      local ass = {}
      for k, v in ipairs(data.assigned) do
        table.insert(ass, {
          SID = v.SID,
          First = v.First,
          Last = v.Last,
          Callsign = v.Callsign
        })
      end
      local success = MySQL.update.await(
        "UPDATE vehicles SET Properties = JSON_SET(CASE WHEN JSON_TYPE(Properties) = 'OBJECT' THEN Properties ELSE '{}' END, '$.GovAssigned', ?) WHERE VIN = ?",
        { json.encode(ass), data.vehicle }
      )

      cb(success)
    else
      cb(false)
    end
  end)

  exports["pulsar-core"]:RegisterServerCallback("MDT:TrackFleetVehicle", function(source, data, cb)
    local hasPerms, loggedInJob = CheckMDTPermissions(source, {
      'FLEET_MANAGEMENT',
    })

    if hasPerms and loggedInJob and data.vehicle then
      cb(exports['pulsar-vehicles']:OwnedTrack(data.vehicle))
    else
      cb(false)
    end
  end)
end)
