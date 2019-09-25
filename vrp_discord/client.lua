--Z--

Citizen.CreateThread(function()

	while true do

		Citizen.Wait(5000)

		players = {}

		for i = 0, 31 do

			if NetworkIsPlayerActive( i ) then

				table.insert( players, i )

			end

		end

	end

end)



Citizen.CreateThread(function()

    while true do

        TriggerServerEvent("vRP:Discord")

		Citizen.Wait(5000)

	end

end)



RegisterNetEvent('vRP:Discord-rich')

AddEventHandler('vRP:Discord-rich', function(user_id, faction, name)

SetDiscordAppId(615702486983901185)-- Discord app ID --DISCORD ID

SetDiscordRichPresenceAsset('logo') -- PNG file

SetDiscordRichPresenceAssetText('Crystal Romania RolePlay') -- PNG text desc       --Aici puneti numele

SetDiscordRichPresenceAssetSmall('discord') -- PNG small

SetDiscordRichPresenceAssetSmallText('https://discord.io/CrystalRoRP') -- PNG text desc2 --Aici puneti server-ul

SetRichPresence("[ID:"..user_id.."][Job:"..faction.."][Name:"..name.. "] - | ".. #players .. "/32 |")

end)