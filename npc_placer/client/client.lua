local globalNPCs = {}
local clothingComponents = {
    head = {id = 0, label = 'Head', texture = false, icon = 'face-smile'}, -- Head
    beard = {id = 1, label = 'Beard', texture = false, icon = 'face-smile'}, -- Beard
    hair = {id = 2, label = 'Hair', texture = true, icon = 'face-smile'}, -- Hair
    upper = {id = 3, label = 'Torso', texture = true, icon = 'person'}, -- Shirt
    lower = {id = 4, label = 'Legs', texture = true, icon = 'person'}, -- Pants
    hand = {id = 5, label = 'Hands', texture = false, icon = 'hand'}, -- Hands
    feet = {id = 6, label = 'Feet', texture = true, icon = 'shoe-prints'}, -- Shoes
    accessories = {id = 8, label = 'Accessories', texture = true, icon = 'hat-wizard'}, -- Accessories
    task = {id = 9, label = 'Tasks', texture = false, icon = 'question'}, -- Tasks
    decl = {id = 10, label = 'Decals', texture = false, icon = 'person'}, -- Decals
    jbib = {id = 11, label = 'Jackets', texture = true, icon = 'person'}, -- Shirts/Jackets
}

local propsComponents = {
    head = {id = 0, label = 'Hat', texture = true, icon = 'hat-wizard'}, -- Hat
    eyes = {id = 1, label = 'Glasses', texture = true, icon = 'glasses'}, -- Glasses
    ears = {id = 2, label = 'Earrings', texture = false, icon = 'ear-listen'}, -- Earrings
}

CreateThread(function ()
    TriggerServerEvent('npc_placer:sync')
end)

RegisterCommand('npcplacer', function ()
    lib.registerContext({
        id = 'npc_placer',
        title = 'NPC Placer',
        options = {
            {
                title = 'Place NPC',
                event = 'npc_placer:place',
                icon = 'user',
            },
            {
                title = 'Edit NPC',
                event = 'npc_placer:edit',
                icon = 'users',
            }
        },
    })

    lib.showContext('npc_placer')
end)

RegisterNetEvent('npc_placer:edit', function ()
    local npcs = lib.callback.await('npc_placer:getNPCs')

    if not npcs or #npcs == 0 then
        lib.notify({ title = 'NPC Placer', description = 'No NPCs to manage.', type = 'info' })
        return
    end

    local npctable = {}
    for _, npc in ipairs(npcs) do
        table.insert(npctable, {
            title = string.format('%s - %s', npc.key, npc.model),
            description = string.format('Coords: %s, %s, %s', npc.coords.x, npc.coords.y, npc.coords.z),
            icon = 'user',
            onSelect = function ()
                lib.registerContext({
                    id = 'npc_placer_edit_' .. npc.key,
                    title = string.format('Manage NPC (%s)', npc.key),
                    options = {
                        {
                            title = 'Delete NPC',
                            icon = 'trash',
                            onSelect = function ()
                                TriggerServerEvent('npc_placer:delete', npc.key, true)
                                lib.notify({ title = 'NPC Placer', description = 'NPC deleted.', type = 'success' })
                            end,
                        },
                        {
                            title = 'Teleport to NPC',
                            icon = 'location-arrow',
                            onSelect = function ()
                                SetEntityCoords(PlayerPedId(), npc.coords.x, npc.coords.y, npc.coords.z)
                                lib.notify({ title = 'NPC Placer', description = 'Teleported to NPC.', type = 'success' })
                            end,
                        },
                        {
                            title = 'Edit NPC Look',
                            icon = 'user-edit',
                            onSelect = function ()
                                TriggerEvent('npc_placer:editLook', npc)
                            end,
                        },
                        {
                            title = 'Edit NPC animations',
                            icon = 'person',
                            onSelect = function ()
                                TriggerEvent('npc_placer:editAnimation', npc)
                            end,
                        },
                    },
                })

                lib.showContext('npc_placer_edit_' .. npc.key)
            end
        })
    end

    lib.registerContext({
        id = 'npc_placer_edit',
        title = 'Manage NPCs',
        options = npctable,
    })

    lib.showContext('npc_placer_edit')
end)

