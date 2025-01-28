local function loadNPCs()
    local content = LoadResourceFile(GetCurrentResourceName(), "npcs.json")
    if content then
        return json.decode(content) or {}
    end
    return {}
end

local function saveNPCs(npcs)
    local content = json.encode(npcs)
    SaveResourceFile(GetCurrentResourceName(), "npcs.json", content, -1)
end

local npcs = loadNPCs()

RegisterNetEvent('npc_placer:place', function (coords, heading, model, clothing, props, anim)
    local key = #npcs + 1
    npcs[key] = { 
        coords = coords, 
        heading = heading, 
        model = model, 
        clothing = clothing, 
        props = props, 
        anim = anim, 
        key = key 
    }
    saveNPCs(npcs)
    TriggerClientEvent('npc_placer:spawn', -1, coords, heading, model, key, clothing, props, anim)
end)

RegisterNetEvent('npc_placer:sync', function ()
    for _, npc in ipairs(npcs) do
        TriggerClientEvent('npc_placer:spawn', source, npc.coords, npc.heading, npc.model, npc.key, npc.clothing, npc.props, npc.anim)
    end
end)

RegisterNetEvent('npc_placer:delete', function (index, removeFromTable)
    if removeFromTable then
        table.remove(npcs, index)
    end

    for i, npc in ipairs(npcs) do
        npc.key = i
    end

    saveNPCs(npcs)
    TriggerClientEvent('npc_placer:delete', -1, index)
end)

RegisterNetEvent('npc_placer:updatelook', function (key, clothing, props)
    local src = source

    if not npcs[key] then
        TriggerClientEvent('npc_placer:notify', src, { title = "Error", description = "NPC not found.", type = "error" })
        return
    end

    npcs[key].clothing = clothing
    npcs[key].props = props

    saveNPCs(npcs)
    TriggerEvent('npc_placer:delete', key, false)
    TriggerClientEvent('npc_placer:spawn', -1, npcs[key].coords, npcs[key].heading, npcs[key].model, key, clothing, props, npcs[key].anim)
end)

RegisterNetEvent('npc_placer:updateAnim', function (key, anim)
    local src = source

    if not npcs[key] then
        TriggerClientEvent('npc_placer:notify', src, { title = "Error", description = "NPC not found.", type = "error" })
        return
    end

    npcs[key].anim = anim

    print(json.encode(npcs[key].anim))

    saveNPCs(npcs)
    TriggerEvent('npc_placer:delete', key, false)
    TriggerClientEvent('npc_placer:spawn', -1, npcs[key].coords, npcs[key].heading, npcs[key].model, key, npcs[key].clothing, npcs[key].props, npcs[key].anim)
end)

lib.callback.register('npc_placer:getNPCs', function ()
    return npcs
end)