_charPropertyKeys = {}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterCallbacks()
    RegisterMiddleware()
    RegisterChatCommands()
    DefaultData()
    Startup()
    CreateFurnitureCallbacks()
    SetupPropertyCrafting()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-properties')
  end
end)

exports('Add', function(source, type, interior, price, label, pos)
  if PropertyTypes[type] then
    if PropertyInteriors[interior] and PropertyInteriors[interior].type == type then
      local doc = {
        type = type,
        label = label,
        price = price,
        sold = false,
        owner = nil,
        location = {
          front = pos,
        },
        upgrades = {
          interior = interior,
        },
        locked = true,
        keys = {},
        data = {},
        foreclosed = false
      }

      local locationJson = json.encode(doc.location)
      local upgradesJson = json.encode(doc.upgrades)
      local keysJson = json.encode(doc.keys)
      local dataJson = json.encode(doc.data)

      exports.oxmysql:execute(
        'INSERT INTO properties (type, label, price, sold, owner, location, upgrades, locked, `keys`, data, foreclosed) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
          doc.type, doc.label, doc.price, doc.sold and 1 or 0, doc.owner, locationJson,
          upgradesJson, doc.locked and 1 or 0, keysJson, dataJson, doc.foreclosed and 1 or 0
        }, function(result)
          if result and result.insertId then
            doc.id = result.insertId
            _properties[result.insertId] = doc

            exports["pulsar-chat"]:SendServerSingle(source,
              "Property Added, Property ID: " .. result.insertId)
            TriggerClientEvent("Properties:Client:Update", -1, result.insertId, doc)
          else
            exports["pulsar-chat"]:SendServerSingle(source, "Failed to save property to database")
          end
        end)

      return true
    else
      exports["pulsar-chat"]:SendServerSingle(source, "Invalid Interior Combination")
      return false
    end
  else
    exports["pulsar-chat"]:SendServerSingle(source, "Invalid Property Type")
    return false
  end
end)

exports('AddFrontdoor', function(id, pos)
  if not _properties[id] or not pos then
    return false
  end

  local p = promise.new()
  local currentLocation = _properties[id] and _properties[id].location or {}
  currentLocation.front = pos
  local locationJson = json.encode(currentLocation)

  exports.oxmysql:update('UPDATE properties SET location = ? WHERE id = ?', { locationJson, id },
    function(affectedRows)
      if affectedRows > 0 then
        if _properties[id] and _properties[id].location then
          _properties[id].location.front = pos

          TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
        end
        p:resolve(true)
      else
        p:resolve(false)
      end
    end)
  return Citizen.Await(p)
end)

exports('AddBackdoor', function(id, pos)
  if not _properties[id] or not pos then
    return false
  end

  local p = promise.new()
  local currentLocation = _properties[id] and _properties[id].location or {}
  currentLocation.backdoor = pos
  local locationJson = json.encode(currentLocation)

  exports.oxmysql:update('UPDATE properties SET location = ? WHERE id = ?', { locationJson, id },
    function(affectedRows)
      if affectedRows > 0 then
        if _properties[id] and _properties[id].location then
          _properties[id].location.backdoor = pos

          TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
        end
        p:resolve(true)
      else
        p:resolve(false)
      end
    end)
  return Citizen.Await(p)
end)

exports('AddGarage', function(id, pos)
  if not _properties[id] or pos == nil then
    return false
  end

  local p = promise.new()
  local currentLocation = _properties[id] and _properties[id].location or {}
  currentLocation.garage = pos
  local locationJson = json.encode(currentLocation)

  exports.oxmysql:update('UPDATE properties SET location = ? WHERE id = ?', { locationJson, id },
    function(affectedRows)
      if affectedRows > 0 then
        if _properties[id] and _properties[id].location then
          _properties[id].location.garage = pos

          TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
        end
        p:resolve(true)
      else
        p:resolve(false)
      end
    end)
  return Citizen.Await(p)
end)

