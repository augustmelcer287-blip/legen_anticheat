Config = {}

Config.Command = 'ssm'
Config.AdminAce = 'legenac.admin'
Config.BypassAce = 'legenac.bypass'
Config.UseAceBypassForDetections = true

Config.DiscordWebhook = '' -- put webhook here
Config.ServerName = 'Bayou State Roleplay'

Config.HeartbeatInterval = 10000 -- client sends every 10s
Config.HeartbeatTimeout = 45000 -- server flags if missing 45s

Config.Actions = {
    BlacklistedWeapon = 'ban', -- ban/kick/log
    ExplosionSpam = 'ban',
    EntitySpam = 'kick',
    EventSpam = 'kick',
    InvalidHealthArmor = 'kick'
}

Config.MaxArmor = 100
Config.MaxHealth = 250
Config.CheckInterval = 2500

Config.BlacklistedWeapons = {
    [`WEAPON_RAILGUN`] = 'Railgun',
    [`WEAPON_RAILGUNXM3`] = 'Railgun XM3',
    [`WEAPON_RPG`] = 'RPG',
    [`WEAPON_HOMINGLAUNCHER`] = 'Homing Launcher',
    [`WEAPON_GRENADELAUNCHER`] = 'Grenade Launcher',
    [`WEAPON_MINIGUN`] = 'Minigun',
    [`WEAPON_FIREWORK`] = 'Firework Launcher',
    [`WEAPON_COMPACTLAUNCHER`] = 'Compact Launcher'
}

Config.ExplosionLimit = { count = 4, seconds = 8 }
Config.EntityLimit = { count = 25, seconds = 10 }
Config.EventLimit = { count = 35, seconds = 10 }

Config.ProtectedEvents = {
    'esx:getSharedObject',
    'qb-core:GetObject',
    'HCheat:TempDisableDetection',
    'redst0nia:checking',
    'antilynx8:anticheat'
}
