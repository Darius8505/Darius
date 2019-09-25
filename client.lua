vRPCstages = {}
Tunnel.bindInterface("vRP_carStages",vRPCstages)
Proxy.addInterface("vRP_carStages",vRPCstages)
vRPSstages = Tunnel.getInterface("vRP_carStages","vRP_carStages")
vRP = Proxy.getInterface("vRP")

currentStage = 0
currentVeh = nil
vehModel = nil

stageInstallProgress = -1

installingStage = 0

stageSpeeds = {
	[1] = 40,
	[2] = 60,
	[3] = 100,	
}

stageLoc = {-1478.8155517578,-1008.094909668,6.2788805961608}
stagePWarp = {-1473.500366211,-1001.1100463868,6.3154273033142,135.46794128418}

carSpawnLoc = {-1480.6160888672,-998.09765625,6.2604594230652,141.68730163574}

function vRPCstages.setCarCurrentStage(theStage)
	currentStage = tonumber(theStage)
end

function vRPCstages.deleteStargerCar()
	DeleteEntity(currentVeh)
	currentVeh = nil
end

function stages_DisplayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function vRPCstages.applyCarStage(installStage, vehicleModel)
	currentVeh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	SetEntityCoords(currentVeh, stageLoc[1], stageLoc[2], stageLoc[3])
	FreezeEntityPosition(currentVeh, true)
	vehModel = vehicleModel
	Citizen.CreateThread(function()
		while DoesEntityExist(currentVeh) do
			Citizen.Wait(25)
			SetEntityHeading(currentVeh, GetEntityHeading(currentVeh)+1 %360)
		end
	end)
	
	installingStage = installStage
	
	stageInstallProgress = 0
	
	SetEntityCoords(GetPlayerPed(-1), stagePWarp[1], stagePWarp[2], stagePWarp[3])
	SetEntityHeading(GetPlayerPed(-1), stagePWarp[4])
end

function DrawText3D(x,y,z, text, scl, font) 

    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*scl
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 200)
        SetTextDropshadow(0, 0, 0, 0, 200)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2000)
		if(installingStage ~= 0)then
			if(stageInstallProgress < 100)then
				stageInstallProgress = stageInstallProgress + 1
			elseif(stageInstallProgress == 100)then
				stageInstallProgress = 0
				vRPSstages.applyStages({installingStage, vehModel})
				installingStage = 0
				SetEntityCoords(currentVeh, carSpawnLoc[1], carSpawnLoc[2], carSpawnLoc[3])
				SetEntityHeading(currentVeh, carSpawnLoc[4])
				FreezeEntityPosition(currentVeh, false)
				currentVeh = nil
				vehModel = nil
			end
		end
	end
end)

function stage_drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(7)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
	    SetTextOutline()
	end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local coords = GetEntityCoords(GetPlayerPed(-1))
		if(GetDistanceBetweenCoords(coords.x, coords.y, coords.z, stageLoc[1], stageLoc[2], stageLoc[3], true) <= 25.0)then
			if(currentVeh ~= nil)then
				DrawText3D(stageLoc[1], stageLoc[2], stageLoc[3]+1.4, "~g~Instalare: ~y~Stage "..installingStage.."\n~g~Progres: ~r~"..stageInstallProgress.."%", 2.5, 1)
			else
				DrawText3D(stageLoc[1], stageLoc[2], stageLoc[3]+0.3, "~g~Instalare Stageuri", 2.0, 7)
			end
			DrawMarker(1, stageLoc[1], stageLoc[2], stageLoc[3]-1.0, 0, 0, 0, 0, 0, 0, 2.5, 2.5, 0.5, 0, 255, 0, 180, 0, 0, 0, 0)
			if(GetDistanceBetweenCoords(coords.x, coords.y, coords.z, stageLoc[1], stageLoc[2], stageLoc[3], true) <= 2.5)then
				veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
				if(currentVeh == nil)then
					if (IsPedInAnyVehicle(GetPlayerPed(-1), false)) and (GetPedInVehicleSeat(veh, -1) == GetPlayerPed(-1)) then
						local ok, vtype, name = vRP.getNearestOwnedVehicle({7})
						if ok then					
							stages_DisplayHelpText("Apasa ~INPUT_CONTEXT~ pentru a accesa meniul de ~g~Stageuri")
							if(IsControlJustReleased(1, 51))then
								vRPSstages.showCarStagesMenu({GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1), false))})
							end
						else
							stages_DisplayHelpText("~r~Trebuie sa vi cu vehiculul tau personal!")
						end
					else
						stages_DisplayHelpText("~r~Trebuie sa vi cu vehiculul tau personal!")
					end
				else
					stages_DisplayHelpText("~r~Asteapta pana ce vehiculul actual este gata!")
				end
			end
		end
		
		veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		if (IsPedInAnyVehicle(GetPlayerPed(-1), false)) and (GetPedInVehicleSeat(veh, -1) == GetPlayerPed(-1)) then
			if(currentStage ~= 0)then
				stage_drawTxt(1.29, 1.43, 1.0,1.0,0.3, "~w~Stage: ~g~"..currentStage, 255, 255, 255, 255)
				SetVehicleEnginePowerMultiplier(veh, stageSpeeds[currentStage] + 0.001)
			end
		end
	end
end)