local run = false

function debugPrint(msg)
    if Config.Debug then
        print(msg)
    end
end

---@comment Thanbks to @Mustachedom for this function.
---@comment https://github.com/Mustachedom/md-props/blob/343f78f14d7b4551083b2e2c104013703b605a50/client/client.lua#L4
function StartRay(model)
	local heading = 180.0
	local created = false
	local coord = GetEntityCoords(PlayerPedId())
	lib.requestModel(model, 30000)
    local entity = CreatePed(4, GetHashKey(model), coord.x, coord.y, coord.z, heading, false, false)
    local z = math.floor(coord.z * 100) / 100
    run = true
    repeat
        local hit, entityHit, endCoords, surfaceNormal, matHash = lib.raycast.fromCamera(511, 4, 30)
        if not created then 
            created = true
            lib.showTextUI('[ E ] To Place  \n  [ DEL ] To Cancel  \n  [ ← ] To Rotate Left  \n  [ → ] To Rotate Right  \n  [ ↑ ] To Go Up  \n  [ ↓ ] To Go Down')
        else
            SetEntityCoords(entity, endCoords.x, endCoords.y, z)
            SetEntityHeading(entity, heading)
            SetEntityCollision(entity, false, false)
        end
        if IsControlPressed(0, 174) then heading = heading - 1 end
        if IsControlPressed(0, 175) then heading = heading + 1 end
        if IsControlPressed(0, 172) then z = z + 0.01 end 
        if IsControlPressed(0, 173) then z = z - 0.01 end
        if IsControlPressed(0, 38) then
            lib.hideTextUI()
            run = false
            DeleteEntity(entity)
            local loc = vector3(math.floor(endCoords.x * 100) / 100, math.floor(endCoords.y * 100) / 100, math.floor(endCoords.z * 100) / 100)
            return loc, heading
        end

        if IsControlPressed(0, 178) then
            lib.hideTextUI()
            run = false
            DeleteEntity(entity)
            return nil
        end
    until run == false
end