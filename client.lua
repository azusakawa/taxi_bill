Config = {}

Config.Basic = 10
Config.KMprice = 20

--[[    Don't touch    ]]
local time, total, average, price = 0, 0, 0, 0

ESX = nil
local PlayerData = {}
local started = false
--[[    ESX Base    ]]

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
        PlayerData = ESX.GetPlayerData()
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterCommand("stop", function()
    started = false
end)

RegisterCommand("clear", function()
    claer()
    started = true
end)

RegisterCommand("start", function()
    if PlayerData.job.name == 'taxi' then
        claer()
        started = true
        StartBill()
    else
        Notify('Your job is not taxi')
    end
end)

function claer()
    time = 0
    total = 0
    average = 0
    price = 0
    started = false
end


function StartBill()
    local player = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(player, false)
    while true do
        Citizen.Wait(0)
        if not started then
            return
        end
        if (IsPedSittingInAnyVehicle(player)) then
            time = time + 1
            total = total + GetEntitySpeed(vehicle) * 3.6
            average = total / time 

            local distance = average * time / 3600

            price = (Config.Basic + (Config.KMprice * distance))

            message = "計費開始,起跳價 ~g~$: " .. Config.Basic .. " ~w~,每公里收費 ~g~$: " .. Config.KMprice .. " ~w~,總計 ~g~$: " .. tostring(round(price))

            DrawTxt(message, 0.335, 0.94)
        else
            Notify('You must in vehicle to do this action')
        end
    end
end

RegisterCommand("pay", function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer == -1 or closestDistance > 3.0 then
        Notify('Not player naer you')
    else
        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_taxi', 'Taxi', price)
    end
end)

--[[    Function    ]]
function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function Notify(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function DrawTxt(text, x, y)
	SetTextFont(1)
	SetTextProportional(1)
	SetTextScale(0.4, 0.5)
	SetTextDropshadow(1, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry('STRING')
	AddTextComponentString(text)
	DrawText(x, y)
end