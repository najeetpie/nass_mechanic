if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports['es_extended']:getSharedObject()
Framework = 'esx'

function GetPlayer(src)
    return ESX.GetPlayerFromId(src)
end

function GetPlayerFromIdentifier(identifier)
    local player = ESX.GetPlayerFromIdentifier(identifier)
    if not player then return false end
    return player
end

function GetPlayers()
    return ESX.GetPlayers()
end

function RegisterCallback(name, cb)
    ESX.RegisterServerCallback(name, cb)
end

function AddMoney(source, type, amount)
    if type == 'cash' then type = 'money' end
    local player = GetPlayer(source)
    player.addAccountMoney(type, amount)
end

function RemoveMoney(source, type, amount)
    if type == 'cash' then type = 'money' end
    local player = GetPlayer(source)
    player.removeAccountMoney(type, amount)
end

function GetPlayerAccountFunds(source, type)
    if type == 'cash' then type = 'money' end
    local player = GetPlayer(source)
    return player.getAccount(type).money
end
