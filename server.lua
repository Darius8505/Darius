local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
MySQL = module("vrp_mysql", "MySQL")

vRPstages = {}
Tunnel.bindInterface("vRP_carStages",vRPstages)
Proxy.addInterface("vRP_carStages",vRPstages)
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_carStages")
vRPCstages = Tunnel.getInterface("vRP_carStages", "vRP_carStages")

MySQL.createCommand("vRP/has_veh_stage", "SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")
MySQL.createCommand("vRP/update_vehicle_stage","UPDATE vrp_user_vehicles SET stage = @stage WHERE user_id = @user_id AND vehicle = @vehicle")

stages = {
	[1] = 25000000,
	[2] = 45000000,
	[3] = 65000000
}

usingStager = nil

function vRPstages.startStageInstall(thePlayer, theStage, theVeh)
	local user_id = vRP.getUserId({thePlayer})
	MySQL.query("vRP/has_veh_stage", {user_id = user_id}, function(vehicles, affected)
		if #vehicles > 0 then
			for i, v in pairs(vehicles) do
				if(v.vehicle == theVeh)then
					if(theStage ~= v.stage)then
						if(vRP.tryFullPayment({user_id, stages[theStage]}))then
							vRPCstages.applyCarStage(thePlayer, {theStage, theVeh})
							vRP.closeMenu({thePlayer})
							usingStager = user_id
							vRPclient.notify(thePlayer, {"~g~Instalare ~y~Stage "..theStage.."!\n~g~Asteapta ~b~3 minute ~g~pana ce upgrade-ul este gata!"})
						else
							vRPclient.notify(thePlayer, {"~r~Nu ai destui bani pentru ~y~Stage "..theStage})
						end
					else
						vRPclient.notify(thePlayer, {"~r~Acest vehicul are deja ~y~Stage "..theStage.." ~r~instalat!"})
					end
				end
			end
		end
	end)
end

function vRPstages.applyStages(stage, vehicle)
	local thePlayer = source
	local user_id = vRP.getUserId({thePlayer})
	vRPCstages.setCarCurrentStage(thePlayer, {stage})
	usingStager = nil
	vRPclient.notify(thePlayer, {"~g~Ti-ai setat ~y~Stage "..stage.." ~g~la masina!"})
	MySQL.execute("vRP/update_vehicle_stage", {vehicle = vehicle, user_id = user_id, stage = stage})
end

function vRPstages.showCarStagesMenu(carModel)
	local thePlayer = source
	local user_id = vRP.getUserId({thePlayer})
	if(usingStager == nil)then
		MySQL.query("vRP/has_veh_stage", {user_id = user_id}, function(vehicles, affected)
			if #vehicles > 0 then
				for i, v in pairs(vehicles) do
					if(GetHashKey(v.vehicle) == carModel)then
						vRP.buildMenu({"Stageuri Valabile", {player = thePlayer}, function(menu)
							menu.name = "Stageuri Valabile"
							menu.css={top="75px",header_color="rgba(235,0,0,0.75)"}
							menu.onclose = function(thePlayer) vRP.openMainMenu({thePlayer}) end	
							menu["Stage 1"] = {function(thePlayer, choice) vRPstages.startStageInstall(thePlayer, 1, v.vehicle) end, "Aplica <font color='green'>Stage 1</font> pe vehicul</br>Pret: <font color='red'>$"..stages[1].."</font>"}
							menu["Stage 2"] = {function(thePlayer, choice) vRPstages.startStageInstall(thePlayer, 2, v.vehicle) end, "Aplica <font color='green'>Stage 2</font> pe vehicul</br>Pret: <font color='red'>$"..stages[2].."</font>"}
							menu["Stage 3"] = {function(thePlayer, choice) vRPstages.startStageInstall(thePlayer, 3, v.vehicle) end, "Aplica <font color='green'>Stage 3</font> pe vehicul</br>Pret: <font color='red'>$"..stages[3].."</font>"}
							vRP.openMenu({thePlayer, menu})
						end})
					end
				end
			end
		end)
	else
		vRPclient.notify(thePlayer, {"~r~Deja se intaleaza un Stage pe un vehicul, asteapta pana ce acesta este gata!"})
	end
end

function vRPstages.closeStageMenu()
	local thePlayer = source
	vRP.closeMenu({thePlayer})
end

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(theVehicle, theSeat, vehicleName, vehModel)
	local thePlayer = source
	local user_id = vRP.getUserId({thePlayer})
	MySQL.query("vRP/has_veh_stage", {user_id = user_id}, function(vehicles, affected)
		if #vehicles > 0 then
			for i, v in pairs(vehicles) do
				if(GetHashKey(v.vehicle) == vehModel)then
					vRPCstages.setCarCurrentStage(thePlayer, {tonumber(v.stage)})
				end
			end
		end
	end)
end)

RegisterNetEvent("baseevents:leftVehicle")
AddEventHandler("baseevents:leftVehicle", function(theVehicle, theSeat, vehicleName)
	local thePlayer = source
	vRPCstages.setCarCurrentStage(thePlayer, {0})
end)

AddEventHandler("vRP:playerLeave", function(user_id, source)
	if(usingStager ~= nil)then
		if(usingStager == user_id)then
			usingStager = nil
			vRPCstages.deleteStargerCar(source, {})
		end
	end
end)