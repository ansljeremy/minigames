fx_version 'cerulean'
game 'gta5'

description 'Minigames'
version '0.1.0'

author 'Idris et al.'

ui_page "html/index.html"
shared_script '@qb-core/import.lua'
client_script 'client.lua'

files {
    'html/index.html',
    'html/main.js',
    'html/style.css',
}

exports {
    'GetMinigameObject'
}

dependencies {
    'qb-core'
}
