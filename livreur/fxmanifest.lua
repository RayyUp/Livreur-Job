fx_version 'cerulean'
game 'gta5'

author 'Rayy'
description 'Livreur'
version '1.0.0'

dependencies {
    'es_extended',
    'oxmysql'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

