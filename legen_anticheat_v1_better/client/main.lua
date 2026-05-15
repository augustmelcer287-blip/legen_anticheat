local menuOpen = false
local lastOpen = 0

local function notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

RegisterCommand(Config.Command, function()
    if GetGameTimer() - lastOpen < 1000 then return end
    lastOpen = GetGameTimer()
    TriggerServerEvent('legenac:requestOpenMenu')
end, false)

RegisterNetEvent('legenac:openMenu', function(payload)
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = payload })
end)

RegisterNetEvent('legenac:closeMenu', function()
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end)

RegisterNetEvent('legenac:notify', function(msg)
    notify('~r~LegenAC~s~: '..tostring(msg))
end)

RegisterNetEvent('legenac:updatePlayers', function(players)
    SendNUIMessage({ action = 'players', players = players })
end)

RegisterNUICallback('close', function(_, cb)
    menuOpen = false
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

RegisterNUICallback('refresh', function(_, cb)
    TriggerServerEvent('legenac:getPlayers')
    cb({ ok = true })
end)

RegisterNUICallback('ban', function(data, cb)
    TriggerServerEvent('legenac:adminBan', tonumber(data.id), tostring(data.reason or 'Manual admin ban'))
    cb({ ok = true })
end)

RegisterNUICallback('kick', function(data, cb)
    TriggerServerEvent('legenac:adminKick', tonumber(data.id), tostring(data.reason or 'Manual admin kick'))
    cb({ ok = true })
end)

RegisterNUICallback('unban', function(data, cb)
    TriggerServerEvent('legenac:adminUnban', tostring(data.license or ''))
    cb({ ok = true })
end)

RegisterNUICallback('copy', function(_, cb)
    cb({ ok = true })
end)

CreateThread(function()
    Wait(5000)
    while true do
        TriggerServerEvent('legenac:heartbeat', GetPlayerServerId(PlayerId()))
        Wait(Config.HeartbeatInterval or 10000)
    end
end)

CreateThread(function()
    while true do
        Wait(Config.CheckInterval or 2500)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            local hp = GetEntityHealth(ped)
            local armor = GetPedArmour(ped)
            if hp > (Config.MaxHealth or 250) or armor > (Config.MaxArmor or 100) then
                TriggerServerEvent('legenac:detection', 'InvalidHealthArmor', ('Invalid health/armor | HP: %s Armor: %s'):format(hp, armor))
            end
            local weapon = GetSelectedPedWeapon(ped)
            if Config.BlacklistedWeapons[weapon] then
                RemoveWeaponFromPed(ped, weapon)
                TriggerServerEvent('legenac:detection', 'BlacklistedWeapon', 'Blacklisted weapon: '..Config.BlacklistedWeapons[weapon])
            end
        end
    end
end)

AddEventHandler('onClientResourceStop', function(res)
    if res == GetCurrentResourceName() and menuOpen then
        SetNuiFocus(false, false)
    end
end)
