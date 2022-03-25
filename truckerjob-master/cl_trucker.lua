local markerPos = vector3(-737, -2565, 14)
local HasAlreadyGotMessage = false
local modelHash = 2112052861 --Change this if you want a different truck
local TruckJobInProggres = false
local RouteSet = false
local deliveryMarkerPos
local HasAlreadyGotDeliveryMessage = false
local alreadyDelivered = false
local pickedroutes = {}
Citizen.CreateThread(function()
    local ped = GetPlayerPed(-1)
    InsertRoutes()
    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(ped)
        local distance = #(playerCoords - markerPos)
        local isInMarker = false        
        local isInDeliveryMarker = false
        if distance < 20 then
           DrawMarker(0, -737.0, -2565.0, 15.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 255, 128, 0, 120, false, true, 2, nil, nil, false)
           if distance < 2 then 
            isInMarker = true
           else
            HasAlreadyGotMessage = false
           end
        else
            Wait(2000)
        end
        if isInMarker and not HasAlreadyGotMessage then 
            exports['mystic-notify']:SendAlert('Zmackni [E] pro získání zakázky', 'info')
            HasAlreadyGotMessage = true
        end
        if isInMarker and IsControlJustReleased(1,51) then 
            if not TruckJobInProggres then 
                exports['mystic-notify']:SendAlert('Byla ti přiřazena zakázka', 'info')
                VytvorTruck()
            else
                exports['mystic-notify']:SendAlert('Již máš přiřazenou zakázku', 'warn')
            end
        end
        if TruckJobInProggres and not RouteSet then
            deliveryblip = AddBlipForCoord(pickedroutes[math.random(#pickedroutes)])
            SetBlipSprite(deliveryblip, 304)
            SetBlipDisplay(deliveryblip, 4)
            SetBlipScale(deliveryblip, 1.0)
            SetBlipColour(deliveryblip, 5)
            SetBlipAsShortRange(deliveryblip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("doruceni")
            EndTextCommandSetBlipName(deliveryblip)
            SetBlipRoute(deliveryblip, true)
            Citizen.Wait(1)
            RouteSet = true
            deliveryMarkerPos = GetBlipCoords(deliveryblip)
        end
        if TruckJobInProggres then
            deliveryMarkerDistance = #(playerCoords - deliveryMarkerPos)
            Citizen.Wait(10)
        end
        while RouteSet and deliveryMarkerDistance < 50 do
            DrawMarker(25,deliveryMarkerPos.x,deliveryMarkerPos.y,deliveryMarkerPos.z - 0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 10.0, 10.0, 255, 128, 0, 120, false, true, 2, nil, nil, false)
            Citizen.Wait(1)
            isInDeliveryMarker = true
            if not HasAlreadyGotDeliveryMessage and isInDeliveryMarker then
                exports['mystic-notify']:SendAlert('Zmáčkni [E] pro odevzdání zakázky', 'info')
                HasAlreadyGotDeliveryMessage = true
            end
            if isInDeliveryMarker and IsControlJustReleased(1,51) and not alreadyDelivered then
                alreadyDelivered = true
                RemoveBlip(deliveryblip)
                TriggerServerEvent('trucker:vyplata')
                trucknasmazani = GetVehiclePedIsIn(ped, false)
                SetEntityAsMissionEntity(trucknasmazani, true, true)
                DeleteVehicle(trucknasmazani)
                RouteSet = false
                TruckJobInProggres = false
            end
        end
    end
end)
function VytvorTruck()
    TruckJobInProggres = true 
    RequestModel(modelHash) 
    while not HasModelLoaded(modelHash) do 
        Citizen.Wait(10)
    end
    local MyPed = PlayerPedId()
    local vehicle = CreateVehicle(modelHash, -755.96, -2591.77, 13.91,237.87, true, false) 
    SetModelAsNoLongerNeeded(modelHash)
    TaskWarpPedIntoVehicle(MyPed, vehicle, -1) 
    HasAlreadyGotDeliveryMessage = false
    alreadyDelivered = false
    if Config.useLegacyFuel then
        exports[--[[Insert the LegacyFuel export here]]]:SetFuel(vehicle, 100) 
    end
end
function InsertRoutes()
    for k,v in ipairs(Config.routes) do
        table.insert(pickedroutes,v)
    end
end
