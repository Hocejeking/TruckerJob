ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)







RegisterServerEvent('trucker:vyplata')
AddEventHandler('trucker:vyplata', function()

    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addMoney(Config.payout)
    TriggerClientEvent('mystic:notify', source, 'Úspěsně si odevzdal zakázku a získal si '..Config.payout.. " $", 'succes')
    
end)