exports('SetLabel', function(id, label)
  if not _properties[id] or not label then
    return false
  end

  local p = promise.new()
  exports.oxmysql:update('UPDATE properties SET label = ? WHERE id = ?', { label, id }, function(affectedRows)
    if affectedRows > 0 then
      if _properties[id] and _properties[id].label then
        _properties[id].label = label

        TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
      end
      p:resolve(true)
    else
      p:resolve(false)
    end
  end)
  return Citizen.Await(p)
end)

exports('SetPrice', function(id, price)
  if not _properties[id] or not price then
    return false
  end

  local p = promise.new()
  exports.oxmysql:update('UPDATE properties SET price = ? WHERE id = ?', { price, id }, function(affectedRows)
    if affectedRows > 0 then
      if _properties[id] and _properties[id].price then
        _properties[id].price = price

        TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
      end
      p:resolve(true)
    else
      p:resolve(false)
    end
  end)
  return Citizen.Await(p)
end)

exports('SetData', function(id, key, value)
  if not key or not _properties[id] then
    return false
  end

  local p = promise.new()
  local currentData = _properties[id] and _properties[id].data or {}
  currentData[key] = value
  local dataJson = json.encode(currentData)

  exports.oxmysql:update('UPDATE properties SET data = ? WHERE id = ?', { dataJson, id }, function(affectedRows)
    if affectedRows > 0 then
      if _properties[id] then
        if not _properties[id].data then _properties[id].data = {} end
        _properties[id].data[key] = value

        TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
      end
      p:resolve(true)
    else
      p:resolve(false)
    end
  end)
  return Citizen.Await(p)
end)

exports('Delete', function(id)
  local p = promise.new()
  exports.oxmysql:update('DELETE FROM properties WHERE id = ?', { id }, function(affectedRows)
    if affectedRows > 0 then
      _properties[id] = nil

      TriggerClientEvent("Properties:Client:Update", -1, id, nil)
      p:resolve(true)
    else
      p:resolve(false)
    end
  end)
  return Citizen.Await(p)
end)

exports('UpgradeSet', function(id, upgrade, level)
  local property = _properties[id]
  if property then
    local upgradeData = PropertyUpgrades[property.type][upgrade]
    if upgradeData and upgrade ~= "interior" then
      if level < 1 then
        level = 1
      end

      if level > #upgradeData.levels then
        level = #upgradeData.levels
      end

      local p = promise.new()
      local currentUpgrades = _properties[id] and _properties[id].upgrades or {}
      currentUpgrades[upgrade] = level
      local upgradesJson = json.encode(currentUpgrades)

      exports.oxmysql:update('UPDATE properties SET upgrades = ? WHERE id = ?', { upgradesJson, id },
        function(affectedRows)
          if affectedRows > 0 then
            if _properties[id] then
              if not _properties[id].upgrades then _properties[id].upgrades = {} end
              _properties[id].upgrades[upgrade] = level

              TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
            end
            p:resolve(true)
          else
            p:resolve(false)
          end
        end)
      return Citizen.Await(p)
    end
  end

  return false
end)

exports('UpgradeGet', function(id, upgrade)
  local property = _properties[id]
  if property and property.upgrades and property.upgrades[upgrade] then
    return property.upgrades[upgrade]
  end
  return 1
end)

exports('UpgradeIncrease', function(id, upgrade)
  local property = _properties[id]
  if property then
    local currentLevel = exports['pulsar-properties']:UpgradeGet(id, upgrade)
    local success = exports['pulsar-properties']:UpgradeSet(id, upgrade, currentLevel + 1)

    return success
  end
  return false
end)

exports('UpgradeDecrease', function(id, upgrade)
  local property = _properties[id]
  if property then
    local currentLevel = exports['pulsar-properties']:UpgradeGet(id, upgrade)
    local success = exports['pulsar-properties']:UpgradeSet(id, upgrade, currentLevel - 1)

    return success
  end
  return false
end)

