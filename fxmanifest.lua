-- Spécifie la version de fxserver utilisée
fx_version 'cerulean'

-- Spécifie le jeu pour lequel ce script est destiné
game 'gta5'

-- Utilise la version Lua 5.4
lua54 'yes'

-- Informations sur la ressource
name 'Roller'  -- Nom de la ressource
version '1.0.0'  -- Version de la ressource
description 'Roller'  -- Description de la ressource
author 'Axl.Mrt'  -- Auteur de la ressource
contact 'imbadplayeur'  -- Contact de l'auteur
url 'https://discord.gg/faXkZGu3Xc'  -- URL pour plus d'informations ou support

-- Script partagé de ESX pour les imports
shared_script '@es_extended/imports.lua'

-- Inclusion des scripts partagés
shared_scripts {
    'shared/*.lua',  -- Inclut tous les fichiers .lua dans le dossier shared
}

-- Inclusion des scripts client
client_scripts {
    'client/*.lua',  -- Inclut tous les fichiers .lua dans le dossier client
}

-- Inclusion des scripts serveur
server_scripts {
    'server/*.lua'  -- Inclut tous les fichiers .lua dans le dossier server
}
