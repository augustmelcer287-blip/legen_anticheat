local bansFile = 'data/bans.json'
local bans = {}
local heartbeats = {}
local rate = { explosion = {}, entity = {}, event = {}, detection = {} }

local function loadBans()
    local raw = LoadResourceFile(GetCurrentResourceName(), bansFile)
    bans = raw and json.decode(raw) or {}
    if type(bans) ~= 'table' then bans = {} end
end

local function saveBans()
    SaveResourceFile(GetCurrentResourceName(), bansFile, json.encode(bans, { indent = true }), -1)
end

local function ids(src)
    local t = { license = 'N/A', discord = 'N/A', fivem = 'N/A', steam = 'N/A', ip = 'N/A' }
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find('license:') == 1 then t.license = id end
        if id:find('discord:') == 1 then t.discord = id end
        if id:find('fivem:') == 1 then t.fivem = id end
        if id:find('steam:') == 1 then t.steam = id end
        if id:find('ip:') == 1 then t.ip = id end
    end
    return t
end

local function isAdmin(src) return IsPlayerAceAllowed(src, Config.AdminAce) end
local function hasBypass(src) return IsPlayerAceAllowed(src, Config.BypassAce) end

local function logDiscord(title, desc, color)
    print(('[LegenAC] %s | %s'):format(title, desc:gsub('\n', ' | ')))
    if not Config.DiscordWebhook or Config.DiscordWebhook == '' then return end
    PerformHttpRequest(Config.DiscordWebhook, function() end, 'POST', json.encode({
        username = 'Legen AntiCheat V1',
        embeds = {{ title = title, description = desc, color = color or 11862016, footer = { text = Config.ServerName or 'LegenAC' } }}
    }), { ['Content-Type'] = 'application/json' })
end

local function playerList()
    local out = {}
    for _, src in ipairs(GetPlayers()) do
        src = tonumber(src)
        local i = ids(src)
        out[#out+1] = {
            id = src,
            name = GetPlayerName(src) or 'Unknown',
            license = i.license,
            discord = i.discord,
            fivem = i.fivem,
            ping = GetPlayerPing(src),
            admin = isAdmin(src),
            bypass = hasBypass(src)
        }
    end
    return out
end

local function punish(src, dtype, reason)
    if not src or not GetPlayerName(src) then return end
    if Config.UseAceBypassForDetections and hasBypass(src) then
        logDiscord('Bypassed Detection', ('Player: %s [%s]\nDetection: %s\nReason: %s'):format(GetPlayerName(src), src, dtype, reason), 3447003)
        return
    end
    local action = (Config.Actions and Config.Actions[dtype]) or 'kick'
    local i = ids(src)
    local msg = ('Player: %s [%s]\nLicense: %s\nDiscord: %s\nFiveM: %s\nAction: %s\nReason: %s'):format(GetPlayerName(src), src, i.license, i.discord, i.fivem, action, reason)
    logDiscord('Detection: '..dtype, msg, 15158332)
    if action == 'ban' then
        bans[i.license] = { name = GetPlayerName(src), reason = reason, detection = dtype, time = os.time(), ids = i }
        saveBans()
        DropPlayer(src, 'Legen AntiCheat: '..reason)
    elseif action == 'kick' then
        DropPlayer(src, 'Legen AntiCheat: '..reason)
    end
end

loadBans()

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)
    deferrals.update('Checking Legen AntiCheat bans...')
    local license = 'N/A'
    for _, id in ipairs(GetPlayerIdentifiers(src)) do if id:find('license:') == 1 then license = id end end
    if bans[license] then
        deferrals.done('You are banned by Legen AntiCheat. Reason: '..(bans[license].reason or 'No reason'))
        return
    end
    deferrals.done()
end)

AddEventHandler('playerDropped', function()
    local src = source
    heartbeats[src] = nil
    for _, bucket in pairs(rate) do bucket[src] = nil end
end)

RegisterNetEvent('legenac:heartbeat', function()
    local src = source
    heartbeats[src] = os.time()
end)

CreateThread(function()
    while true do
        Wait(15000)
        local now = os.time()
        for _, src in ipairs(GetPlayers()) do
            src = tonumber(src)
            if not hasBypass(src) then
                local last = heartbeats[src]
                if last and (now - last) > (Config.HeartbeatTimeout or 45) then
                    logDiscord('Heartbeat Warning', ('%s [%s] missed heartbeat for %ss'):format(GetPlayerName(src), src, now-last), 16753920)
                end
            end
        end
    end
end)

