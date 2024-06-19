-- Utilisez l'importation recommandée pour obtenir l'objet ESX
ESX = exports["es_extended"]:getSharedObject()

-- Enregistrez l'item "roller" pour qu'il puisse être utilisé
ESX.RegisterUsableItem('roller', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('esx:useItem', source, 'roller')
end)
