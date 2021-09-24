fx_version 'cerulean'
game 'gta5'

description 'Minigame'
version '0.1.0'

ui_page "html/index.html"
shared_script '@core/import.lua'
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
    'core'
}