exports('UpgradeSetInterior', function(id, interior)
  local property = _properties[id]
  if property then
    local intData = PropertyInteriors[interior]

    if intData and intData.type == property.type then
      local p = promise.new()
      local currentUpgrades = _properties[id] and _properties[id].upgrades or {}
      currentUpgrades.interior = interior
      local upgradesJson = json.encode(currentUpgrades)

      exports.oxmysql:update('UPDATE properties SET upgrades = ? WHERE id = ?', { upgradesJson, id },
        function(affectedRows)
          if affectedRows > 0 then
            if _properties[id] then
              if not _properties[id].upgrades then _properties[id].upgrades = {} end
              _properties[id].upgrades["interior"] = interior

              TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
            end
            p:resolve(true)
          else
            p:resolve(false)
          end
        end)
      return Citizen.Await(p)
    end
  end
end)

exports('Sell', function(id)
  local p = promise.new()
  exports.oxmysql:update('UPDATE properties SET sold = 0, owner = NULL, `keys` = NULL WHERE id = ?', { id },
    function(affectedRows)
      if affectedRows > 0 and _properties[id] then
        _properties[id].sold = false

        if _properties[id].keys then
          for k, v in pairs(_properties[id].keys) do
            local t = _charPropertyKeys[v.Char]
            if t ~= nil then
              for k2, v2 in ipairs(t) do
                if v2 == id then
                  table.remove(t, k2)
                  _charPropertyKeys[v.Char] = t
                  break
                end
              end
            end
          end
        end

        _properties[id].keys = nil
        _properties[id].owner = nil
        TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
        p:resolve(true)
      else
        p:resolve(false)
      end
    end)
  return Citizen.Await(p)
end)

exports('Buy', function(id, owner, payment)
  local p = promise.new()
  local keysData = { [owner.Char] = owner }
  local keysJson = json.encode(keysData)

  exports.oxmysql:update('UPDATE properties SET soldAt = ?, sold = 1, owner = ?, `keys` = ? WHERE id = ?',
    { os.time(), json.encode(owner), keysJson, id }, function(affectedRows)
      if affectedRows > 0 then
        _properties[id].sold = true
        _properties[id].owner = owner
        _properties[id].keys = keysData
        _properties[id].soldAt = os.time()

        if _charPropertyKeys[owner.Char] ~= nil then
          local t = _charPropertyKeys[owner.Char]
          table.insert(t, id)
          _charPropertyKeys[owner.Char] = t
        else
          _charPropertyKeys[owner.Char] = {
            id,
          }
        end

        TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
        p:resolve(true)
      else
        p:resolve(false)
      end
    end)

  return Citizen.Await(p)
end)

exports('Foreclose', function(id, state)
  if not _properties[id] and state ~= nil then
    return false
  end

  local p = promise.new()
  exports.oxmysql:update('UPDATE properties SET foreclosed = ? WHERE id = ?', { state and 1 or 0, id },
    function(affectedRows)
      if affectedRows > 0 then
        if _properties[id] then
          _properties[id].foreclosed = state

          TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])
        end
        p:resolve(true)
      else
        p:resolve(false)
      end
    end)
  return Citizen.Await(p)
end)

exports('IsNearProperty', function(source)
  local myPos = GetEntityCoords(GetPlayerPed(source))
  local closest = nil
  for k, v in pairs(_properties) do
    local dist = #(myPos - vector3(v.location.front.x, v.location.front.y, v.location.front.z))
    if dist < 3.0 and (not closest or dist < closest.dist) then
      closest = {
        dist = dist,
        propertyId = v.id,
      }
    end
  end
  return closest
end)

exports('SetLock', function(id, locked)
  if _properties[id] then
    _properties[id].locked = locked
    TriggerClientEvent("Properties:Client:SetLocks", -1, id, _properties[id].locked)
    return true
  else
    return false
  end
end)

exports('ToggleLock', function(id)
  if _properties[id] then
    _properties[id].locked = not _properties[id].locked
    TriggerClientEvent("Properties:Client:SetLocks", -1, id, _properties[id].locked)
    return true
  else
    return false
  end
end)

