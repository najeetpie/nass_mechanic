RegisterServerEvent('nass_mechanic:triggerServerSync')
AddEventHandler('nass_mechanic:triggerServerSync', function(repairCost, mech, veh, engine)
    if Config.chargeForRepair then
        RemoveMoney(source, "money", repairCost)
    end
    Wait(200)
    TriggerClientEvent('nass_mechanic:triggerClientSyncAnim', -1, mech, veh, engine)
    
end)

RegisterCallback("nass_mechanic:checkForMechanics", function(source, cb)
    local Players = GetPlayers()
    local count = 0
    for i=1, #Players, 1 do
        if getJob(Players[i]) == "mechanic" then
            count = count +1
        end
    end
    cb(count)
end)