RegisterNetEvent('npc_placer:editAnimation', function (npc)
    local animData = {}
    local animInput = lib.inputDialog('Animation Options', {
        {type = 'input', label = 'Dict', description = 'The animation dictionary'},
        {type = 'input', label = 'Name', description = 'The animation name'},
        {type = 'input', label = 'Flag', description = 'Flag for the animation (Default: 1)'},
    })

    if animInput then
        animData = {
            dict = animInput[1],
            name = animInput[2],
            flag = animInput[3] or 1
        }
    else
        lib.notify({
            title = 'NPC Placer',
            description = 'No animation options selected!',
            type = 'info'
        })
    end

    TriggerServerEvent('npc_placer:updateAnim', npc.key, animData)
end)

RegisterNetEvent('npc_placer:editLook', function (npc)
    local clothingInputs = {}
    for _, comp in pairs(clothingComponents) do
        table.insert(clothingInputs, {
            type = 'number',
            label = comp.label .. ' Drawable',
            description = string.format('Enter drawable ID for %s', comp.label),
            icon = comp.icon
        })
        if comp.texture then
            table.insert(clothingInputs, {
                type = 'number',
                label = comp.label .. ' Texture',
                description = string.format('Enter texture ID for %s', comp.label),
                icon = 'bars',
            })
        end
    end

    local clothingInput = lib.inputDialog('Edit NPC Clothing', clothingInputs)
    if not clothingInput then
        lib.notify({ title = 'NPC Placer', description = 'No changes made to clothing.', type = 'info' })
        return
    end

    local propsInputs = {}
    for _, prop in pairs(propsComponents) do
        table.insert(propsInputs, {
            type = 'number',
            label = prop.label .. ' Drawable',
            description = string.format('Enter drawable ID for %s', prop.label),
            icon = prop.icon
        })
        if prop.texture then
            table.insert(propsInputs, {
                type = 'number',
                label = prop.label .. ' Texture',
                description = string.format('Enter texture ID for %s', prop.label),
                icon = 'bars',
            })
        end
    end

    local propsInput = lib.inputDialog('Edit NPC Props', propsInputs)
    if not propsInput then
        lib.notify({ title = 'NPC Placer', description = 'No changes made to props.', type = 'info' })
        return
    end

    local clothingData = {}
    local propsData = {}
    local index = 1
    for name, comp in pairs(clothingComponents) do
        clothingData[name] = {
            drawable = tonumber(clothingInput[index]) or 0,
            texture = comp.texture and tonumber(clothingInput[index + 1]) or 0
        }
        index = index + (comp.texture and 2 or 1)
    end

    index = 1
    for name, prop in pairs(propsComponents) do
        propsData[name] = {
            drawable = tonumber(propsInput[index]) or 0,
            texture = prop.texture and tonumber(propsInput[index + 1]) or 0,
        }
        index = index + (prop.texture and 2 or 1)
    end

    TriggerServerEvent('npc_placer:updatelook', npc.key, clothingData, propsData)
end)

