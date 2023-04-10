--Main Creation Thread
Citizen.CreateThread(function()
	for _,v in pairs(Config.PedList) do
		RequestModel(GetHashKey(v.ped))
		while not HasModelLoaded(GetHashKey(v.ped)) do
			Wait(1)
		end
		ped = CreatePed(4, GetHashKey(v.ped), v.pos.x, v.pos.y, v.pos.z, v.pos.w, false, false)

		v.newPed = ped
		SetEntityHeading(ped, v.pos.w)
		FreezeEntityPosition(ped, true)
		SetEntityInvincible(ped, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
		if Config.useTarget then
			createTarget(v)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		if Config.useTarget then
			break;
		end
		local sleep = 5000
		local plyped = PlayerPedId()
		for _,v in pairs(Config.PedList) do
			if #(GetEntityCoords(plyped) - v.pos.xyz) < 20 then
				sleep = 0
				if #(GetEntityCoords(plyped) - v.pos.xyz) < 1.9 then
					ShowHelpNotification("Press ~INPUT_CONTEXT~ to ask "..v.name.." to repair your vehicle")
					if IsControlJustPressed(0, 51) then
						TriggerEvent("nass_mechanic:startvehrepair", {name = v.name})
					end
				end
			end
		end
		Wait(sleep)
	end
end)


AddEventHandler('nass_mechanic:startvehrepair', function(data)
	if Config.checkForOnlineMechanic then
		ServerCallback('nass_mechanic:checkForMechanics', function(mechNum) 
			if mechNum > 0 then
				ShowNotification('There is a mechanic in the city, contact them.')
			else
				verRepFunc(data)
			end
		end)
	else
		verRepFunc(data)
	end
end)

function verRepFunc(data)
	local mechped = GetClosestMech()
	if mechped == nil then
		ShowNotification(data.name ..' is busy, let him finish.')
	else
		startCarRepair(mechped)
	end
end


function createTarget(ent)
	exports.qtarget:AddTargetEntity(ent.newPed, {
		options = {
			{
				event = "nass_mechanic:startvehrepair",
				icon = "fa-solid fa-wrench",
				label = "Repair Vehicle",
				name = ent.name
			},
		},
		distance = 1.5
	})
end
function startCarRepair(mech)
	local playerPed = PlayerPedId()
	if GetVehiclePedIsIn(playerPed, false) ~= 0 then
		ShowNotification('Get out of the vehicle.')
	else
		local veh = GetVehiclePedIsIn(playerPed,true)
		if veh then
			local engine = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, "engine"))
			if engine == vector3(0.0, 0.0, 0.0) then
				engine = GetEntityCoords(veh)
			end
			if #(engine - mech.pos.xyz) < 20 then
				local repairCost = math.floor((1000 - GetVehicleEngineHealth(veh))/1000*Config.price*Config.DamageMultiplier)
				if Config.chargeForRepair then
					if getCash() >= repairCost then	
						ShowNotification(mech.name.." says he can fix it")
						TriggerServerEvent("nass_mechanic:triggerServerSync", repairCost, mech, veh, engine)
					else
						ShowNotification('You can\'t afford that. The repair will cost $'..repairCost..' ')
					end	
				else
					ShowNotification(mech.name.." says he can fix it")
					TriggerServerEvent("nass_mechanic:triggerServerSync", repairCost, mech, veh, engine)
				end
			else
				ShowNotification('Vehicle is too far.')
			end
		else
			ShowNotification('Vehicle was not found.')
		end
	end
end

RegisterNetEvent('nass_mechanic:triggerClientSyncAnim')
AddEventHandler('nass_mechanic:triggerClientSyncAnim', function(firstclmech, veh, engine)
	
	local mech = GetClosestMech(firstclmech.pos)
	FreezeEntityPosition(mech.newPed, false)
	TaskGoStraightToCoord(mech.newPed,engine.x, engine.y, engine.z, 1.0, 5000, (GetEntityHeading(veh)-180), 0)
	Wait(200)
	while #(engine.xyz - GetEntityCoords(mech.newPed, true)) > 2 do
		Wait(200)
	end

	Wait(1000)
	SetVehicleDoorOpen(veh, 4, false, false)

	TaskTurnPedToFaceCoord(mech.newPed, engine.x, engine.y, engine.z, -1)

	Wait(500)

	TaskStartScenarioInPlace(mech.newPed, "PROP_HUMAN_BUM_BIN", 0, 1)
	Wait(15000)

	ClearPedTasksImmediately(mech.newPed)

	SetVehicleFixed(veh)
    SetVehicleUndriveable(veh, false)
    SetVehicleEngineOn(veh, true, true)
	SetVehicleDoorShut(veh, 4, false)

	Wait(500)
	TaskGoStraightToCoord(mech.newPed, mech.pos.x, mech.pos.y, mech.pos.z+1, 1.0, 5000, mech.pos.w, 0)
	while #(mech.pos.xyz - GetEntityCoords(mech.newPed, true)) > 1.5 do
		Wait(200)
	end

	SetEntityHeading(mech.newPed, mech.pos.w) 
	

	
	FreezeEntityPosition(mech.newPed, true)
end)

function GetClosestMech(orgPos)
	if orgPos then
		for k,v in pairs(Config.PedList) do
			if #(orgPos.xyz - v.pos.xyz) < 2 then
				return v
			end
		end
	else
		for k,v in pairs(Config.PedList) do
			local pedCoords = GetEntityCoords(PlayerPedId(), true)
			if #(v.pos.xyz - pedCoords) < 2 then
				return v
			end
		end
	end
end

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	for k,v in pairs(Config.PedList) do
		DeleteEntity(v.newPed)
	end
end)

function ShowNotification(msg, _type)
	if GetResourceState('es_extended') == 'started' or GetResourceState('qb-core') == 'started' then
	     notify(msg, _type)
	else
	    if GetResourceState('nass_notifications') == 'started' then
		exports["nass_notifications"]:ShowNotification("alert", "Info", msg, 5000)
	    else
		BeginTextCommandThefeedPost('STRING')
		AddTextComponentSubstringPlayerName(msg)
		EndTextCommandThefeedPostTicker(0, 1)
	    end
	end
end

function ShowHelpNotification(msg)
	AddTextEntry('helpnotification', msg) 
	BeginTextCommandDisplayHelp('helpnotification')
	EndTextCommandDisplayHelp(0, false, false, -1) 
end
