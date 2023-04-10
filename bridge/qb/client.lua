if GetResourceState('qb-core') ~= 'started' then return end
QBCore = exports['qb-core']:GetCoreObject()
Framework, PlayerLoaded, PlayerData = 'qb', nil, {}

AddStateBagChangeHandler('isLoggedIn', '', function(_bagName, _key, value, _reserved, _replicated)
    if value then
        PlayerData = QBCore.Functions.GetPlayerData()
    else
        table.wipe(PlayerData)
    end
    PlayerLoaded = value
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName or not LocalPlayer.state.isLoggedIn then return end
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerLoaded = true
end)


RegisterNetEvent('QBCore:Client:OnMoneyChange', function()
	PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(newPlayerData)
    if source ~= '' and GetInvokingResource() ~= 'qb-core' then return end
    PlayerData = newPlayerData
end)

function notify(msg, type)
    if GetResourceState('nass_notifications') == 'started' then
        exports["nass_notifications"]:ShowNotification("alert", "Info", msg, 5000)
    else
        ESX.ShowNotification(msg)
    end
end

function ServerCallback(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb,  ...)
end

function getName()
    return PlayerData.charinfo.firstname .." ".. PlayerData.charinfo.lastname
end

function getJobName()
    return PlayerData.job.label .." - ".. PlayerData.job.grade.name
end

function getCash()
    return PlayerData.money.cash
end

function getBank()
    return PlayerData.money.bank
end


--[[
function getBank()
    for k,v in pairs(PlayerData.accounts) do
        if v.name == "bank" then
            return v.money
        end
    end
end]]