RegisterNetEvent('npc_placer:place', function ()
    local input = lib.inputDialog('NPC Placer', {
        {type = 'input', label = 'Model', description = 'What ped model?', required = true},
        {type = 'checkbox', label = 'Use your coords?'},
        {type = 'checkbox', label = 'Clothing?'},
        {type = 'checkbox', label = 'Props?'},
        {type = 'checkbox', label = 'Animation?'},
    })

    if input then
        local model = input[1]
        local clothingData = {}
        local propsData = {}
        local animData = {}
        local ped = PlayerPedId()

        if input[3] then -- Clothing 
            local clothingInputs = {}
            for _, comp in pairs(clothingComponents) do
                table.insert(clothingInputs, {
                    type = 'number',
                    label = comp.label .. ' Drawable',
                    description = string.format('Enter drawable ID for %s', comp.label),
                    icon = comp.icon
                })
                if comp.texture then
                    table.insert(clothingInputs, {
                        type = 'number',
                        label = comp.label .. ' Texture',
                        description = string.format('Enter texture ID for %s', comp.label),
                        icon = 'bars',
                    })
                end
            end

            local clothingInput = lib.inputDialog('Clothing Options', clothingInputs)

            if clothingInput then
                local index = 1
                for name, comp in pairs(clothingComponents) do
                    clothingData[name] = {
                        drawable = tonumber(clothingInput[index]) or 0,
                        texture = comp.texture and tonumber(clothingInput[index + 1]) or 0
                    }
                    index = index + (comp.texture and 2 or 1)
                end
            else
                lib.notify({
                    title = 'NPC Placer',
                    description = 'No clothing options selected!',
                    type = 'info'
                })
            end
        end

        if input[4] then -- Props
            local propInputs = {}
            for _, prop in pairs(propsComponents) do
                table.insert(propInputs, {
                    type = 'number',
                    label = prop.label .. ' Drawable',
                    description = string.format('Enter drawable ID for %s', prop.label),
                    icon = prop.icon
                })
                if prop.texture then
                    table.insert(propInputs, {
                        type = 'number',
                        label = prop.label .. ' Texture',
                        description = string.format('Enter texture ID for %s', prop.label),
                        icon = 'bars',
                    })
                end
            end

            local propInput = lib.inputDialog('Prop Options', propInputs)

            if propInput then
                local index = 1
                for name, prop in pairs(propsComponents) do
                    propsData[name] = {
                        drawable = tonumber(propInput[index]) or 0,
                        texture = prop.texture and tonumber(propInput[index + 1]) or 0,
                    }
                    index = index + (prop.texture and 2 or 1)
                end
            else
                lib.notify({
                    title = 'NPC Placer',
                    description = 'No prop options selected!',
                    type = 'info'
                })
            end
        end

        if input[5] then -- Animation
            local animInput = lib.inputDialog('Animation Options', {
                {type = 'input', label = 'Dict', description = 'The animation dictionary'},
                {type = 'input', label = 'Name', description = 'The animation name'},
                {type = 'input', label = 'Flag', description = 'Flag for the animation (Default: 1)'},
            })


            if animInput then
                animData = {
                    dict = animInput[1],
                    name = animInput[2],
                    flag = animInput[3] or 1
                }
            else
                lib.notify({
                    title = 'NPC Placer',
                    description = 'No animation options selected!',
                    type = 'info'
                })
            end
        end

        if not input[2] then
            local coords, heading = StartRay(model)
            if coords ~= nil then
                TriggerServerEvent('npc_placer:place', coords, heading, model, clothingData, propsData, animData)
            else
                lib.notify({
                    title = 'NPC Placer',
                    description = 'No coords selected!',
                    type = 'info'
                })
            end
        else
            TriggerServerEvent('npc_placer:place', GetEntityCoords(ped), GetEntityHeading(ped), model, clothingData, propsData, animData)
        end
    else
        lib.notify({
            title = 'NPC Placer',
            description = 'Please enter a model!',
            type = 'error'
        })
    end
end)

RegisterNetEvent('npc_placer:spawn', function (coords, heading, model, key, clothing, props, anim)
    local hash = GetHashKey(model)
    lib.requestModel(hash)
    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z, heading, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetModelAsNoLongerNeeded(hash)

    if anim.dict ~= nil == true and anim.dict == '' == false then
        lib.requestAnimDict(anim.dict)
        TaskPlayAnim(ped, anim.dict, anim.name, 8.0, -8.0, -1, anim.flag or 1, 0, false, false, false)
        RemoveAnimDict(anim.dict)
    end

    for compName, data in pairs(clothing) do
        local component = clothingComponents[compName:lower()]
        if component then
            SetPedComponentVariation(ped, component.id, data.drawable, data.texture or 0, 2)
        else
            debugPrint(string.format("Invalid component name: %s", compName))
        end
    end

    for propName, data in pairs(props) do
        local prop = propsComponents[propName:lower()]
        if prop then
            SetPedPropIndex(ped, prop.id, data.drawable, data.texture or 0, true)
        else
            debugPrint(string.format("Invalid prop name: %s", propName))
        end
    end
    
    globalNPCs[key] = { ped = ped, coords = coords, heading = heading, model = model, clothing = clothing }

    debugPrint(string.format('Spawned NPC %s at %s', model, json.encode(coords)))
end)

RegisterNetEvent('npc_placer:delete', function (index)
    for k, v in pairs(globalNPCs) do
        if k == index then
            DeleteEntity(v.ped)
            globalNPCs[k] = nil
            debugPrint(string.format('Deleted NPC %s', k))
            break
        end
    end
end)