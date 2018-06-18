--[[
           _____                    _____                    _____                    _____          
          /\    \                  /\    \                  /\    \                  /\    \         
         /::\    \                /::\    \                /::\    \                /::\____\        
        /::::\    \              /::::\    \              /::::\    \              /::::|   |        
       /::::::\    \            /::::::\    \            /::::::\    \            /:::::|   |        
      /:::/\:::\    \          /:::/\:::\    \          /:::/\:::\    \          /::::::|   |        
     /:::/__\:::\    \        /:::/  \:::\    \        /:::/__\:::\    \        /:::/|::|   |        
    /::::\   \:::\    \      /:::/    \:::\    \      /::::\   \:::\    \      /:::/ |::|   |        
   /::::::\   \:::\    \    /:::/    / \:::\    \    /::::::\   \:::\    \    /:::/  |::|   | _____  
  /:::/\:::\   \:::\    \  /:::/    /   \:::\ ___\  /:::/\:::\   \:::\    \  /:::/   |::|   |/\    \ 
 /:::/__\:::\   \:::\____\/:::/____/     \:::|    |/:::/__\:::\   \:::\____\/:: /    |::|   /::\____\
 \:::\   \:::\   \::/    /\:::\    \     /:::|____|\:::\   \:::\   \::/    /\::/    /|::|  /:::/    /
  \:::\   \:::\   \/____/  \:::\    \   /:::/    /  \:::\   \:::\   \/____/  \/____/ |::| /:::/    / 
   \:::\   \:::\    \       \:::\    \ /:::/    /    \:::\   \:::\    \              |::|/:::/    /  
    \:::\   \:::\____\       \:::\    /:::/    /      \:::\   \:::\____\             |::::::/    /   
     \:::\   \::/    /        \:::\  /:::/    /        \:::\   \::/    /             |:::::/    /    
      \:::\   \/____/          \:::\/:::/    /          \:::\   \/____/              |::::/    /     
       \:::\    \               \::::::/    /            \:::\    \                  /:::/    /      
        \:::\____\               \::::/    /              \:::\____\                /:::/    /       
         \::/    /                \::/____/                \::/    /                \::/    /        
          \/____/                  ~~                       \/____/                  \/____/         
                                                                                                     
]] 
----------------------------------------------------------
INFO : 

FR : 

- Livraison de son vehicule personnel par un pnj

EN : 

- If u want your vehicle delivery by a pnj
	
Needed script : 

- U need eden_garage for use this snippet
----------------------------------------------------------

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

----------------- Client -----------------
function OpenLiveryMenu()
	local elements = {}

	ESX.TriggerServerCallback('eden_garage:getVehicles', function(vehicles)

	  for _,v in pairs(vehicles) do

		local hashVehicule = v.vehicle.model
		  local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
		  local labelvehicle

		  if(v.state)then
		  	labelvehicle = vehicleName..': Return'
		  else
		  	labelvehicle = vehicleName..': Exit'
		  end
			table.insert(elements, {label = labelvehicle , value = v})
	  end

	  ESX.UI.Menu.Open(
	  'default', GetCurrentResourceName(), 'delivery_vehicle',
	  {
			title    = 'Vehicle delivery',
			align    = 'top-left',
			elements = elements,
	  },
	  function(data, menu)
			if(data.current.value.state)then
			  menu.close()
			  LiveryVehicle(data.current.value.vehicle)
			  ESX.ShowNotification('~o~... Wait')
			else
			  TriggerEvent('esx:showNotification', 'Your vehicle is already out !')
			end
	  end,
	  function(data, menu)
		  menu.close()
	  end)
	end)
end

function LiveryVehicle(vehicle)

	local coords 	 = GetEntityCoords(GetPlayerPed(-1))
	local distance = GetDistanceBetweenCoords(-774.76385498047 , 274.4645690918, 84.782699584961, coords, true)
	local price 	 = math.floor(distance * 1.25)

	ESX.Game.SpawnVehicle(vehicle.model, { x = -774.76385498047 ,	y = 274.4645690918,	z = 84.782699584961	}, 120, function(callback_vehicle)
	  ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
	  LiveryActive = true

	  RequestModel('A_M_M_Business_01')
	  while not HasModelLoaded('A_M_M_Business_01') do
			Citizen.Wait(10)
	  end

	  LiveryPed = CreatePedInsideVehicle(callback_vehicle, 4, 'A_M_M_Business_01', -1, true, false)
	  TaskGoToCoordAnyMeans(LiveryPed, coords, 1.0, 0, 0, 387, 0xbf800000)
	  ESX.ShowNotification('Vehicle in the delivery yard')
	end)

	TriggerServerEvent('eden_livery:PayLivery', price)
  TriggerServerEvent('eden_garage:modifystate', vehicle, false)
end

Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(1)

		local coords = GetEntityCoords(GetPlayerPed(-1))
		local coordsPed = GetEntityCoords(LiveryPed)
		local distance2 = GetDistanceBetweenCoords(coordsPed , coords,true)

		if distance2 < 8 and LiveryActive then
			TaskLeaveVehicle(LiveryPed, callback_vehicle, 256)
			ESX.ShowNotification('~g~Here is your car')
			ClearPedTasks(LiveryPed)
			Wait(1500)
			LiveryActive = false
			TriggerEvent('menuperso:pedwalk')
		end
	end
end)

RegisterNetEvent('menuperso:pedwalk')
AddEventHandler('menuperso:pedwalk', function()
	TaskWanderStandard(LiveryPed, true, true )
	Wait(60000)
	SetEntityCoords( LiveryPed , -4432.4321 , -5643.3969 , 999 , true , true , true , true )
end)

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

----------------- Server -----------------
RegisterServerEvent('eden_livery:PayLivery')
AddEventHandler('eden_livery:PayLivery', function(price)

  local _source  = source
  local xPlayer  = ESX.GetPlayerFromId(_source)
  local xPlayers = ESX.GetPlayers()

  xPlayer.removeMoney(price)
end)