exports('GiveKey', function(charData, id, isOwner, permissions, updating)
  local p = promise.new()

  local currentKeys = _properties[id] and _properties[id].keys or {}
  currentKeys[charData.ID] = {
    Char = charData.ID,
    First = charData.First,
    Last = charData.Last,
    SID = charData.SID,
    Owner = isOwner,
    Permissions = permissions,
  }
  local keysJson = json.encode(currentKeys)

  exports.oxmysql:update('UPDATE properties SET `keys` = ? WHERE id = ?', { keysJson, id }, function(affectedRows)
    if affectedRows > 0 then
      if _properties[id] then
        _properties[id].keys = currentKeys
      end

      TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])

      if not updating then
        if _charPropertyKeys[charData.ID] ~= nil then
          local t = _charPropertyKeys[charData.ID]
          table.insert(t, id)
          _charPropertyKeys[charData.ID] = t
        else
          _charPropertyKeys[charData.ID] = {
            id,
          }
        end
      end
      p:resolve(true)
    else
      p:resolve(false)
    end

    if charData.Source then
      TriggerClientEvent("Properties:Client:AddBlips", charData.Source)
    end
  end)

  return Citizen.Await(p)
end)

exports('TakeKey', function(target, id)
  local p = promise.new()

  local currentKeys = _properties[id] and _properties[id].keys or {}
  currentKeys[target] = nil
  local keysJson = json.encode(currentKeys)

  exports.oxmysql:update('UPDATE properties SET `keys` = ? WHERE id = ?', { keysJson, id }, function(affectedRows)
    if affectedRows > 0 then
      if _properties[id] then
        _properties[id].keys = currentKeys
      end

      TriggerClientEvent("Properties:Client:Update", -1, id, _properties[id])

      local t = _charPropertyKeys[target]
      if t ~= nil then
        for k, v in ipairs(t) do
          if v == id then
            table.remove(t, k)
            break
          end
        end

        _charPropertyKeys[target] = t
      end
      p:resolve(true)
    else
      p:resolve(false)
    end
  end)
  return Citizen.Await(p)
end)

exports('HasKey', function(id, charId)
  if _properties[id] and _properties[id].keys ~= nil then
    return _properties[id].keys[charId]
  end
  return false
end)

exports('HasKeyBySID', function(id, stateId)
  if _properties[id] and _properties[id].keys ~= nil then
    for k, v in pairs(_properties[id].keys) do
      if v.SID == stateId then
        return true
      end
    end
  end
  return false
end)

exports('HasAccessWithData', function(source, key, value)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char then
    local propertyKeys = _charPropertyKeys[char:GetData("ID")]

    for _, propertyId in ipairs(propertyKeys) do
      local property = _properties[propertyId]
      if property and property.data and ((value == nil and property.data[key]) or property.data[key] == value) then
        return property.id
      end
    end
  end
  return false
end)

exports('Get', function(propertyId)
  return _properties[propertyId]
end)

exports('ForceEveryoneLeave', function(propertyId)
  local property = _properties[propertyId]
  if property then
    if _insideProperties[property.id] then
      for k, v in pairs(_insideProperties[property.id]) do
        TriggerClientEvent("Properties:Client:ForceExitProperty", k, property.id)
      end
    end
  end
end)

exports('GetMaxParkingSpaces', function(propertyId)
  local property = _properties[propertyId]
  if property then
    local garageLevel = (property.upgrades and property.upgrades.garage) or 1

    if garageLevel and garageLevel >= 1 and PropertyGarage[property.type] and PropertyGarage[property.type][garageLevel] then
      return PropertyGarage[property.type][garageLevel].parking
    end
  end
end)

function table.copy(t)
  local u = {}
  for k, v in pairs(t) do
    u[k] = v
  end
  return setmetatable(u, getmetatable(t))
end

exports('ClientEnter', function(source, id)
  TriggerClientEvent("Properties:Client:Enter", source, id)
end)