RegisterNetEvent('legenac:detection', function(dtype, reason)
    local src = source
    rate.detection[src] = rate.detection[src] or { c = 0, t = os.time() }
    local r = rate.detection[src]
    if os.time() - r.t > 10 then r.c = 0 r.t = os.time() end
    r.c = r.c + 1
    if r.c > 8 then return end
    punish(src, tostring(dtype), tostring(reason))
end)

RegisterNetEvent('legenac:requestOpenMenu', function()
    local src = source
    if not isAdmin(src) then
        TriggerClientEvent('legenac:notify', src, 'No permission. Missing ACE: '..Config.AdminAce)
        return
    end
    TriggerClientEvent('legenac:openMenu', src, { players = playerList(), bans = bans, server = Config.ServerName })
end)

RegisterNetEvent('legenac:getPlayers', function()
    local src = source
    if not isAdmin(src) then return end
    TriggerClientEvent('legenac:updatePlayers', src, playerList())
end)

RegisterNetEvent('legenac:adminBan', function(target, reason)
    local src = source
    if not isAdmin(src) then return end
    target = tonumber(target)
    if not target or not GetPlayerName(target) then TriggerClientEvent('legenac:notify', src, 'Invalid player ID') return end
    local i = ids(target)
    bans[i.license] = { name = GetPlayerName(target), reason = reason, detection = 'Manual Ban', time = os.time(), ids = i, admin = GetPlayerName(src) }
    saveBans()
    logDiscord('Manual Ban', ('Admin: %s\nTarget: %s [%s]\nReason: %s'):format(GetPlayerName(src), GetPlayerName(target), target, reason), 15158332)
    DropPlayer(target, 'Legen AntiCheat: '..reason)
end)

RegisterNetEvent('legenac:adminKick', function(target, reason)
    local src = source
    if not isAdmin(src) then return end
    target = tonumber(target)
    if not target or not GetPlayerName(target) then TriggerClientEvent('legenac:notify', src, 'Invalid player ID') return end
    logDiscord('Manual Kick', ('Admin: %s\nTarget: %s [%s]\nReason: %s'):format(GetPlayerName(src), GetPlayerName(target), target, reason), 16753920)
    DropPlayer(target, 'Legen AntiCheat: '..reason)
end)

RegisterNetEvent('legenac:adminUnban', function(license)
    local src = source
    if not isAdmin(src) then return end
    if bans[license] then
        bans[license] = nil
        saveBans()
        logDiscord('Manual Unban', ('Admin: %s\nLicense: %s'):format(GetPlayerName(src), license), 3066993)
        TriggerClientEvent('legenac:notify', src, 'Unbanned '..license)
    else
        TriggerClientEvent('legenac:notify', src, 'License not found')
    end
end)

AddEventHandler('explosionEvent', function(sender, ev)
    sender = tonumber(sender)
    if hasBypass(sender) then return end
    local lim = Config.ExplosionLimit
    local r = rate.explosion[sender] or { c = 0, t = os.time() }
    if os.time() - r.t > lim.seconds then r.c = 0 r.t = os.time() end
    r.c = r.c + 1
    rate.explosion[sender] = r
    if r.c >= lim.count then
        CancelEvent()
        punish(sender, 'ExplosionSpam', 'Explosion spam detected')
    end
end)

AddEventHandler('entityCreating', function(entity)
    local owner = NetworkGetEntityOwner(entity)
    if not owner or owner == 0 or hasBypass(owner) then return end
    local lim = Config.EntityLimit
    local r = rate.entity[owner] or { c = 0, t = os.time() }
    if os.time() - r.t > lim.seconds then r.c = 0 r.t = os.time() end
    r.c = r.c + 1
    rate.entity[owner] = r
    if r.c >= lim.count then
        CancelEvent()
        punish(owner, 'EntitySpam', 'Entity spam detected')
    end
end)

for _, ev in ipairs(Config.ProtectedEvents or {}) do
    RegisterNetEvent(ev, function()
        local src = source
        if hasBypass(src) then return end
        punish(src, 'EventSpam', 'Blacklisted/protected event triggered: '..ev)
        CancelEvent()
    end)
end
