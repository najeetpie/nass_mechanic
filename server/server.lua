RegisterServerEvent('nass_mechanic:triggerServerSync')
AddEventHandler('nass_mechanic:triggerServerSync', function(repairCost, mech, veh, engine)
    if Config.chargeForRepair then
        RemoveMoney(source, "money", repairCost)
    end
    Wait(200)
    TriggerClientEvent('nass_mechanic:triggerClientSyncAnim', -1, mech, veh, engine)
    
end)

