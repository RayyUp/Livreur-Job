ESX = exports['es_extended']:getSharedObject()

local isOnMission = false
local currentBike = nil
local deliveryPoint = nil
local deliveryPoints = {}

RegisterNetEvent('delivery:setPoints')
AddEventHandler('delivery:setPoints', function(points)
    deliveryPoints = points
end)

Citizen.CreateThread(function()
    TriggerServerEvent('delivery:getPoints')
end)

local pedCoords = vector3(-1076.0914, -1677.2520, 4.5752)
local pedHeading = 309.9528
local startPed = nil

Citizen.CreateThread(function()
    RequestModel('a_m_m_business_01')
    while not HasModelLoaded('a_m_m_business_01') do
        Wait(100)
    end

    startPed = CreatePed(4, GetHashKey('a_m_m_business_01'), pedCoords.x, pedCoords.y, pedCoords.z - 1.0, pedHeading, false, true)
    SetEntityInvincible(startPed, true)
    SetBlockingOfNonTemporaryEvents(startPed, true)
    FreezeEntityPosition(startPed, true)

    exports['ox_target']:addLocalEntity(startPed, {
        {
            name = 'start_delivery',
            label = 'Prendre la mission',
            icon = 'fas fa-bicycle',
            onSelect = function()
                StartDeliveryMission()
            end,
        }
    })

    local blip = AddBlipForCoord(pedCoords.x, pedCoords.y, pedCoords.z)
    SetBlipSprite(blip, 280)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Point de départ de la mission")
    EndTextCommandSetBlipName(blip)
end)

local startPoint = pedCoords

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        if #(coords - startPoint) < 10.0 then
            if #(coords - startPoint) < 2.0 then
                if IsControlJustReleased(0, 38) then
                    StartDeliveryMission()
                end
            end
        end
    end
end)

function StartDeliveryMission()
    if isOnMission then
        ESX.ShowNotification('Vous êtes déjà en mission!')
        return
    end

    isOnMission = true
    deliveryPoint = deliveryPoints[math.random(#deliveryPoints)]

    local model = GetHashKey('bmx')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    currentBike = CreateVehicle(model, coords.x + 2, coords.y, coords.z, 0.0, true, false)
    SetVehicleHasBeenOwnedByPlayer(currentBike, true)
    SetModelAsNoLongerNeeded(model)

    ESX.ShowNotification('Prenez le vélo et livrez-le au point indiqué!')

    local deliveryBlip = AddBlipForCoord(deliveryPoint.x, deliveryPoint.y, deliveryPoint.z)
    SetBlipRoute(deliveryBlip, true)

    Citizen.CreateThread(function()
        while isOnMission do
            Citizen.Wait(0)
            local playerCoords = GetEntityCoords(playerPed)
            if #(playerCoords - vector3(deliveryPoint.x, deliveryPoint.y, deliveryPoint.z)) < 10.0 then
                DrawMarker(1, deliveryPoint.x, deliveryPoint.y, deliveryPoint.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
                if #(playerCoords - vector3(deliveryPoint.x, deliveryPoint.y, deliveryPoint.z)) < 2.0 then
                    CompleteDelivery(deliveryBlip)
                end
            end
        end
    end)
end

function CompleteDelivery(deliveryBlip)
    RemoveBlip(deliveryBlip)

    if DoesEntityExist(currentBike) then
        DeleteVehicle(currentBike)
    end

    TriggerServerEvent('delivery:payPlayer')

    isOnMission = false
    currentBike = nil
    deliveryPoint = nil
end
