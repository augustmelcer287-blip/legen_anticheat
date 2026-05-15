fx_version 'cerulean'
game 'gta5'

name 'Legen AntiCheat V1'
author 'Legendary Development'
description 'Stable V1 anticheat with NUI admin panel, ACE perms, logs, bans, heartbeat, blacklist checks'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
