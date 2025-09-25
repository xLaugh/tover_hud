local isPlayerLoaded = false
local xPlayer = nil
local screenRes = {
    x = nil, 
    y = nil
}

local prox = 0.0
local isTalking = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    isPlayerLoaded = true
    TriggerEvent('es:setMoneyDisplay', 0.0)
    
    xPlayer = playerData

    prox = Config.proximity.whisper
end)

Citizen.CreateThread(function()
    while true do 
        if isPlayerLoaded then 
            local resX, resY = GetActiveScreenResolution()
            if screenRes.x == nil or screenRes.x ~= resX or screenRes.y == nil or screenRes.y ~= resY then 
                MoveHudToCorrectPos()
            end
        end
        Citizen.Wait(10000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(250)
        if MumbleIsPlayerTalking(PlayerId()) == 1 then 
            isTalking = true
        else
            isTalking = false
        end

        local pH = GetEntityHealth(PlayerPedId())
        local pA = GetPedArmour(PlayerPedId())
        SendNUIMessage({action = "setTalking", value = isTalking})
        SendNUIMessage({action = "updatePlayerHealth", values = {health = pH-100, armor = pA}})    
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(7)
        if Config.allowProximityChange then 
            if IsControlJustPressed(1, 243) then
                ExecuteCommand('cycleproximity')
            end
        end
    end
end)

Citizen.CreateThread(function()
    local lastIndex = nil
    local lastModeLabel = nil
    while true do
        Citizen.Wait(200)
        if LocalPlayer and LocalPlayer.state and LocalPlayer.state.proximity then
            local proxState = LocalPlayer.state.proximity
            local index = proxState.index
            local modeLabel = nil
            if index == 1 then
                modeLabel = "whisper"
            elseif index == 2 then
                modeLabel = "normal"
            elseif index == 3 then
                modeLabel = "shout"
            else
                local dist = proxState.distance or 0.0
                if dist <= 3.0 then
                    modeLabel = "whisper"
                elseif dist <= 10.0 then
                    modeLabel = "normal"
                else
                    modeLabel = "shout"
                end
            end
            if index ~= lastIndex or modeLabel ~= lastModeLabel then
                SendNUIMessage({action = "setProximity", value = modeLabel})
                lastIndex = index
                lastModeLabel = modeLabel
            end
        end
    end
end)

function MoveHudToCorrectPos()
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    screenRes.x, screenRes.y = GetActiveScreenResolution()
    local xscale = 1.0 / screenRes.x
    local yscale = 1.0 / screenRes.y
    local Minimap = {}
    Minimap.width = (xscale * (screenRes.x / (4 * aspect_ratio)))
    Minimap.height = yscale * (screenRes.y / 5.674)
    Minimap.left_x = (xscale * (screenRes.x * (safezone_x * ((math.abs(safezone - 1.0)) * 10))))
    Minimap.bottom_y = (1.0 - yscale * (screenRes.y * (safezone_y * ((math.abs(safezone - 1.0)) * 10))))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.xunit = xscale
    Minimap.yunit = yscale
    SendNUIMessage({action = "updateHudPosition", value=Minimap})
end

RegisterNetEvent('tover_hud:toggle')
AddEventHandler('tover_hud:toggle', function(show)
    SendNUIMessage({action = "toggle", show = show})
    DisplayRadar(show)
end)

--RegisterNetEvent('esx_status:onTick')
AddEventHandler('esx_status:onTick', function(status)
    SendNUIMessage({action = "updateStatus", status = status})
end)
