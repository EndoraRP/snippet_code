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

INFO : 

FR: 

- Gestion des facture pour les patrons des societées

EN:

- Invoice management for corporate bosses

----------------------------------------------------------
----------------------------------------------------------
---------------------- esx_billing -----------------------
----------------------------------------------------------
----------------------------------------------------------

(esx_billing/server.main.lua)

select all : xPlayer.identifier to xPlayer.name 

----------------------------------------------------------
----------------------------------------------------------
---------------------- esx_society -----------------------
----------------------------------------------------------
----------------------------------------------------------


----------------- Client -----------------

In '''function OpenBossMenu(society, close, options)''' 
    
  if options.billing then
    table.insert(elements, {label = _U('billing_management'), value = 'manage_billing'})
  end

  if data.current.value == 'manage_billing' then
    OpenManageBillingMenu(society)
  end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

Create '''function OpenManageBillingMenu()'''

function OpenManageBillingMenu()

    ESX.TriggerServerCallback('esx_society:getBilling', function(data)
  
      local elements = {
          head = { 'Client', 'Salarié', 'Linbélé', 'Montant', 'Action'},
        rows = {}
      }
  
      for i=1, #data, 1 do
  
        table.insert(elements.rows, {
          data = data[i],
          cols = {
            data[i].identifier,
            data[i].sender,
            data[i].label,
            data[i].amount,
  
            '{{' ..'Supprimer' .. '|delete}}'
          }
        })
      end
  
      ESX.UI.Menu.Open(
        'list', GetCurrentResourceName(), 'customers',
        elements,
        function(data, menu)
  
          if data.value == 'delete' then
            TriggerServerEvent('esx_society:deletebilling', data.data.id)
            menu.close()
          end
        end,
        function(data, menu)
          menu.close()
        end
      )
    end)
  
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

----------------- Server -----------------

ESX.RegisterServerCallback('esx_society:getBilling', function(source, cb)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
  
    MySQL.Async.fetchAll(

        'SELECT * FROM billing WHERE target = @targer',
        { ['@targer'] = 'society_'..xPlayer.job.name},

        function(result)

        local data = {}

        for i=1, #result, 1 do
            table.insert(data, {
                id         = result[i].id,
                identifier = result[i].identifier,
                sender     = result[i].sender,
                target     = result[i].targer,
                label      = result[i].label,
                amount     = result[i].amount
            })
        end

        cb(data)

        end
    )

end)

RegisterServerEvent('esx_society:deletebilling')
AddEventHandler('esx_society:deletebilling', function(id)

  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.execute('DELETE FROM billing WHERE id = @id',
  {
    ['@id'] = id
  })

  TriggerClientEvent('esx:showNotification', xPlayer.source, 'Facture ~b~supprimé')

end)
