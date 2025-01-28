fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'emptyy'
description 'NPC Placer. Thanks to @SnakeSeargent (github) for the idea.'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/shared.lua',
}

client_scripts {
    'client/utils.lua',
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}

files {
    'npcs.json',
}