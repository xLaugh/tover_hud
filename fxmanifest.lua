fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

shared_scripts {
    '@es_extended/imports.lua'
}

client_scripts {
	'cl_hud.lua',
	'config.lua'
}

server_scripts {
	'sv_hud.lua'
}

files {
	'html/index.html',
	'html/main.js',
}