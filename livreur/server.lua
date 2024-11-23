ESX = exports['es_extended']:getSharedObject()

local deliveryPoints = {
    {x = 454.60, y = -599.34, z = 28.56},

}

RegisterNetEvent('delivery:payPlayer')
AddEventHandler('delivery:payPlayer', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local reward = math.random(100, 300)  
        xPlayer.addMoney(reward)  
        TriggerClientEvent('esx:showNotification', source, ('Mission accomplie! Vous avez reçu $%s'):format(reward))
    else
        print('Erreur: Joueur non trouvé pour le paiement')
    end
end)

RegisterNetEvent('delivery:getPoints')
AddEventHandler('delivery:getPoints', function()
    TriggerClientEvent('delivery:setPoints', source, deliveryPoints) 
end)
